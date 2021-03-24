import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'api_key.dart';

Future<http.Response> distCalc(Position startCo, Position destCo) async {
  var url = Uri.parse(
      "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${startCo.latitude},${startCo.longitude}&destinations=${destCo.latitude}%2C,${destCo.longitude}&key=${Secrets.API_KEY}");
  var response = http.post(url, body: {'name': 'doodle', 'color': 'blue'});
  return response;
}
