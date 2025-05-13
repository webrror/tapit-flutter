
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class CommonGradientTextButton extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight = FontWeight.bold;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  const CommonGradientTextButton({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.gradientColors = const [Colors.deepOrangeAccent, Colors.indigoAccent],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: GradientText(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        colors: gradientColors,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
