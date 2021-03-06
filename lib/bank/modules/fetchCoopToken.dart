import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:kite_bird/bank/configs/bank_config.dart';
import 'package:kite_bird/kite_bird.dart';

Future<String> fetchCoopToken({String key, String secret})async{
  final String username = key;
  final String password =  secret;
  final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  final Map<String, String> _headers = {
    'authorization': basicAuth,
    "Accept": "application/json",
    "Content-Type": "application/x-www-form-urlencoded"
  };

  const bool trustSelfSigned = true;
  final HttpClient httpClient = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);
  final IOClient ioClient = IOClient(httpClient);

  final http.Response r = await ioClient.post(coopTokenUrl, body: {'grant_type': 'client_credentials'}, headers: _headers, );

  final body = json.decode(r.body);

  return body['access_token'].toString();

}
