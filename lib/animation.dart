import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';
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

/// Describe an animation
///
///     AnimValues(
///           name: "alpha",
///           curve: Curves.easeIn,
///           duration: const Duration(milliseconds: 800),
///           values: [0.5, 1],
///        ),
///
class AnimValues extends AnimAnimation {
  final String name;
  final Curve curve;
  final AnimAnimationListener listener;
  final Duration duration;
  final List<double> values;

  AnimValues({
    @required this.name,
    @required this.values,
    this.listener,
    AnimAnimationStatusListener statusListener,
    this.curve = Anim_DEFAULT_CURVE,
    this.duration = Anim_DEFAULT_DURATION,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay, statusListener: statusListener);

  AnimValues.tween({
    this.name,
    @required double start,
    @required double end,
    this.listener,
    AnimAnimationStatusListener statusListener,
    this.curve = Anim_DEFAULT_CURVE,
    this.duration = Anim_DEFAULT_DURATION,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  })  : this.values = [start, end],
        super(startDelay: startDelay, statusListener: statusListener);
}

/// Describe an animation grou^ that will run all child animations in parallel,
/// starts all animations at the same time, then finish when all child animation finished
class AnimTogether extends AnimAnimation {
  final List<AnimAnimation> anims;
  AnimTogether({
    this.anims,
    AnimAnimationStatusListener statusListener,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay, statusListener: statusListener);
}

/// Describe an animation group that will run child animations sequentially,
/// starts the second animation when the previous has finished, and so on
class AnimSequentially extends AnimAnimation {
  final List<AnimAnimation> anims;

  AnimSequentially({
    this.anims,
    AnimAnimationStatusListener statusListener,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay, statusListener: statusListener);
}
