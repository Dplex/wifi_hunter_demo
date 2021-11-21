import 'dart:convert';

import 'package:wifi_hunter/wifi_hunter_result.dart' as result;
import 'package:http/http.dart' as http;

Future<http.Response> sendFingerprint(String locationId, List<result.WiFiHunterResultEntry> results, String refPoint) async {
  return await http.post(
      Uri.parse('http://13.124.21.200:8882/save_fingerprint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode( {
        'userid': 'test_jhr',
        'locationid': locationId,
        'deviceid': 'test_jhr',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'wifi': results.map((e) => {
          'mac': e.BSSID,
          'rssi': e.level,
          'frequency': e.frequency
        }).toList(),
        'ref_point': refPoint,
      })
  );
}

Future<Map> dashboard1(String locationId, String refPoint) async{
  http.Response response = await http.get(
      Uri.parse('http://13.124.21.200:8882/dashboard/statistics/$locationId/$refPoint/wifi')
  );
  return jsonDecode(response.body) as Map;
}

Future<Map> dashboard2() async{
  http.Response response = await http.get(
      Uri.parse('http://13.124.21.200:8882/dashboard/devices/test_jhr/rssi')
  );
  return jsonDecode(response.body) as Map;
}

Future<Map> dashboard3(String locationId) async{
  http.Response response = await http.get(
      Uri.parse('http://13.124.21.200:8882/dashboard/statistics/$locationId/fingerprint')
  );
  return jsonDecode(response.body) as Map;
}