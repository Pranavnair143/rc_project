import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rc_app/markerSave.dart';

class AddMarker extends StatefulWidget {
  final Set<Marker> markers;
  final TextEditingController destController;
  final Function markerShortcut;
  AddMarker(this.markers, this.destController, this.markerShortcut);
  @override
  _AddMarkerState createState() => _AddMarkerState();
}

class _AddMarkerState extends State<AddMarker> {
  Set<Marker> mrkList = {};
  Set<Marker> showStored = {};
  Set<Marker> op = {};
  GoogleMapController mapController;
  Position currentPosition;
  LatLng userPointer;
  String currentAddress;
  Position mrkPosition;
  final markNameController = TextEditingController();
  final markAddressController = TextEditingController();
  final nameNode = FocusNode();
  final addressNode = FocusNode();

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      print('ssss');
      setState(() {
        currentPosition = position;
        print(currentPosition);
        print('ppppppppppppppppppppppppppppppppppppppppppp');
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 18.0,
        )))
            .then((result) {
          getAddress();
        });
      });
    }).catchError((e) {
      print(e);
    });
  }

  getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          userPointer.latitude, userPointer.longitude);
      Placemark place = p[0];
      setState(() {
        currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print(currentAddress);
        markAddressController.text = currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  void submitData() async {
    setState(() {
      if (mrkList != null) {
        setState(() {
          // ignore: missing_required_param
          mrkPosition = Position(
              latitude: mrkList.elementAt(0).position.latitude,
              longitude: mrkList.elementAt(0).position.longitude);
        });
        op.add(Marker(
          markerId: MarkerId(userPointer.toString()),
          position: LatLng(mrkList.elementAt(0).position.latitude,
              mrkList.elementAt(0).position.longitude),
          infoWindow: InfoWindow(
            title: markNameController.text,
            snippet: markAddressController.text,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () {
            widget.destController.text = currentAddress;
            widget
                .markerShortcut(
                    // ignore: missing_required_param
                    Position(
                        latitude: currentPosition.latitude,
                        longitude: currentPosition.longitude),
                    // ignore: missing_required_param
                    mrkPosition)
                .then((isCalculated) {
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
          },
        ));
        mrkList = {};
        userPointer = null;
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your marker added successfully.!!'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition _iniPosition = CameraPosition(target: LatLng(0.0, 0.0));
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, op);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Set your marker'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.red, Colors.blue])),
            ),
          ),
          floatingActionButton: (userPointer != null)
              ? Container(
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                    onPressed: () {
                      if (markNameController.text.isNotEmpty)
                        markNameController.text = '';
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(40),
                                  topRight: const Radius.circular(40))),
                          backgroundColor: Colors.white,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: MarkerSave(
                                submitData,
                                markNameController,
                                markAddressController,
                                nameNode,
                                addressNode,
                                userPointer,
                              ),
                            );
                          });
                    },
                    icon: Icon(
                      Icons.add_location_alt_rounded,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                )
              : null,
          body: Stack(
            children: [
              GoogleMap(
                markers: mrkList != null
                    ? Set<Marker>.from([op, mrkList].expand((x) => x).toList())
                    : null,
                initialCameraPosition: _iniPosition,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                onTap: (LatLng point) {
                  setState(() {
                    userPointer = point;
                    Marker markOn = Marker(
                      markerId: MarkerId(userPointer.toString()),
                      position:
                          LatLng(userPointer.latitude, userPointer.longitude),
                      infoWindow: InfoWindow(
                        title: markNameController.text,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueViolet),
                    );
                    getAddress();
                    print(markOn);
                    mrkList = {};
                    mrkList.add(markOn);
                  });
                },
              ),
            ],
          )),
    );
  }
}
