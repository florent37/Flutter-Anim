
import 'package:flutter/animation.dart';
export 'package:flutter/animation.dart';

const Anim_DEFAULT_DURATION = const Duration(milliseconds: 500);
const Anim_DEFAULT_START_DELAY = const Duration();
const Anim_DEFAULT_CURVE = Curves.linear;

class AnimAnimation {
  final Duration startDelay;
  AnimAnimation({
    this.startDelay,
  });
}

class AnimValues extends AnimAnimation {
  final String name;
  final Curve curve;
  final Duration duration;
  final List<double> values;
  AnimValues({
    this.name,
    this.values,
    this.curve = Anim_DEFAULT_CURVE,
    this.duration = Anim_DEFAULT_DURATION,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay);
}

class AnimTogether extends AnimAnimation {
  final List<AnimAnimation> anims;
  AnimTogether({
    this.anims,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay);
}

class AnimSequentially extends AnimAnimation {
  final List<AnimAnimation> anims;

  AnimSequentially({
    this.anims,
    Duration startDelay = Anim_DEFAULT_START_DELAY,
  }) : super(startDelay: startDelay);
}
