# anim

Fluent Flutter Animation library. Describe Sequences & Parallel animation's workflow, setup startDelay, duration and curve, then run !

# Describe the Anim

Anim contains 3 major classes : `AnimValues`, `AnimSequentially` and `AnimTogether`.

## Animation
```Dart
AnimValues(
    name:"animationName", 
    values: [value0, value1, value2, ...],
    duration: Duration(seconds: 1),
);
```

## Animation schedulers

`AnimSequentially();` to play one after the other animations
`AnimTogether();` to play in parallel animations

```Dart
AnimSequentially(anims: [
    anim1, anim2, anim3
]);
AnimTogether(anims: [
    anim1, anim2, anim3
]);
```

# Example

[![sample1](https://raw.githubusercontent.com/florent37/Flutter-Anim/master/example/medias/sample1.gif)](https://github.com/florent37/Flutter-Anim)

```Dart
this.anim = Anim(
        vsync: this,
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
```

# Bind your Anim

```Dart
@override
Widget build(BuildContext context) {
  return Opacity(
      opacity: this.anim["alpha"],
      child: SizedBox(
          height: this.anim["size"],
          width: this.anim["size"]
          child: _yourView(),
      ),
    );
  }
}
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
