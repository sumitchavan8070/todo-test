import 'package:flutter/material.dart';

class AppBoxDecoration {
  static BoxDecoration getBoxDecoration({
    double borderRadius = 10,
    Color color = Colors.white,
    double spreadRadius = 0,
    double blurRadius = 10,
    Color shadowColor = const Color(0x1A000000),
    bool showShadow = true,
    double offsetX = 0,
    double offsetY = 4,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: color,
      boxShadow: [
        if (showShadow)
          BoxShadow(
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            color: shadowColor,
            offset: Offset(offsetX, offsetY),
          ),
      ],
    );
  }

  static BoxDecoration getBorderBoxDecoration({
    double borderRadius = 10,
    Color color = Colors.white,
    double spreadRadius = 0,
    double blurRadius = 10,
    Color shadowColor =  const Color(0x1A000000),
    Color borderColor = const Color(0x66000000),
    bool showShadow = true,
    double offsetX = 0,
    double offsetY = 4,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: color,
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        if (showShadow)
          BoxShadow(
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            color: shadowColor,
            offset: Offset(offsetX, offsetY),
          ),
      ],
    );
  }

  static BoxDecoration customBoxDecoration({
    double borderRadius = 12,
    Color color = Colors.white,
    double spreadRadius = 0,
    double blurRadius = 20,
    Color shadowColor = const  Color(0x66000000),
    double offsetX = 0,
    double offsetY = 4,
    BoxShape? boxShape,
    ImageProvider? image,
    showShadow = true,
  }) {
    return BoxDecoration(
      borderRadius: boxShape == null ? BorderRadius.circular(borderRadius) : null,
      shape: boxShape ?? BoxShape.rectangle,
      color: color,
      image: image != null ? DecorationImage(image: image) : null,
      boxShadow: [
        if (showShadow)
          BoxShadow(
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            color: shadowColor,
            offset: Offset(offsetX, offsetY),
          ),
      ],
    );
  }
}
