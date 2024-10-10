import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Function()? onPressed;
  // final Color color;
  final String text;

  ActionButton({this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        // : color ?? Colors.green,
        // shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(6.0),
        //     side: BorderSide(color: color ?? Colors.green)),
      ),
      padding: EdgeInsets.all(10.0),
    );
  }
}
