import 'package:flutter/material.dart';

class AppUtils {
  static const double targetHeight = 160;
  static const double targetWidth = 90;

  static double screenWidth()=>WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  static double screenHeight()=>WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
  static double getHeight(double height)=>screenHeight()*(height/targetHeight);
  static double getWidth(double width)=>screenWidth()*(width/targetWidth);
}