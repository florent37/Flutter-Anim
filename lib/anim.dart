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

/// Listener that will be pinged when the widget has to be re-build
///
///     this.anim = Anim(
///         vsync: this,
///         listener: () {
///             setState(() {
///               /* rebuild */
///             });
///         },
typedef AnimListener = void Function();

/// Called when the anim re-start again
///     this.anim = Anim(
///         vsync: this,
///         repeatCount: 3,
///         repeatListener: (current) {
///
///         },
typedef AnimRepeatListener = void Function(int current);

/// The main class of the library, Anim is the root object of the animation delcaration
/// It will contains & compute the animations, handle repeatcount & listeners
///
/// Don't forget to define `initiaValues` (used when the animation has not been launched)
///
///     # Example
///     this.anim = Anim(
///          vsync: this,
///          repeatCount: 3,
///          listener: () {
///            setState(() {
///              /* rebuild */
///            });
///          },
///          initiaValues: {
///            "alpha": 1,
///            "size": 100,
///          },
///          animations: [...] <-- AnimValues, AnimSequentially or AnimTogether
///      );
///
class Anim {
  final TickerProvider vsync;
  final Map<String, double> _initialValues = Map<String, double>();
  final Map<String, double> _currentValues = Map<String, double>();

  /// The resolved animation, using AnimationResolver
  AnimAnimatable _animatable;
  final AnimListener listener;
  final AnimAnimationStatusListener statusListener;
  final AnimRepeatListener repeatListener;
  final int repeatCount;

  /// Access to an animated value of this Anim
  ///
  ///     child: Opacity(
  ///         opacity: this.anim["alpha"],
  ///
  double operator [](String key) {
    return _currentValues[key];
  }

  /// Boolean representing the running state of this Anim
  bool running = false;

  /// Construct an anim
  ///
  ///
  /// Don't forget to define `initiaValues` (used when the animation has not been launched)
  ///
  ///     # Example
  ///     this.anim = Anim(
  ///          vsync: this,
  ///          listener: () {
  ///            setState(() {
  ///              /* rebuild */
  ///            });
  ///          },
  ///          initiaValues: {
  ///            "alpha": 1,
  ///            "size": 100,
  ///          },
  ///          animations: [...] <-- AnimValues, AnimSequentially or AnimTogether
  ///      );
  ///
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

    /// resolve the animation, using AnimationResolver
    final AnimationResolver _animationResolver =
        AnimationResolver._(AnimValueSetter._(this), animations);
    _animatable = _animationResolver.resolve();
  }

  void _resetToInitialValues() {
    _currentValues.addAll(_initialValues);
  }

  /// Start the Anim
  /// Will ping it `listener` when the animated values changes
  ///
  ///     this.anim = Anim(
  ///          vsync: this,
  ///          repeatCount: 3,
  ///          listener: () {
  ///            setState(() {
  ///              /* rebuild */
  ///            });
  ///          },
  ///
  /// The future will be pinged when the animation finished (at the end of the last repeat loop)
  ///
  ///     void _startAnim() async {
  ///         await anim.start();
  ///         print("finished");
  ///     }
  ///
  /// The statusListener will be called with `AnimAnimationStatus.started` at the start of the anim, then on the end with `AnimAnimationStatus.finished`
  ///
  Future<Anim> start() async {
    if (!running) {
      running = true;
      if (statusListener != null) {
        statusListener(AnimAnimationStatus.started);
      }
      await _start(this.repeatCount);
      if (statusListener != null) {
        statusListener(AnimAnimationStatus.finished);
      }
      running = false;
    } else {
      reset();
      return start();
    }
    return this;
  }

  /// Recursively fire the animation until repeatLeft is `== 0`
  Future<Anim> _start(int repeatLeft) async {
    if (repeatLeft > 0) {
      _resetToInitialValues();
      if (this.repeatListener != null) {
        repeatListener(repeatLeft);
      }
      await _animatable.play();
      return _start(repeatLeft - 1);
    } else {
      return this;
    }
  }

  /// Cancel the current animation
  /// The animation will be reseted, you can now use `start()`
  void reset() {
    _animatable.reset();
    running = false;
  }

  /// Dispose the current animation
  /// Will not be be able to start again
  void dispose() {
    _animatable.dispose();
  }
}

/// Setter given to the `Animatables`, capable of update an animated value of the `Anim`
class AnimValueSetter {
  Anim anim;
  AnimValueSetter._(this.anim);

  /// Update an animated value of the `Anim`
  void setValue(String name, double value) {
    this.anim._currentValues[name] = value;
    this.anim.listener();
  }
}

/// Resolver of the animations, transform `AnimAnimation` into `AnimAnimatable` (real animations, capable of running)
class AnimationResolver {
  final AnimValueSetter animValueSetter;
  List<AnimAnimation> animations;

  AnimationResolver._(this.animValueSetter, this.animations);

  /// Resolver of the animations, transform `AnimAnimation` into `AnimAnimatable` (real animations, capable of running)
  AnimAnimatable resolve() {
    return resolveCurrent(AnimTogether(anims: this.animations));
  }

  AnimAnimatable resolveCurrent(AnimAnimation current) {
    //AnimSequentially

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
    }

    //AnimTogether
    else if (current is AnimTogether) {
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
    }

    //Simple animation
    else if (current is AnimValues) {
      final AnimValues animation = current;
      return SimpleAnimatable(
        animValueSetter: this.animValueSetter,
        animValues: animation,
      );
    }
    return null;
  }
}
