import 'package:flutter/animation.dart';
export 'package:flutter/animation.dart';

const Anim_DEFAULT_DURATION = const Duration(milliseconds: 500);
const Anim_DEFAULT_START_DELAY = const Duration();
const Anim_DEFAULT_CURVE = Curves.linear;

/// The status of an animation
enum AnimAnimationStatus {
  /// The animation is running from beginning to end
  started,

  /// The animation is stopped at the end
  finished,
}
typedef AnimAnimationListener = void Function(double value);
typedef AnimAnimationStatusListener = void Function(AnimAnimationStatus status);

class AnimAnimation {
  final Duration startDelay;
  final AnimAnimationStatusListener statusListener;

  AnimAnimation({
    this.startDelay,
    this.statusListener,
  });
}

class AnimValues extends AnimAnimation {
  final String name;
  final Curve curve;
  final AnimAnimationListener listener;
  final Duration duration;
  final List<double> values;
  AnimValues({
    this.name,
    this.values,
    this.listener,
    AnimAnimationStatusListener statusListener,
    this.curve = Anim_DEFAULT_CURVE,
    this.duration = Anim_DEFAULT_DURATION,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay, statusListener: statusListener);
}

class AnimTogether extends AnimAnimation {
  final List<AnimAnimation> anims;
  AnimTogether({
    this.anims,
    AnimAnimationStatusListener statusListener,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay, statusListener: statusListener);
}

class AnimSequentially extends AnimAnimation {
  final List<AnimAnimation> anims;

  AnimSequentially({
    this.anims,
    AnimAnimationStatusListener statusListener,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay, statusListener: statusListener);
}
