import 'package:flutter/material.dart';
import 'add_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InputBox extends StatefulWidget {
  final Function submitData;
  final TextEditingController orgController;
  final TextEditingController destController;
  final String currentAddress;
  final FocusNode orgNode;
  final FocusNode destNode;
  final Set<Marker> markers;
  final Position currentPosition;

  InputBox(
    this.submitData,
    this.orgController,
    this.destController,
    this.currentAddress,
    this.orgNode,
    this.destNode,
    this.markers,
    this.currentPosition,
  );
  @override
  _InputBoxState createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  void addUserMarker(BuildContext context) {
    print('HELLOOOO');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return AddMarker(widget.markers);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          TextButton(
              onPressed: () => addUserMarker(context), child: Text('Add Mark')),
          TextButton(onPressed: widget.submitData, child: Text('Submit')),
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              onSubmitted: (_) => widget.submitData,
              controller: widget.orgController,
              decoration: InputDecoration(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
                labelText: 'Choose destination point',
              ),
              focusNode: widget.destNode,
            ),
          ),
        ],
      ),
    ));
  }
}
