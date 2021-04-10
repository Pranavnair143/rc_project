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
import 'add_marker.dart';

import 'package:dio/dio.dart';
//MODELS
import 'ml_models/model1_cf.dart' as onecf;
import 'ml_models/model1_rg.dart' as onerg;
//import 'ml_models/model2_cf.dart' as twocf;
// ignore: unused_import
//import 'ml_models/model2_rg.dart' as tworg;
//import 'ml_models/model3_cf.dart' as threecf;
//import 'ml_models/model3_rg.dart' as threerg;
//import 'ml_models/model4_cf.dart' as fourcf;
//import 'ml_models/model4_rg.dart' as fourrg;
//import 'ml_models/model5_cf.dart' as fivecf;
//import 'ml_models/model5_rg.dart' as fiverg;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RC_APP',
      home: AppView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  Set<Marker> markers = {};
  BitmapDescriptor myIcon;
  Set<Marker> userMarkers = {
    Marker(
      markerId: MarkerId('Dummy'),
      position: LatLng(73.072897226544825, 70.11426513723994),
      infoWindow: InfoWindow(
        title: '',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      visible: false,
    ),
  };

  void addUserMarker(BuildContext context) async {
    final Set<Marker> newlyAdded = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddMarker(rcMarkers, destController, markerShortcut)));
    setState(() {
      if (newlyAdded != null) {
        userMarkers.addAll(newlyAdded);
      }
    });
  }

  int totalDistance;
  double totalDuration;
  String tdistStr;
  String tdurStr;

  Position currentPosition;
  CameraPosition _iniPosition = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  String orgAddress = '';
  String destAddress = '';
  String currentAddress;
  String resOrgAddress = '';
  String resDestAddress = '';
  Map<dynamic, dynamic> infos = {};
  Map<dynamic, dynamic> sheetInfos = {};
  final orgController = TextEditingController();
  final destController = TextEditingController();

  final orgNode = FocusNode();
  final destNode = FocusNode();

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<Point> polylinePoint = [];

  void showSheet(BuildContext ctx, Position startCoordinates,
      Position destinationCoordinates) {
    showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10))),
        backgroundColor: Colors.white,
        builder: (_) {
          return FutureBuilder(
              future: coreFunc(startCoordinates, destinationCoordinates),
              builder:
                  (context, AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ResultSheet(snapshot.data);
                } else {
                  return Container(
                      child: Center(child: Text('Loading')),
                      padding: EdgeInsets.all(100));
                }
              });
        });
  }

  Future<Map<dynamic, dynamic>> coreFunc(
      Position startCoordinates, Position endCoordinates) async {
    var response = await Dio().get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${startCoordinates.latitude},${startCoordinates.longitude}&destinations=${endCoordinates.latitude}%2C${endCoordinates.longitude}&key=${Secrets.API_KEY}');
    String resDestAddress =
        response.data['destination_addresses'][0].toString();
    String resOrgAddress = response.data['origin_addresses'][0].toString();
    int totalDistance =
        response.data['rows'][0]['elements'][0]['distance']['value'];
    int totalDuration =
        response.data['rows'][0]['elements'][0]['duration']['value'];
    String tdistStr =
        response.data['rows'][0]['elements'][0]['distance']['text'];
    String tdurStr =
        response.data['rows'][0]['elements'][0]['duration']['text'];
    print(resOrgAddress);
    Map<dynamic, dynamic> data = {
      'DestAddress': resDestAddress,
      'OrgAddress': resOrgAddress,
      'Distance': totalDistance,
      'Duration': totalDuration,
      'distText': tdistStr,
      'durText': tdurStr
    };
    print('pppppppppppppppppppppppppppppppppppppppppppppppppppppppppp');

    int checkOn;
    Marker rcPoint;
    for (var i = 0; i < rcMarkers.length; i++) {
      checkOn = gmc.PolyUtils.locationIndexOnEdgeOrPath(
        Point(rcMarkers.elementAt(i).position.latitude,
            rcMarkers.elementAt(i).position.longitude),
        polylinePoint,
        false,
        false,
        100,
      );
      if (checkOn >= 0) {
        rcPoint = rcMarkers.elementAt(i);
        data['rcCrossing'] = rcPoint.infoWindow.title;
        break;
      }
    }
    final DateTime startTime = new DateTime.now();
    if (rcPoint != null) {
      // ignore: missing_required_param
      data['includesGate'] = 1;
      /*await distCalc(
              startCoordinates,
              // ignore: missing_required_param
              Position(
                  latitude: rcPoint.position.latitude,
                  longitude: rcPoint.position.longitude))
          .then((bp) {
        print(bp);*/
      var response = await Dio().get(
          'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${startCoordinates.latitude},${startCoordinates.longitude}&destinations=${rcPoint.position.latitude}%2C${rcPoint.position.longitude}&key=${Secrets.API_KEY}');
      int totalDuration =
          response.data['rows'][0]['elements'][0]['duration']['value'];
      DateTime reach = startTime.add(Duration(seconds: totalDuration));
      print(reach);
      /*List<double> lp = [
          reach.day.toDouble(),
          reach.hour.toDouble(),
          reach.minute.toDouble(),
          0
        ];*/
      List<double> lp = [15, 11, 29, 0];
      List<double> cfResult;
      cfResult = onecf.score(lp);
      print(cfResult);
      print('sssssssssssssssssss');
      if (cfResult[0] > cfResult[1]) {
        data['gateStatus'] = 0;
      } else {
        data['gateStatus'] = 1;
        data['WaitingTime'] = onerg.score(lp).floor();
      }
      print(data['WaitingTime']);
      /*if (rcPoint.markerId == MarkerId('B')) {
        cfResult = twocf.score(lp);
        if (cfResult[0] > cfResult[1]) {
          data['gateStatus'] = 0;
        } else {
          data['gateStatus'] = 1;
          data['waitingTime'] = tworg.score(lp);
        }
      } else if (rcPoint.markerId == MarkerId('C')) {
        cfResult = threecf.score(lp);
        if (cfResult[0] > cfResult[1]) {
          data['gateStatus'] = 0;
        } else {
          data['gateStatus'] = 1;
          data['waitingTime'] = threerg.score(lp);
        }
      } else if (rcPoint.markerId == MarkerId('D')) {
        cfResult = fourcf.score(lp);
        if (cfResult[0] > cfResult[1]) {
          data['gateStatus'] = 0;
        } else {
          data['gateStatus'] = 1;
          data['waitingTime'] = fourrg.score(lp);
        }
      } else if (rcPoint.markerId == MarkerId('E')) {
        cfResult = fivecf.score(lp);
        if (cfResult[0] > cfResult[1]) {
          data['gateStatus'] = 0;
        } else {
          data['gateStatus'] = 1;
          data['waitingTime'] = fiverg.score(lp);
        }
      }*/
      return data;
    } else {
      data['includesGate'] = 0;
      return data;
    }
  }

  Future<bool> _calculateDistance(String orgAddress, String destAddress) async {
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
        int checkOn;
        await _createPolylines(startCoordinates, destinationCoordinates);
        for (var i = 0; i < rcMarkers.length; i++) {
          checkOn = gmc.PolyUtils.locationIndexOnEdgeOrPath(
            Point(rcMarkers.elementAt(i).position.latitude,
                rcMarkers.elementAt(i).position.longitude),
            polylinePoint,
            false,
            false,
            100,
          );
          if (checkOn >= 0) {
            print(checkOn);
            break;
          }
        }

        showSheet(context, startCoordinates, destinationCoordinates);
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
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<bool> markerShortcut(
      Position startCoordinates, Position destinationCoordinates) async {
    try {
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      setState(() {
        if (markers.isNotEmpty) markers.clear();
        if (polylines.isNotEmpty) polylines.clear();
        if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
        if (polylinePoint.isNotEmpty) polylinePoint.clear();
      });
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
      int checkOn;
      await _createPolylines(startCoordinates, destinationCoordinates);
      for (var i = 0; i < rcMarkers.length; i++) {
        checkOn = gmc.PolyUtils.locationIndexOnEdgeOrPath(
          Point(rcMarkers.elementAt(i).position.latitude,
              rcMarkers.elementAt(i).position.longitude),
          polylinePoint,
          false,
          false,
          100,
        );
        if (checkOn >= 0) {
          print(checkOn);
          break;
        }
      }

      showSheet(context, startCoordinates, destinationCoordinates);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
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
      });
      await _calculateDistance(orgAddress, destAddress).then((isCalculated) {
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
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Set<Marker> rcMarkers = {
    Marker(
      markerId: MarkerId('A'),
      position: LatLng(23.072897226544825, 70.11426513723994),
      infoWindow: InfoWindow(
        title: 'Galpadhar Railway Crossing',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
    Marker(
      markerId: MarkerId('A'),
      position: LatLng(23.0682255, 70.1310453),
      infoWindow: InfoWindow(
        title: 'Meghpar Railway Crossing',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
    Marker(
      markerId: MarkerId('A'),
      position: LatLng(23.065036799999998, 70.12660079999999),
      infoWindow: InfoWindow(
        title: 'Lilashah Railway Crossing',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
  };
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              addUserMarker(context);
            },
            child: Icon(Icons.add_location),
          ),
          body: Stack(
            children: [
              GoogleMap(
                markers: (markers != null)
                    ? Set<Marker>.from([userMarkers, rcMarkers, markers]
                        .expand((x) => x)
                        .toList())
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
              InputBox(submitData, orgController, destController,
                  currentAddress, orgNode, destNode, currentPosition),
            ],
          )),
    );
  }
}
