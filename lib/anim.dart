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
typedef AnimRepeatListener = void Function(int current);

class Anim {
  final TickerProvider vsync;
  final Map<String, double> _initialValues = Map<String, double>();
  final Map<String, double> _currentValues = Map<String, double>();
  AnimAnimatable _animatable;
  AnimListener listener;
  AnimationStatusListener statusListener;
  AnimRepeatListener repeatListener;
  double repeatCount;

  double operator [](String key) {
    return _currentValues[key];
  }

  bool running = false;

  Anim({
    @required this.vsync,
    @required this.listener,
    List<AnimAnimation> animations,
    Map<String, double> initiaValues,
    this.repeatCount = 1,
    this.statusListener,
    this.repeatListener,
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

  Future<Anim> start() async {
    if (!running) {
      running = true;
      if(statusListener != null){
        statusListener(AnimAnimationStatus.started);
      }
      await _start(this.repeatCount);
      if(statusListener != null){
        statusListener(AnimAnimationStatus.finished);
      }
      running = false;
    } else {
      //TODO
    }
    return this;
  }

  Future<Anim> _start(double repeatLeft) async {
    if (repeatLeft > 0) {
      _resetToInitialValues();
      await _animatable.play();
      return _start(repeatLeft - 1);
    } else {
      return this;
    }
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
