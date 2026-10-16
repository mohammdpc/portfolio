import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const String _font = "JetBrains_Mono";
  static const TextStyle title = TextStyle(
    fontFamily: _font,
    fontSize: 70,
    fontWeight: FontWeight.w700,
    color: AppColors.mainText,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _font,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.mainText,
  );
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.mainText,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.secondaryText,
  );
  static final TextStyle bodyDisabled = body.copyWith(color: AppColors.disabled);
  static final TextStyle bodySecondary = body.copyWith(color: AppColors.secondaryText,);
  static final TextStyle bodyAccent = body.copyWith(color: AppColors.accent);

  static const TextStyle label = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
  );
  static final TextStyle labelSecondary = label.copyWith(color: AppColors.secondaryText,);
  static final TextStyle labelAccent2 = label.copyWith(color: AppColors.accent2,);

}
