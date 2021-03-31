import 'package:flutter/material.dart';

class ResultSheet extends StatefulWidget {
  final Map results;
  ResultSheet(this.results);
  @override
  _ResultSheetState createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding:
                        EdgeInsets.only(top: 20, bottom: 20, right: 5, left: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        )
                      ],
                    )),
                (widget.results['includesGate'] == 0)
                    ? Icon(
                        Icons.arrow_forward_sharp,
                        size: 50,
                      )
                    : Icon(
                        Icons.railway_alert,
                        size: 50,
                        color: (widget.results['WaitingTime'] != null)
                            ? Colors.red
                            : Colors.green,
                      ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding:
                        EdgeInsets.only(top: 20, bottom: 20, right: 5, left: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text('Destination',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ))
                      ],
                    ))
              ],
            ),
          ),
          Row(
            children: [
              (widget.results['includesGate'] == 1)
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(widget.results['rcCrossing'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text('Clear route',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                    )
            ],
          ),
          Row(
            children: [
              Column(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Distance',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ]),
              Column(children: [
                Text(
                  '   ' + widget.results['distText'],
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                )
              ])
            ],
          ),
          Row(
            children: [
              Column(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Travel Time',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ]),
              Column(children: [
                Text(
                  '   ' + widget.results['durText'],
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                )
              ])
            ],
          ),
          Row(
            children: [
              Column(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Waiting Time',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ]),
              Column(children: [
                (widget.results['WaitingTime'] != null)
                    ? Text(
                        '   ' + widget.results['WaitingTime'].toString(),
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      )
                    : Icon(Icons.local_dining_outlined)
              ])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: (widget.results['WaitingTime'] != null)
                          ? Colors.red
                          : Colors.lightGreen),
                  padding: EdgeInsets.all(20),
                  child: (widget.results['includesGate'] == 0)
                      ? Text(
                          'Free to go',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      : (widget.results['WaitingTime'] != null)
                          ? Text(
                              'Wait for ${widget.results['WaitingTime']} minutes',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              textAlign: TextAlign.center)
                          : Text('Free to go',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              textAlign: TextAlign.center))
            ],
          )
        ],
      ),
    );
  }
}
