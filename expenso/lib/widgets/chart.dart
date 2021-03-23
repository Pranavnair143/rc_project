import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;
  Chart(this.recentTransactions);

  List<Map<String, Object>> get groupedTransactions {
    return List.generate(7, (index) {
      var weekday = DateTime.now().subtract(Duration(days: index));
      var totalSum = 0.0;
      for (var i = 0; i < recentTransactions.length; i++) {
        if (weekday.day == recentTransactions[i].date.day &&
            weekday.month == recentTransactions[i].date.month &&
            weekday.year == recentTransactions[i].date.year) {
          totalSum += recentTransactions[i].amount;
        }
      }
      return {'Date': DateFormat.E().format(weekday), 'totalSum': totalSum};
    });
  }

  @override
  Widget build(BuildContext context) {
    print(groupedTransactions);
    return Container(
        child: Card(
      margin: EdgeInsets.all(20),
      elevation: 10,
      child: Row(children: []),
    ));
  }
}
