import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'api_key.dart';

Future<Map<dynamic, dynamic>> distCalc(
    Position startCo, Position destCo) async {
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
    Map data = {
      'DestAddress': resDestAddress,
      'OrgAddress': resOrgAddress,
      'Distance': totalDistance,
      'Duration': totalDuration,
      'distText': tdistStr,
      'durText': tdurStr
    };
    return data;
  } catch (e) {
    print(e);
  }
}
