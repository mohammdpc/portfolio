import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_styles.dart';
import 'package:portfolio/widgets/CustomOutlinedButton.dart';
import 'package:portfolio/widgets/skill_window.dart';
import '../backGround/perlin_noise.dart';

class IntroCard extends StatefulWidget {
  final ui.Image asciiChars;
  final double appBarHeight;
  const IntroCard({
    super.key,
    required this.asciiChars,
    required this.appBarHeight,
  });

  @override
  State<IntroCard> createState() => _IntroCardState();
}

class _IntroCardState extends State<IntroCard>
    with SingleTickerProviderStateMixin {
  late Future<ui.FragmentShader?> shader;
  late final Ticker _ticker;

  double _time = 0;
  @override
  void initState() {
    _ticker = createTicker((elapsed) {
      setState(() => _time = elapsed.inMilliseconds / 1000.0);
    })..start();
    assignShader();
    super.initState();
  }

  Future<ui.FragmentShader> _loadShader() async {
    // Load and compile the registered fragment program
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/ascii_perlin_nois.frag',
    );
    return program.fragmentShader();
  }

  void assignShader() async {
    shader = _loadShader();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.FragmentShader?>(
      future: shader,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Stack(
              children: [
                SizeChangedLayoutNotifier(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PerlinNoise(
                      snapshot.data!,
                      _time,
                      MediaQuery.devicePixelRatioOf(context),
                      widget.asciiChars,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.backGround],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.centerLeft,
                        colors: [Colors.transparent, AppColors.backGround],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(
                    top: widget.appBarHeight * 2,
                    bottom: widget.appBarHeight * 2,
                    left: widget.appBarHeight * 2,
                    right: widget.appBarHeight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("// flutter developer", style: AppStyles.label),
                          Text("Mohammed Ayman", style: AppStyles.title),
                          Text(
                            """Cross-platform apps,\nbuilt to run fast.""",
                            style: AppStyles.title,
                          ),
                          Text(
                            "Flutter developer building cross-platform apps in Dart, tested on\nAndroid, Web, Windows and Linux. Clean architecture, backend\nintegration, authentication and localization. Now focused on\nmobile security and memory optimization.",
                            style: AppStyles.body,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: MediaQuery.of(context).size.width * .01,
                            children: [
                              CustomOutlinedButton(
                                text: "View projects ->",
                                textColor: AppColors.fill,
                                background: AppColors.accent,
                              ),
                              CustomOutlinedButton(
                                text: "Github",
                                textColor: AppColors.accent,
                                background: AppColors.fill.withAlpha(100),
                                borderThickness: 1.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SkillWindow(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
          );
        }
      },
    );
  }
}
