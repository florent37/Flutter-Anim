import 'dart:math';

import 'package:flutter/material.dart';
import 'package:anim/anim.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

num degToRad(num deg) => deg * (pi / 180.0);
num radToDeg(num rad) => rad * (180.0 / pi);

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  Anim anim1;

  @override
  void initState() {
    super.initState();
    createAnim();
  }

  void createAnim() {
    anim1 = Anim(
      vsync: this,
      listener: () {
        setState(() {
          /* rebuild */
        });
      },
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
            AnimTogether(anims: [
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
            ]),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    anim1?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: Opacity(
                opacity: anim1["round.alpha"],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Transform.scale(
                        scale: anim1["round.scale"],
                        child: Transform.rotate(
                          angle: anim1["round.rotation"],
                          child: SizedBox(
                            height: anim1["round.size"],
                            width: anim1["round.size"],
                            child: Material(
                              elevation: 4.0,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                "assets/avatar.jpg",
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        )),
                    Transform.translate(
                      offset: Offset(0, anim1["text.translationY"]),
                      child: Opacity(
                        opacity: anim1["text.alpha"],
                        child: Text("Avatar",
                            style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: RaisedButton(
                onPressed: () {
                  //createAnim();
                  anim1.start();
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
        ),
      ),
    );
  }
}
