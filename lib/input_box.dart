import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class InputBox extends StatefulWidget {
  final Function submitData;
  final TextEditingController orgController;
  final TextEditingController destController;
  final String currentAddress;
  final FocusNode orgNode;
  final FocusNode destNode;
  final Position currentPosition;

  InputBox(
    this.submitData,
    this.orgController,
    this.destController,
    this.currentAddress,
    this.orgNode,
    this.destNode,
    this.currentPosition,
  );
  @override
  _InputBoxState createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              onSubmitted: (_) => widget.submitData,
              controller: widget.orgController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusColor: Colors.red,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(),
                  ),
                  labelText: 'Choose starting point',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location_rounded),
                    onPressed: () {
                      setState(() {
                        widget.orgController.text =
                            widget.currentAddress.toString();
                      });
                      //orgAddress = addCurrent;
                    },
                  )),
              focusNode: widget.orgNode,
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              onSubmitted: (_) => widget.submitData,
              controller: widget.destController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
                labelText: 'Choose destination point',
              ),
              focusNode: widget.destNode,
            ),
          ),
          Container(
              child: ElevatedButton(
                  onPressed: widget.submitData, child: Text('Check'))),
        ],
      ),
    ));
  }
}
