import 'dart:convert';
import 'package:http/http.dart';

class AlertRepository {
  static String _slackUrl;

  Future<void> send(String message) async {
    String body = json.encode({
      'text': message,
    });

    Response response = await post(
      _slackUrl,
      headers: { 'content-type': 'application/json' },
      body: body,
    );

    if (response.statusCode != 200) {
      print('アラートの送信に失敗しました: ${response.statusCode}');
      return;
    }
  }

  set slackUrl(String slackUrl) {
    _slackUrl = slackUrl;
  }
}
