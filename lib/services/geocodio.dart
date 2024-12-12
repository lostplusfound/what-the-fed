import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Geocodio {
  static const String _authority = 'api.geocod.io';
  static const String _apiKey = '49d06a2304fa745d96aa0e6445d377a024a4259';
  static Future<({String state, int district})?> getStateAndDistrict(String address) async {
    var url = Uri.https(_authority, '/v1.7/geocode',
        {'api_key': _apiKey, 'q': address, 'limit': '1', 'fields': 'cd'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      String state =
          jsonResponse['results'][0]['address_components']['state'] as String;
      int district = jsonResponse['results'][0]['fields']
          ['congressional_districts'][0]['district_number'] as int;
      return (state: state, district: district);
    }
    return null;
  }
}
