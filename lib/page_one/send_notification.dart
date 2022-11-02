
import 'package:dio/dio.dart';

final Dio dio = Dio();
Future<void> sendNotification() async {

  try {
    dio.options.headers["authorization"] =
    "Bearer 'xxx'";
    dio.post(
      "https://fcm.googleapis.com/fcm/send",
      data: {
        "to": "yyy",
        "priority": "high",
        "content_available": true,
        "notification": {"title": "Tuğranın Başı Dertte", "body": "Abi yardım eeeeeett","sound":"default"},
        "data": {
          "body": "Help Me",
          "title": "Help",
          "type": "auth"
        }
      },
    ).then((value) {
    });
  } catch (e) {
  }
}
