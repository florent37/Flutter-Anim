import 'package:anim/anim.dart';
import 'package:anim_example/math_rad.dart';
import 'package:anim_example/my_circle_avatar.dart';
import 'package:flutter/material.dart';

class Example1 extends StatefulWidget {
  _Example1State createState() => _Example1State();
}

class _Example1State extends State<Example1> with TickerProviderStateMixin {
  Anim anim;

  @override
  void initState() {
    super.initState();
    createAnim();
  }

  @override
  void dispose() {
    anim?.dispose();
    super.dispose();
  }

  void createAnim() {
    this.anim = Anim(
      vsync: this,
      listener: () {
        setState(() {
          /* rebuild */
        });
      },
      /* Define initial values, used when the animation has not been launched */
      initiaValues: {
        "text.alpha": 0,
        "text.translationY": -20,
        "round.alpha": 0,
        "round.scale": 1,
        "round.rotation": 0,
        "round.size": 0,
      },
      animations: [
        AnimSequentially(
          anims: [
            AnimTogether(
              anims: [
                AnimValues(
                  name: "round.alpha",
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 500),
                  values: [0, 1],
                ),
                AnimValues(
                  name: "round.size",
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 800),
                  values: [0, 140, 100],
                ),
              ],
            ),
            AnimTogether(
              anims: [
                AnimValues(
                  name: "text.alpha",
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 1000),
                  values: [0, 1],
                ),
                AnimValues(
                  name: "text.translationY",
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 800),
                  values: [-20, 5, -5, 0],
                ),
              ],
            ),
            AnimTogether(
              anims: [
                AnimValues(
                  name: "round.rotation",
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 600),
                  values: [0, degToRad(-10), degToRad(10), 0],
                ),
                AnimValues(
                  name: "round.scale",
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 400),
                  values: [1, 1.3, 1],
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget buildAvatarName() {
    return Transform.translate(
      offset: Offset(0, anim["text.translationY"]),
      child: Opacity(
        opacity: anim["text.alpha"],
        child: Text(
          "Avatar",
          style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget buildAvatar() {
    return Transform.scale(
      scale: anim["round.scale"],
      child: Transform.rotate(
        angle: anim["round.rotation"],
        child: SizedBox(
          height: anim["round.size"],
          width: anim["round.size"],
          child: MyCircleAvatar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: Opacity(
            opacity: anim["round.alpha"],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildAvatar(),
                buildAvatarName(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: RaisedButton(
            onPressed: () {
              //createAnim();
              anim.start();
            },
            child: Text(
              "Animate",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        )
      ],
    );
  }
}
