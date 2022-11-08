
import 'package:dio/dio.dart';

final Dio dio = Dio();
Future<void> sendNotification() async {

  try {
    dio.options.headers["authorization"] =
    "Bearer xx";
    dio.post(
      "https://fcm.googleapis.com/fcm/send",
      data: {
        "to": "yyy",
        "priority": "high",
        "content_available": true,
        "notification": {"title": "title", "body": "body","sound":"default"},
        "data": {
          "body": "body",
          "title": "title",
          "type": "auth"
        }
      },
    ).then((value) {
    });
  } catch (e) {
  }
}
