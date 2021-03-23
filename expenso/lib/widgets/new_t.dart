import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewTransaction extends StatefulWidget {
  final Function addNew;

  NewTransaction(this.addNew);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final titleController = TextEditingController();

  final amountController = TextEditingController();
  DateTime _selDate;

  void submitData() {
    final entTitle = titleController.text;
    final entAmount = double.parse(amountController.text);
    final entDate = _selDate;
    if (entTitle.isEmpty || entAmount <= 0 || entDate == null) {
      return;
    }
    widget.addNew(entTitle, entAmount, entDate);
  }

  void selectDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2017),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: titleController,
              onSubmitted: (_) => submitData,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: amountController,
              onSubmitted: (_) => submitData,
            ),
            Container(
                height: 100,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _selDate == null
                      ? Text('No Date chosen..!')
                      : Text("${DateFormat.yMMMd().format(_selDate)}"),
                  TextButton(
                      child: Text('Choose Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                      onPressed: selectDate)
                ])),
            RaisedButton(
                onPressed: submitData,
                child: Text('Add Transaction',
                    style: TextStyle(color: Colors.white)),
                color: Colors.blue)
          ],
        ),
      ),
    );
  }
}
