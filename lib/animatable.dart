import 'package:anim/anim.dart';
import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';
export 'package:flutter/animation.dart';

abstract class AnimAnimatable {
  final Duration startDelay;
  AnimAnimatable({
    @required this.startDelay,
  });
  Future<void> play();
  void dispose();
}

class SimpleAnimatable extends AnimAnimatable {
  AnimationController animationController;
  final String name;
  final List<double> values;
  Animation<double> animation;
  final Curve curve;
  final Duration duration;
  
  SimpleAnimatable({
    @required AnimValueSetter animValueSetter,
    @required this.name,
    @required this.values,
    @required this.curve,
    @required this.duration,
    @required Duration startDelay,
  }) : super(startDelay: startDelay) {
    animationController =
        AnimationController(vsync: animValueSetter.anim.vsync, duration: duration);

    final List<TweenSequenceItem<double>> tweens = List<TweenSequenceItem<double>>();
    for (var i = 1; i < values.length; i++) {
      tweens.add(
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: values[i - 1], end: values[i]),
          weight: 1,
        ),
      );
    }

    animation = TweenSequence(tweens).animate(
        CurvedAnimation(parent: this.animationController, curve: this.curve));
    animation.addListener((){
      animValueSetter.setValue(name, animation.value);
    });
  }

  @override
  void dispose() {
    this.animationController.dispose();
  }

  @override
  Future<void> play() async {
    if(animationController.isCompleted){
      animationController.reset();
    }
    if (startDelay != null) {
      await Future.delayed(startDelay);
    }
    await animationController.forward().orCancel;
  }
}

class TogetherAnimatable extends AnimAnimatable {
  final List<AnimAnimatable> animatables;

  TogetherAnimatable({this.animatables, Duration startDelay}) : super(startDelay: startDelay);

  @override
  Future<void> play() async {
    if (startDelay != null) {
      await Future.delayed(startDelay);
    }
    final List<Future> animationsFutures = List<Future>();
    for (var animatable in animatables) {
      animationsFutures.add(animatable.play());
    }
    await Future.wait(animationsFutures);
  }

  @override
  void dispose() {
    for(var animatable in animatables){
      animatable.dispose();
    }
  }
}

class ChainAnimatable extends AnimAnimatable {
  final List<AnimAnimatable> animatables;

  ChainAnimatable({this.animatables, Duration startDelay}) : super(startDelay: startDelay);

  @override
  Future<void> play() async {
    if (startDelay != null) {
      await Future.delayed(startDelay);
    }
    for (var animatable in animatables) {
      await animatable.play();
    }
  }

  @override
  void dispose() {
    for(var animatable in animatables){
      animatable.dispose();
    }
  }
}
