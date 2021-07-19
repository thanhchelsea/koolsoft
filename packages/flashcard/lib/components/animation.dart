import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'animations.dart';

enum SwipDirection {
  Left,
  Right,
  None,
}

class SwipInfo {
  final int cardIndex;
  final SwipDirection direction;

  SwipInfo(
    this.cardIndex,
    this.direction,
  );
}

class TCardController {
  TCardState? state;

  void bindState(TCardState state) {
    this.state = state;
  }

  int get index => state?.frontCardIndex ?? 0;

  forward({SwipDirection? direction}) {
    if (direction == null) {
      direction =
          Random().nextBool() ? SwipDirection.Left : SwipDirection.Right;
    }

    state!.swipInfoList.add(SwipInfo(state!.frontCardIndex, direction));
    state!.runChangeOrderAnimation();
  }

  back() {
    state!.runReverseOrderAnimation();
  }

  get reset => state!.reset;

  void dispose() {
    state = null;
  }
}

typedef ForwardCallback(int index, SwipInfo info);
typedef BackCallback(int index, SwipInfo info);
typedef EndCallback();

typedef CardDragUpdateCallback = void Function(
    DragUpdateDetails details, Alignment align);

class TCard extends StatefulWidget {
  final Size size;

  final List<Widget> cards;

  final ForwardCallback? onForward;

  final BackCallback? onBack;

  final EndCallback? onEnd;

  final TCardController? controller;

  final CardDragUpdateCallback? updateMove;

  final Function? onDragEnd;

  final bool lockYAxis;

  /// How quick should it be slided? less is slower. 10 is a bit slow. 20 is a quick enough.
  final double slideSpeed;

  /// How long does it have to wait until the next slide is sliable? less is quicker. 100 is fast enough. 500 is a bit slow.
  final int delaySlideFor;

  const TCard({
    required this.cards,
    this.controller,
    this.onForward,
    this.onBack,
    this.onEnd,
    this.lockYAxis = false,
    this.slideSpeed = 20,
    this.delaySlideFor = 500,
    this.size = const Size(380, 400),
    this.updateMove,
    this.onDragEnd,
  })  : assert(cards != null),
        assert(cards.length > 0);

  @override
  TCardState createState() => TCardState();
}

class TCardState extends State<TCard> with TickerProviderStateMixin {
  final List<Widget> _cards = [];
  // Card swip directions
  final List<SwipInfo> _swipInfoList = [];
  List<SwipInfo> get swipInfoList => _swipInfoList;

  int _frontCardIndex = 0;
  int get frontCardIndex => _frontCardIndex;
  Alignment frontCardAlign = Alignment(0, 0);

