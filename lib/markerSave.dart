import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerSave extends StatefulWidget {
  final Function submitData;
  final TextEditingController markNameController;
  final TextEditingController markAddressController;
  final FocusNode nameNode;
  final FocusNode addressNode;
  final LatLng userPointer;

  MarkerSave(
    this.submitData,
    this.markNameController,
    this.markAddressController,
    this.nameNode,
    this.addressNode,
    this.userPointer,
  );

  @override
  _MarkerSaveState createState() => _MarkerSaveState();
}

class _MarkerSaveState extends State<MarkerSave> {
  String markAddress = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              onSubmitted: (_) => widget.submitData,
              controller: widget.markNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
                labelText: 'Label',
              ),
              focusNode: widget.nameNode,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              onSubmitted: (_) => widget.submitData,
              controller: widget.markAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
                labelText: 'Address',
              ),
              focusNode: widget.addressNode,
            ),
          ),
          ElevatedButton(
              onPressed: widget.submitData, child: Text('Add the marker'))
        ],
      ),
    );
  }
}
