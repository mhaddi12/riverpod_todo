import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius; // controls roundness
  final EdgeInsets padding;
  final double fontSize;
  final FontWeight fontWeight;
  final String? buttonImage;
  final IconData? icon;
  final double elevation;
  final double? width;
  final double? height;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets borderPadding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 4.0, // ✅ less round (default reduced from 12 → 4)
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.buttonImage,
    this.icon,
    this.elevation = 2.0,
    this.width,
    this.height,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1.0,
    this.borderPadding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: borderPadding,
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: elevation,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: borderColor, width: borderWidth),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (buttonImage != null && buttonImage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(buttonImage!, height: fontSize + 6),
                ),
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icon, size: fontSize + 4, color: textColor),
                ),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
