import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rc_app/markerSave.dart';

class AddMarker extends StatefulWidget {
  final Set<Marker> markers;
  final TextEditingController destController;
  AddMarker(this.markers, this.destController);
  @override
  _AddMarkerState createState() => _AddMarkerState();
}

class _AddMarkerState extends State<AddMarker> {
  Set<Marker> mrkList = {};
  GoogleMapController mapController;
  Position currentPosition;
  LatLng userPointer;
  String currentAddress;
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
    List<Placemark> p = await placemarkFromCoordinates(
        userPointer.latitude, userPointer.longitude);
    setState(() {
      if (mrkList != null) {
        widget.markers.add(Marker(
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
            setState(() {
              widget.destController.text = currentAddress;
            });
          },
        ));
        mrkList = {};
        userPointer = null;
      }
      print(widget.markers);
      Navigator.of(context).pop();
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
    return Scaffold(
        floatingActionButton: (userPointer != null)
            ? Container(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(40),
                                topRight: const Radius.circular(40))),
                        backgroundColor: Colors.white,
                        builder: (_) {
                          return MarkerSave(
                            submitData,
                            markNameController,
                            markAddressController,
                            nameNode,
                            addressNode,
                            userPointer,
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
              markers: mrkList != null ? mrkList.union(widget.markers) : null,
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
        ));
  }
}
