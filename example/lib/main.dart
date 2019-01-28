
import 'package:anim_example/example1.dart';
import 'package:anim_example/example2.dart';
import 'package:flutter/material.dart';
import 'package:anim/anim.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Example2()
      ),
    );
  }
}