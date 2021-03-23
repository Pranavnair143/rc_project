import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'api_key.dart';
import 'input_box.dart';
import 'dart:math' show cos, sqrt, asin;

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

  String _placeDistance;

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      print(destAddress);
      print('vfgggggggggggggg');
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

        double totalDistance = 0.0;
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
      print('HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
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

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
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
        _placeDistance = null;
      });
      _calculateDistance().then((isCalculated) {
        if (isCalculated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Distance Calculated Sucessfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error Calculating Distance'),
            ),
          );
        }
      });
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
            markers: markers != null ? Set<Marker>.from(markers) : null,
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
