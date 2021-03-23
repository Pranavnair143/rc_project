import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  final int score;
  final Function resetFunc;
  Result(this.score, this.resetFunc);
  String resultPhrase(int score) {
    var rp;
    if (score <= 0) {
      rp = 'Dumb';
    } else if (score <= 2) {
      rp = 'Can do better';
    } else if (score <= 4) {
      rp = 'Excellent';
    }
    return rp;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(resultPhrase(score)),
      TextButton(
        child: Text('Reset Quiz', style: TextStyle(color: Colors.red)),
        onPressed: resetFunc,
      )
    ]);
  }
}
