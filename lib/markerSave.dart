import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

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
  void getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          widget.userPointer.latitude, widget.userPointer.longitude);
      Placemark place = p[0];
      setState(() {
        markAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print(markAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        TextField(
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
        TextField(
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
        TextButton(onPressed: widget.submitData, child: Text('Add the marker'))
      ],
    ));
  }
}
