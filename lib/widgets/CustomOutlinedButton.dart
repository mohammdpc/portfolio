import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_styles.dart';

class CustomOutlinedButton extends StatefulWidget {
  final String text;
  final Color background;
  final Color borderColor;
  final Color textColor;
  final double borderThickness;
  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.background = Colors.transparent,
    this.borderColor = AppColors.accent,
    required this.textColor,
    this.borderThickness = 1.0,
  });

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onHover: (state){
        setState(() {
          focused = state;
        });
      },
      onPressed: () {
        //todo
      },
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(16)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(16)),
            side: BorderSide(color: widget.borderColor, width: widget.borderThickness),
          ),
        ),
        surfaceTintColor: WidgetStatePropertyAll(widget.textColor),
        overlayColor: WidgetStatePropertyAll(widget.textColor),
        backgroundColor: WidgetStatePropertyAll(widget.background)
      ),
      child: Text(
        widget.text,
        style: AppStyles.cardTitle.copyWith(color: focused?widget.background:widget.textColor),
      ),
    );
  }
}
