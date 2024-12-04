import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.width,
      required this.height,
      required this.text,
      required this.bgColor,
      required this.textColor,
      required this.onPressed,
      required this.isLoading});

  final double width;
  final double height;
  final String text;
  final Function onPressed;
  final bool isLoading;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? CupertinoActivityIndicator(
                radius: 10,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : Text(text,
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
