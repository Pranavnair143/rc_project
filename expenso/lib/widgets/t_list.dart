import 'package:expenso/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> _transactions;
  final Function deleteTx;

  TransactionList(this._transactions, this.deleteTx);

  @override
  Widget build(BuildContext context) {
    return _transactions.isEmpty
        ? Column(children: [
            Text(
              'You have no transactions..!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 50),
            Container(
              child: Image.asset(
                'assets/images/waiting.png',
                fit: BoxFit.cover,
              ),
              height: 200,
            )
          ])
        : ListView(
            children: _transactions.map((tx) {
              return Card(
                  child: Row(children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 2)),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '\$ ${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                      fontSize: 18,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd().format(tx.date),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => deleteTx(tx.id),
                    )
                  ],
                )
              ]));
            }).toList(),
          );
  }
}
