import 'package:anim/anim.dart';
import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';
export 'package:flutter/animation.dart';

import 'dart:async';
export 'dart:async';

/// `AnimAnimatable` real animations, capable of running
/// Contains a startDelay
/// Can be reseted or disposed
abstract class AnimAnimatable {
  final Duration startDelay;
  final Duration duration;

  AnimAnimatable({
    @required this.startDelay,
    @required this.duration,
  });

  Duration get totalDuration => startDelay + duration;

  /// Starts the animation
  Future<AnimAnimatable> play();

  /// Dispose the current animation
  /// Will not be be able to start again
  void dispose();

  /// Cancel the current animation
  /// The animation will be reseted, you can now use `start()`
  void reset();
}

/// Computed animation of `AnimValues`
class SimpleAnimatable extends AnimAnimatable {
  AnimationController animationController;
  final AnimValues animValues;
  Animation animation;

  SimpleAnimatable({
    @required AnimValueSetter animValueSetter,
    @required this.animValues,
  }) : super(
          startDelay: animValues.startDelay,
          duration: animValues.duration,
        ) {
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
  void reset() {
    this.animationController.reset();
  }

  @override
  Future<AnimAnimatable> play() async {
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

    return this;
  }
}

Duration _computeDuration(List<AnimAnimatable> animatables) {
  Duration totalDuration = Duration();
  for (var animatable in animatables) {
    totalDuration += animatable.duration;
  }
  return totalDuration;
}

/// Computed animation of `AnimTogether`
class TogetherAnimatable extends AnimAnimatable {
  final List<AnimAnimatable> animatables;
  final AnimTogether animTogether;

  TogetherAnimatable({
    this.animatables,
    Duration startDelay,
    this.animTogether,
  }) : super(startDelay: startDelay, duration: _computeDuration(animatables));

  @override
  Future<AnimAnimatable> play() async {
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

    return this;
  }

  @override
  void dispose() {
    for (var animatable in animatables) {
      animatable.dispose();
    }
  }

  @override
  void reset() {
    for (var animatable in animatables) {
      animatable.reset();
    }
  }
}

/// Computed animation of `AnimSequentially`
class ChainAnimatable extends AnimAnimatable {
  final List<AnimAnimatable> animatables;
  final AnimSequentially animSequentially;

  ChainAnimatable({
    this.animatables,
    this.animSequentially,
    Duration startDelay,
  }) : super(
          startDelay: startDelay,
          duration: _computeDuration(animatables),
        );

  @override
  Future<AnimAnimatable> play() async {
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

    return this;
  }

  @override
  void dispose() {
    for (var animatable in animatables) {
      animatable.dispose();
    }
  }

  @override
  void reset() {
    for (var animatable in animatables) {
      animatable.reset();
    }
  }
}
