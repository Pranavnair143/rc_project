import 'package:flutter/material.dart';
import './answer.dart';
import './question.dart';

class Quiz extends StatelessWidget {
  final List<Map<String, Object>> question;
  final int _qno;
  final Function ansFunc;

  Quiz(this.question, this._qno, this.ansFunc);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Question(question[_qno]['questionsText']),
        ...(question[_qno]['answers'] as List<Map<String, Object>>)
            .map((answers) {
          return Answer(() => ansFunc(answers['score']), answers['text']);
        }).toList(),
      ],
    );
  }
}
