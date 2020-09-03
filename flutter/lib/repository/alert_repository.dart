import 'dart:convert';
import 'package:http/http.dart';

import 'package:cellar/domain/entity/entities.dart';

class AlertRepository {
  Future<void> send(Status status, String message) async {
    String body = json.encode({
      'text': message,
    });

    Response response = await post(
      status.slackUrl,
      headers: { 'content-type': 'application/json' },
      body: body,
    );

    if (response.statusCode != 200) {
      print('アラートの送信に失敗しました: ${response.statusCode}');
      return;
    }
  }
}
