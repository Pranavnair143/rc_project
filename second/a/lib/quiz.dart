import 'package:flutter/material.dart';
import './answer.dart';
import './question.dart';

class Quiz extends StatelessWidget {
  final List<Map<String, Object>> questions;
  final int qno;
  final Function answerQ;

  Quiz(this.questions, this.qno, this.answerQ);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Question(
          questions[qno]['questionsText'],
        ),
        ...(questions[qno]['answers'] as List<Map<String, Object>>)
            .map((answer) {
          return Answer(() => answerQ(answer['score']), answer['text']);
        }).toList(),
      ],
    );
  }
}
