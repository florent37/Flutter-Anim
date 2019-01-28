import 'package:anim/anim.dart';
import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';
export 'package:flutter/animation.dart';

import 'dart:async';
export 'dart:async';

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
  final AnimValues animValues;
  Animation animation;

  SimpleAnimatable({
    @required AnimValueSetter animValueSetter,
    @required this.animValues,
  }) : super(startDelay: animValues.startDelay) {
    animationController = AnimationController(
        vsync: animValueSetter.anim.vsync, duration: this.animValues.duration);

    final List<TweenSequenceItem<double>> tweens =
        List<TweenSequenceItem<double>>();
    for (var i = 1; i < this.animValues.values.length; i++) {
      tweens.add(
        TweenSequenceItem<double>(
          tween: Tween<double>(
              begin: this.animValues.values[i - 1],
              end: this.animValues.values[i]),
          weight: 1,
        ),
      );
    }

    animation = TweenSequence(tweens).animate(
      CurvedAnimation(
          parent: this.animationController, curve: this.animValues.curve),
    );
    final bool hasListener = this.animValues.listener != null;
    animation.addListener(() {
      if (hasListener) {
        this.animValues.listener(animation.value);
      }
      animValueSetter.setValue(this.animValues.name, animation.value);
    });
  }

  @override
  void dispose() {
    this.animationController.dispose();
  }

  @override
  Future<void> play() async {
    if (animationController.isCompleted) {
      animationController.reset();
    }
    if (startDelay != null) {
      await Future.delayed(startDelay);
    }
    if (animValues.statusListener != null) {
      animValues.statusListener(AnimAnimationStatus.started);
    }
    await animationController.forward().orCancel;
    if (animValues.statusListener != null) {
      animValues.statusListener(AnimAnimationStatus.finished);
    }
  }
}

class TogetherAnimatable extends AnimAnimatable {
  final List<AnimAnimatable> animatables;
  final AnimTogether animTogether;

  TogetherAnimatable({this.animatables, Duration startDelay, this.animTogether})
      : super(startDelay: startDelay);

  @override
  Future<void> play() async {
    if (startDelay != null) {
      await Future.delayed(startDelay);
    }
    if (animTogether.statusListener != null) {
      animTogether.statusListener(AnimAnimationStatus.started);
    }
    final List<Future> animationsFutures = List<Future>();
    for (var animatable in animatables) {
      animationsFutures.add(animatable.play());
    }
    await Future.wait(animationsFutures);
    if (animTogether.statusListener != null) {
      animTogether.statusListener(AnimAnimationStatus.finished);
    }
  }

  @override
  void dispose() {
    for (var animatable in animatables) {
      animatable.dispose();
    }
  }
}

class ChainAnimatable extends AnimAnimatable {
  final List<AnimAnimatable> animatables;
  final AnimSequentially animSequentially;

  ChainAnimatable(
      {this.animatables, this.animSequentially, Duration startDelay})
      : super(startDelay: startDelay);

  @override
  Future<void> play() async {
    if (startDelay != null) {
      await Future.delayed(startDelay);
    }
    if (animSequentially.statusListener != null) {
      animSequentially.statusListener(AnimAnimationStatus.started);
    }
    for (var animatable in animatables) {
      await animatable.play();
    }
    if (animSequentially.statusListener != null) {
      animSequentially.statusListener(AnimAnimationStatus.finished);
    }
  }

  @override
  void dispose() {
    for (var animatable in animatables) {
      animatable.dispose();
    }
  }
}
