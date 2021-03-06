import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kite_bird/jarvis/configs/javis_congigs.dart';
import 'package:kite_bird/kite_bird.dart';

Future<http.Response> jarvisSendSms({String phoneNo, String body})async{
  final _base64E = base64Encode(utf8.encode('$consumerKey:$consumeSecret'));
    final String basicAuth = 'Basic $_base64E';
  
    final Map<String, dynamic> _smsPayload = {
      'phoneNo': phoneNo,
      'message': body
    };
    try {
      return await http.post(jarvisSmsUrl, body: json.encode(_smsPayload), headers: <String, String>{'authorization': basicAuth, 'content-type': 'application/json'});
    } catch (e) {
      print(e);
      final http.Response _res = http.Response("An error Occured!!", 500,);
      return _res;
    }
  
}