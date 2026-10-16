import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_consts.dart';
import 'package:portfolio/core/app_styles.dart';
import 'package:portfolio/core/app_utils.dart';

import 'package:portfolio/widgets/intro_card.dart';

class HomeScreenDesktop extends StatelessWidget {
  final ui.Image asciiChars;
  final AppBar appBar = AppBar(
    backgroundColor: AppColors.fill.withAlpha(200),
    title: Text(">Mohammed_Ayman",style: AppStyles.cardTitle,),
    elevation: 2.0,

  );
  HomeScreenDesktop({super.key,required this.asciiChars});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          IntroCard(asciiChars: asciiChars,appBarHeight: appBar.preferredSize.height,),
        ],
      ),
    );
  }
}
