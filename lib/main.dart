import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_utils/google_maps_utils.dart' as gmc;
import 'dart:math' show Point;

import 'resultSheet.dart';
import 'api_key.dart';
import 'input_box.dart';
import 'distCalc.dart';

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
  Set<Marker> markers = {};
  Set<Marker> rcMarkers = {
    Marker(
      markerId: MarkerId(''),
      position: LatLng(23.072897226544825, 70.11426513723994),
      infoWindow: InfoWindow(
        title: 'Railway Crossing',
        snippet: 'Paata Nhi',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
  };
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

  var _placeDistance;

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<Point> polylinePoint = [];

  void showSheet(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(40),
                topRight: const Radius.circular(40))),
        backgroundColor: Colors.white,
        builder: (_) {
          return ResultSheet();
        });
  }

  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      print(destAddress);
      List<Location> startPlacemark = await locationFromAddress(orgAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(destAddress);
      print(destinationPlacemark);
      if (startPlacemark != null && destinationPlacemark != null) {
        Position startCoordinates = orgAddress == currentAddress
            // ignore: missing_required_param
            ? Position(
                latitude: currentPosition.latitude,
                longitude: currentPosition.longitude)
            // ignore: missing_required_param
            : Position(
                latitude: startPlacemark[0].latitude,
                longitude: startPlacemark[0].longitude);
        // ignore: missing_required_param
        Position destinationCoordinates = Position(
            latitude: destinationPlacemark[0].latitude,
            longitude: destinationPlacemark[0].longitude);
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: orgAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: destAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        markers.add(startMarker);
        markers.add(destinationMarker);
        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position northeastCoordinates;
        Position southwestCoordinates;

        double miny =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? startCoordinates.latitude
                : destinationCoordinates.latitude;
        double minx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? startCoordinates.longitude
                : destinationCoordinates.longitude;
        double maxy =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? destinationCoordinates.latitude
                : startCoordinates.latitude;
        double maxx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? destinationCoordinates.longitude
                : startCoordinates.longitude;
        print(maxx);
        // ignore: missing_required_param
        southwestCoordinates = Position(latitude: miny, longitude: minx);
        // ignore: missing_required_param
        northeastCoordinates = Position(latitude: maxy, longitude: maxx);
        print(southwestCoordinates);
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                northeastCoordinates.latitude,
                northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                southwestCoordinates.latitude,
                southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        await _createPolylines(startCoordinates, destinationCoordinates);
        int checkOn;
        for (var i = 0; i < rcMarkers.length; i++) {
          checkOn = gmc.PolyUtils.locationIndexOnEdgeOrPath(
              Point(rcMarkers.elementAt(i).position.latitude,
                  rcMarkers.elementAt(i).position.longitude),
              polylinePoint,
              false,
              false,
              100);
          if (checkOn >= 0) {
            print(checkOn);
            break;
          }
        }
        print(checkOn);

        setState(() {
          _placeDistance = distCalc(startCoordinates, destinationCoordinates);
          print(_placeDistance.data);
        });
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        polylinePoint.add(Point(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  void submitData() async {
    orgAddress = orgController.text;
    destAddress = destController.text;
    print(destAddress);
    if (orgAddress != '' && destAddress != '') {
      orgNode.unfocus();
      destNode.unfocus();
      setState(() {
        if (markers.isNotEmpty) markers.clear();
        if (polylines.isNotEmpty) polylines.clear();
        if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
        if (polylinePoint.isNotEmpty) polylinePoint.clear();
        _placeDistance = null;
      });
      _calculateDistance().then((isCalculated) {
        if (isCalculated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('See Results'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error..!!Try Again.'),
            ),
          );
        }
      }).then((infoRc) => showSheet(context));
    } else {
      return null;
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
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 18.0,
        )));
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
            markers: markers != null
                ? Set<Marker>.from(
                    [rcMarkers, markers].expand((x) => x).toList())
                : null,
            initialCameraPosition: _iniPosition,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            polylines: Set<Polyline>.of(polylines.values),
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