  Alignment _frontCardAlignment = CardAlignments.front;
  double _frontCardRotation = 0.0;
  late AnimationController _cardChangeController;
  late AnimationController _cardReverseController;
  late Animation<Alignment> _reboundAnimation;
  late AnimationController _reboundController;
  bool isBacking = false;
  Widget _frontCard(BoxConstraints constraints) {
    Widget child =
        _frontCardIndex < _cards.length ? _cards[_frontCardIndex] : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    Widget rotate = Transform.rotate(
      angle: (math.pi / 180.0) * _frontCardRotation,
      child: SizedBox.fromSize(
        size: CardSizes.front(constraints),
        child: child,
      ),
    );

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.frontCardShowAnimation(
          _cardReverseController,
          CardAlignments.front,
          _swipInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.frontCardDisappearAnimation(
          _cardChangeController,
          _frontCardAlignment,
          _swipInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else {
      return Align(
        alignment: _frontCardAlignment,
        child: rotate,
      );
    }
  }

  Widget _middleCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length - 1
        ? _cards[_frontCardIndex + 1]
        : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.middleCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.middleCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.middleCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.middleCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.middle,
        child: SizedBox.fromSize(
          size: CardSizes.middle(constraints),
          child: child,
        ),
      );
    }
  }

  Widget _backCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length - 2
        ? _cards[_frontCardIndex + 2]
        : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.backCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.backCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.backCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.backCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.back,
        child: SizedBox.fromSize(
          size: CardSizes.back(constraints),
          child: child,
        ),
      );
    }
  }

  bool _isAnimating() {
    return _cardChangeController.status == AnimationStatus.forward ||
        _cardReverseController.status == AnimationStatus.forward;
  }

  void _runReboundAnimation(Offset pixelsPerSecond, Size size) {
    _reboundAnimation = _reboundController.drive(
      AlignmentTween(
        begin: _frontCardAlignment,
        end: CardAlignments.front,
      ),
    );

    final double unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final double unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;
    const spring = SpringDescription(mass: 30.0, stiffness: 1.0, damping: 1.0);
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _reboundController.animateWith(simulation);
    _resetFrontCard();
  }

  void _runChangeOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex >= _cards.length) {
      return;
    }

    _cardChangeController.reset();
    _cardChangeController.forward();
  }

  get runChangeOrderAnimation => _runChangeOrderAnimation;

  void _runReverseOrderAnimation() {
    setState(() {
      isBacking = true;
    });
    if (_isAnimating()) {
      setState(() {
        isBacking = false;
      });
      return;
    }

    if (_frontCardIndex == 0) {
      // khong co quay ve
      _swipInfoList.clear();
      setState(() {
        isBacking = false;
      });
      return;
    }

    _cardReverseController.reset();
    _cardReverseController.forward().whenComplete(() {
      setState(() {
        isBacking = false;
      });
    });
  }

  get runReverseOrderAnimation => _runReverseOrderAnimation;

  void _forwardCallback() {
    _frontCardIndex++;
    _resetFrontCard();
    if (widget.onForward != null && widget.onForward is Function) {
      widget.onForward!(
        _frontCardIndex,
        _swipInfoList[_frontCardIndex - 1],
      );
    }
    if (widget.onEnd != null &&
        widget.onEnd is Function &&
        _frontCardIndex >= _cards.length) {
      widget.onEnd!();
    }
    frontCardAlign = Alignment(0, 0);
  }

  // Back animation callback
  void _backCallback() {
    _resetFrontCard();

    if (widget.onBack != null && widget.onBack is Function) {
      int index = _frontCardIndex > 0 ? _frontCardIndex - 1 : 0;
      SwipInfo info = _swipInfoList[_frontCardIndex];
      widget.onBack!(_frontCardIndex, info);
    }
    _swipInfoList.removeLast();
    frontCardAlign = Alignment(0, 0);
  }

  void _resetFrontCard() {
    _frontCardRotation = 0.0;
    _frontCardAlignment = CardAlignments.front;
    setState(() {});
    frontCardAlign = Alignment(0, 0);
  }

  void reset({List<Widget>? cards}) {
    _cards.clear();
    if (cards != null) {
      _cards.addAll(cards);
    } else {
      _cards.addAll(widget.cards);
    }
    _swipInfoList.clear();
    _frontCardIndex = 0;
    _resetFrontCard();
    frontCardAlign = Alignment(0, 0);
  }

  void _stop() {
    _reboundController.stop();
    _cardChangeController.stop();
    _cardReverseController.stop();
  }

  void _updateFrontCardAlignment(DragUpdateDetails details, Size size) {
    _frontCardAlignment += Alignment(
      details.delta.dx / (size.width / 2) * widget.slideSpeed,
      widget.lockYAxis
          ? 0
          : details.delta.dy / (size.height / 2) * widget.slideSpeed,
    );

    _frontCardRotation = _frontCardAlignment.x;
    setState(() {});
  }

  void _judgeRunAnimation(DragEndDetails details, Size size) {
    final double limit = 10.0;
    final bool isSwipLeft = _frontCardAlignment.x < -limit;
    final bool isSwipRight = _frontCardAlignment.x > limit;

    if (isSwipLeft || isSwipRight) {
      _runChangeOrderAnimation();
      if (isSwipLeft) {
        _swipInfoList.add(SwipInfo(_frontCardIndex, SwipDirection.Left));
      } else {
        _swipInfoList.add(SwipInfo(_frontCardIndex, SwipDirection.Right));
      }
    } else {
      _runReboundAnimation(details.velocity.pixelsPerSecond, size);
    }
  }

  @override
  void initState() {
    super.initState();

    _cards.addAll(widget.cards);

    if (widget.controller != null && widget.controller is TCardController) {
      widget.controller!.bindState(this);
    }

    _cardChangeController = AnimationController(
      duration: Duration(milliseconds: widget.delaySlideFor),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _forwardCallback();
        }
      });

    _cardReverseController = AnimationController(
      duration: Duration(milliseconds: widget.delaySlideFor),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _frontCardIndex--;
        } else if (status == AnimationStatus.completed) {
          _backCallback();
        }
      });

    _reboundController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.delaySlideFor),
    )..addListener(() {
        setState(() {
          _frontCardAlignment = _reboundAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _cardReverseController.dispose();
    _cardChangeController.dispose();
    _reboundController.dispose();
    if (widget.controller != null) {
      widget.controller!.dispose();
    }
    super.dispose();
  }

  // Alignment frontCardAlign;
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.size,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          Size size = MediaQuery.of(context).size;
          return Stack(
            children: <Widget>[
              RotationTransition(
                turns: AlwaysStoppedAnimation(8 / 360),
                child: _backCard(constraints),
              ),
              GestureDetector(
                onTap: null,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(-8 / 360),
                  child: _middleCard(constraints),
                ),
              ),
              _frontCard(constraints),
              isBacking == false &&
                      _cardChangeController.status != AnimationStatus.forward
                  ? SizedBox.expand(
                      child: GestureDetector(
                        onPanDown: (DragDownDetails details) {
                          _stop();
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          setState(() {
                            frontCardAlign = new Alignment(
                                frontCardAlign.x +
                                    details.delta.dx *
                                        20 /
                                        MediaQuery.of(context).size.width,
                                0);
                          });
                          if (widget.updateMove != null) {
                            widget.updateMove!(details, frontCardAlign);
                          }
                          _updateFrontCardAlignment(details, size);
                        },
                        onPanEnd: (DragEndDetails details) {
                          widget.onDragEnd!();
                          _judgeRunAnimation(details, size);
                        },
                      ),
                    )
                  : IgnorePointer(),
            ],
          );
        },
      ),
    );
  }
}
