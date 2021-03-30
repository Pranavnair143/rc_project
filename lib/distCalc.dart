import 'package:geolocator/geolocator.dart';
import 'api_key.dart';
import 'package:dio/dio.dart';

Future<Map<dynamic, dynamic>> distCalc(
    Position startCo, Position destCo) async {
  //var url = Uri.parse(
  //    "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${startCo.latitude},${startCo.longitude}&destinations=${destCo.latitude}%2C,${destCo.longitude}&key=${Secrets.API_KEY}");
  //http.Response response = http.post(url, body: {'name': 'doodle', 'color': 'blue'});

  //http.Response res = await http.get(url);
  //print(res);
  //Map values = jsonDecode(res.body);
  //return values.toString();
  try {
    var response = await Dio().get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${startCo.latitude},${startCo.longitude}&destinations=${destCo.latitude}%2C${destCo.longitude}&key=${Secrets.API_KEY}');
    print(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${startCo.latitude},${startCo.longitude}&destinations=${destCo.latitude}%2C${destCo.longitude}&key=${Secrets.API_KEY}');
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
    Map p = {
      'DestAddress': resDestAddress,
      'OrgAddress': resOrgAddress,
      'Distance': totalDistance,
      'Duration': totalDuration,
      'distText': tdistStr,
      'durText': tdurStr
    };
    print(p);
    // /coreFunc(value, startCoordinates, destinationCoordinates))
    return p;
  } catch (e) {
    print(e);
  }
} //https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=23.0579311,70.1170317&destinations=23.0752362%2C70.1163862%7C&key=AIzaSyAlDx57d3FsEqr4SJfykYrTOtdflQTWTjo
//https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C-73.9976592%7C&key=AIzaSyAlDx57d3FsEqr4SJfykYrTOtdflQTWTjo
