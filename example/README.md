# anim_example

Demonstrates how to use the anim plugin.

# Initialize your Anim

```Dart
this.anim1 = Anim(
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
```

# Bind with your widget

```Dart
Widget buildAvatarName() {
    return Transform.translate(
      offset: Offset(0, anim1["text.translationY"]),
      child: Opacity(
        opacity: this.anim["text.alpha"],
        child: Text("Avatar",
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
      scale: this.anim["round.scale"],
      child: Transform.rotate(
        angle: this.anim["round.rotation"],
        child: SizedBox(
          height: this.anim["round.size"],
          width: this.anim["round.size"],
          child: CircleAvatar(),
        ),
      ),
    );
  }
```

# 3. Start !

```Dart
this.anim.start();
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
