import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:portfolio/screens/home/home_screen_desktop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await rootBundle.load("assets/bitmap/ascii chars.png");
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  runApp(MyApp(asciiChars: frame.image));
}

class MyApp extends StatelessWidget {
  final ui.Image asciiChars;
  const MyApp({super.key, required this.asciiChars});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mohammed ayman Portfolio',
      theme: ThemeData(fontFamily: "vt323"),
      home:  HomeScreenDesktop(asciiChars: asciiChars,),
    );
  }
}