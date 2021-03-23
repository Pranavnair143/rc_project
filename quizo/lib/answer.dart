import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final Function score;
  final String option;
  Answer(this.score, this.option);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ElevatedButton(
          child: Text(option),
          style: ElevatedButton.styleFrom(primary: Colors.blue),
          onPressed: score,
        ),
        width: double.infinity);
  }
}
