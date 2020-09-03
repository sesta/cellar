import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cellar/domain/entity/entities.dart';

class AlertRepository {
  Future<void> send(Status status) async {
    String url = '';
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'text': 'test'});

    http.Response resp = await http.post(url, headers: headers, body: body);

    if (resp.statusCode != 200) {
      print('アラートの送信に失敗しました: ${resp.statusCode}');
      return;
    }
  }
}
