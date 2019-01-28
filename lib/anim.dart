import 'dart:async';
export 'dart:async';

import 'package:anim/animatable.dart';
export 'package:anim/animatable.dart';

import 'package:anim/animation.dart';
export 'package:anim/animation.dart';

import 'package:flutter/scheduler.dart';
export 'package:flutter/scheduler.dart';

import 'package:meta/meta.dart';
export 'package:meta/meta.dart';

export 'package:flutter/animation.dart';

typedef AnimListener = void Function();

class Anim {
  final TickerProvider vsync;
  final Map<String, double> _initialValues = Map<String, double>();
  final Map<String, double> _currentValues = Map<String, double>();
  AnimAnimatable _animatable;
  AnimListener listener;

  double operator [](String key) {
    return _currentValues[key];
  }

  Anim({
    @required this.vsync,
    @required this.listener,
    List<AnimAnimation> animations,
    Map<String, double> initiaValues,
  }) {
    this._initialValues.addAll(initiaValues);
    _resetToInitialValues();

    final AnimationResolver _animationResolver =
        AnimationResolver(AnimValueSetter._(this), animations);
    _animatable = _animationResolver.resolve();
  }

  void _resetToInitialValues() {
    _currentValues.addAll(_initialValues);
  }

/*
  static AnimTogether together({
    @required List<AnimAnimation> anims,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) {
    return AnimTogether(
      anims: anims,
      startDelay: startDelay,
    );
  }

  static AnimSequentially sequentially({
    @required List<AnimAnimation> anims,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) {
    return AnimSequentially(
      anims: anims,
      startDelay: startDelay,
    );
  }

  static AnimValues values({
    @required String name,
    @required List<double> values,
    Curve curve = Anim_DEFAULT_CURVE,
    Duration duration = Anim_DEFAULT_DURATION,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) {
    return AnimValues(
      name: name,
      values: values,
      curve: curve,
      duration: duration,
      startDelay: startDelay,
    );
  }

  static AnimAnimation tween({
    @required String name,
    @required double start,
    @required double end,
    Curve curve = Anim_DEFAULT_CURVE,
    Duration duration = Anim_DEFAULT_DURATION,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) {
    return values(
        name: name,
        values: [start, end],
        duration: duration,
        curve: curve,
        startDelay: startDelay);
  }
*/

  Future<void> start() async {
    _resetToInitialValues();
    return await _animatable.play();
  }

  void dispose() {
    _animatable.dispose();
  }
}

class AnimValueSetter {
  Anim anim;
  AnimValueSetter._(this.anim);

  void setValue(String name, double value) {
    this.anim._currentValues[name] = value;
    this.anim.listener();
  }
}

class AnimationResolver {
  final AnimValueSetter animValueSetter;
  List<AnimAnimation> animations;

  AnimationResolver(this.animValueSetter, this.animations);

  AnimAnimatable resolve() {
    return resolveCurrent(AnimTogether(anims: this.animations));
  }

  AnimAnimatable resolveCurrent(AnimAnimation current) {
    if (current is AnimSequentially) {
      final AnimSequentially animation = current;
      final List<AnimAnimatable> childAnimatables = List<AnimAnimatable>();
      for (var childs in animation.anims) {
        childAnimatables.add(resolveCurrent(childs));
      }
      return ChainAnimatable(
        animSequentially: animation,
        animatables: childAnimatables,
        startDelay: animation.startDelay,
      );
    } else if (current is AnimTogether) {
      final AnimTogether animation = current;
      final List<AnimAnimatable> childAnimatables = List<AnimAnimatable>();
      for (var childs in animation.anims) {
        childAnimatables.add(resolveCurrent(childs));
      }
      return TogetherAnimatable(
        animTogether: animation,
        animatables: childAnimatables,
        startDelay: animation.startDelay,
      );
    } else if (current is AnimValues) {
      final AnimValues animation = current;
      return SimpleAnimatable(
        animValueSetter: this.animValueSetter,
        animValues: animation,
      );
    }
    return null;
  }
}
