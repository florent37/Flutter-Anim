import 'package:anim/anim.dart';
import 'package:anim_example/my_circle_avatar.dart';
import 'package:flutter/material.dart';

class Example2 extends StatefulWidget {
  _Example2State createState() => _Example2State();
}

class _Example2State extends State<Example2> with TickerProviderStateMixin {
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
        repeatCount: 3,
        listener: () {
          setState(() {
            /* rebuild */
          });
        },
        /* Define initial values, used when the animation has not been launched */
        initiaValues: {
          "alpha": 1,
          "size": 100,
        },
        animations: [
          AnimSequentially(
              startDelay: const Duration(milliseconds: 400),
              anims: [

                //Animate the alpha, then the size
                AnimValues(
                  name: "alpha",
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 800),
                  values: [1, 0.4, 0.8, 0.5],
                ),
                AnimValues(
                  name: "size",
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 800),
                  values: [100, 140, 80],
                ),

                //and finally animate those two values together
                AnimTogether(anims: [
                  AnimValues(
                    name: "alpha",
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 800),
                    values: [0.5, 1],
                  ),
                  AnimValues(
                    name: "size",
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 800),
                    values: [80, 100],
                  ),
                ])
              ]),
        ]);
  }

  Widget _yourView() {
    return MyCircleAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: Opacity(
            opacity: this.anim["alpha"],
            child: SizedBox(
              height: this.anim["size"],
              width: this.anim["size"],
              child: _yourView(),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: RaisedButton(
            onPressed: () {
              _startAnim();
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

  void _startAnim() async {
    await anim.start();
    print("finished");
  }

}
