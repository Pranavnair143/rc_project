import 'package:expenso/widgets/t_list.dart';
import 'package:flutter/material.dart';
import './models/transaction.dart';
import './widgets/new_t.dart';
import './widgets/chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Expenso', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> transactions = [
    Transaction(id: 't1', title: 'Shoe', amount: 120.5, date: DateTime.now()),
    Transaction(id: 't2', title: 'Bag', amount: 220.0, date: DateTime.now()),
    Transaction(id: 't4', title: 'Phone', amount: 520.5, date: DateTime.now()),
  ];

  List<Transaction> get _recentTransactions {
    return transactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(Duration(days: 7)),
      );
    }).toList();
  }

  void _addNew(String txTitle, double txAmount, DateTime txDate) {
    final newtx = Transaction(
      id: DateTime.now().toString(),
      date: txDate,
      title: txTitle,
      amount: txAmount,
    );
    setState(() {
      transactions.add(newtx);
    });
    Navigator.of(context).pop();
  }

  void startAddTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return NewTransaction(_addNew);
        });
  }

  void deleteTx(String id) {
    setState(() {
      transactions.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Expenso'),
      actions: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () => startAddTransaction(context))
      ],
    );
    return Scaffold(
        appBar: appBar,
        body: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  height: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      0.3,
                  child: Chart(_recentTransactions)),
              Container(
                  height: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      0.7,
                  child: TransactionList(this.transactions, this.deleteTx)),
            ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => startAddTransaction(context)));
  }
}
