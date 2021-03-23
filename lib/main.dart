import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'input_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'RC_APP', home: AppView());
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  Position currentPosition;
  CameraPosition _iniPosition = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  String orgAddress = '';
  String destAddress = '';
  String currentAddress;

  final orgController = TextEditingController();
  final destController = TextEditingController();

  final orgNode = FocusNode();
  final destNode = FocusNode();
  //GoogleMapController mapController;

  void submitData() {
    final orgAddress = orgController.text;
    final destAddress = destController.text;
    print(orgAddress);
    if (orgAddress.isEmpty || destAddress.isEmpty) {
      return;
    }
  }

  getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        orgController.text = currentAddress;
        orgAddress = currentAddress;
        print(orgAddress);
        print(
            'ADRESSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs');
      });
    } catch (e) {
      print(e);
    }
  }

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        currentPosition = position;
        print(position);
        print('POSITIONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN');
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 18.0,
        )));
        print('BOSDKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK');
      });
      await getAddress();
    }).catchError((e) {
      print(e);
    }); //.then((Position position) => widget.update(position));
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
          body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _iniPosition,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          InputBox(submitData, orgController, destController, currentAddress,
              orgNode, destNode),
        ],
      )),
    );
  }
}
