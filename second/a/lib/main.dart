import 'package:flutter/material.dart';
import './result.dart';
import './quiz.dart';

//void main() {
//  runApp(MyApp());
//}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State {
  var _qno = 0;
  var _totalScore = 0;
  void _answerQ(int score) {
    _totalScore += score;
    setState(() {
      _qno = _qno + 1;
    });
    print(_qno);
  }

  void _resetQ() {
    setState(() {
      _totalScore = 0;
      _qno = 0;
    });
  }

  Widget build(BuildContext context) {
    var _questions = [
      {
        'questionsText': 'What is your favourite color??',
        'answers': [
          {'text': 'Blue', 'score': 1},
          {'text': 'Orange', 'score': -1},
          {'text': 'Red', 'score': -1},
          {'text': 'Yellow', 'score': -1},
        ]
      },
      {
        'questionsText': 'What is your favourite food??',
        'answers': [
          {'text': 'A', 'score': -1},
          {'text': 'B', 'score': 1},
          {'text': 'C', 'score': -1},
          {'text': 'D', 'score': -1},
        ]
      },
      {
        'questionsText': 'What is your favourite film??',
        'answers': [
          {'text': 'K', 'score': -1},
          {'text': 'L', 'score': -1},
          {'text': 'M', 'score': -1},
          {'text': 'N', 'score': 1},
        ]
      },
      {
        'questionsText': 'What is your favourite hobby??',
        'answers': [
          {'text': '1', 'score': -1},
          {'text': '2', 'score': 1},
          {'text': '3', 'score': -1},
          {'text': '4', 'score': -1},
        ]
      },
    ];
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('My First App'),
          ),
          body: _qno >= _questions.length
              ? Result(_totalScore, _resetQ)
              : Quiz(_questions, _qno, _answerQ)),
    );
  }
}
