import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_styles.dart';

class SkillWindow extends StatelessWidget {
  const SkillWindow({super.key,});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      width: size.width * 0.25,
      height: size.height * 0.33,
      decoration: BoxDecoration(
        color: AppColors.fill.withAlpha(150),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border, width: 2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Container(
            width: size.width,
            color: AppColors.fill,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.keyboard_control,
                  color: AppColors.disabled,
                  size: 24,
                ),
                Text(
                  "~/flutter_portfolio",
                  style: AppStyles.bodyDisabled,
                ),
                SizedBox(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text.rich(
                  TextSpan(
                    text: r"$",
                    style: AppStyles.bodyAccent,
                    children: [
                      const TextSpan(text: "Developer -i", style: AppStyles.body),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: r"> platforms ",
                    style: AppStyles.bodySecondary,
                    children: [
                      TextSpan(
                        text: "android · web · windows · linux",
                        style: AppStyles.label,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: r"> arch      ",
                    style: AppStyles.labelSecondary,
                    children: [
                      TextSpan(
                        text: "clean · mvvm · repository",
                        style: AppStyles.label,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: r"> state     ",
                    style: AppStyles.labelSecondary,
                    children: [
                      TextSpan(
                        text: "bloc · cubit · provider",
                        style: AppStyles.label,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: r"> backend   ",
                    style: AppStyles.labelSecondary,
                    children: [
                      TextSpan(
                        text: "Firebase · Supabase",
                        style: AppStyles.label,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: r"> status    ",
                    style: AppStyles.labelSecondary,
                    children: [
                      TextSpan(
                        text: "Open To Work",
                        style: AppStyles.labelAccent2,
                      ),
                    ],
                  ),
                ),
                Text(
                  r"$ █",
                  style: AppStyles.bodyAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
