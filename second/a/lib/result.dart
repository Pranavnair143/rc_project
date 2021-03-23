import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  final int score;
  final Function resetHandler;
  String get resultPhrase {
    String result;
    if (score <= 0) {
      result = 'Tumse naa ho paega';
    } else if (score <= 2) {
      result = 'Binod!';
    } else if (score <= 4) {
      result = 'Heavy Driver';
    }
    return result;
  }

  Result(this.score, this.resetHandler);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        resultPhrase,
        style: TextStyle(fontSize: 30),
      ),
      TextButton(onPressed: resetHandler, child: Text('Reset the Quiz'))
    ]);
  }
}
