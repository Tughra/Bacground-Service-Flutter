import 'dart:async';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';
const String darwinNotificationCategoryPlain2 = 'plainCategory2';
const String navigationActionId = 'id_3';

void didReceiveNotification(NotificationResponse notificationResponse) {
  print("------------Tapped Notification----------------");
  switch (notificationResponse.notificationResponseType) {
    case NotificationResponseType.selectedNotification:
      {
        print("------------Tapped BODY----------------");
        onNotifications.add(notificationResponse.payload);
      }
      break;
    case NotificationResponseType.selectedNotificationAction:
      {
        print("------------Action Tapped----------------");
        onNotifications.add(notificationResponse.actionId);
      }
      break;
  }
}

@pragma('vm:entry-point')
void didReceiveNotificationBackground(
    NotificationResponse notificationResponse) {
  print("------------Tapped Notification Background----------------");
  switch (notificationResponse.notificationResponseType) {
    case NotificationResponseType.selectedNotification:
      {
        print("------------Tapped BODY Background----------------");
        onNotifications.add(notificationResponse.payload);
      }
      break;
    case NotificationResponseType.selectedNotificationAction:
      {
        //sendNotification();
        print("------------Action Tapped Background----------------");
        debugPrint(notificationResponse.actionId);
        onNotifications.add(notificationResponse.actionId);
      }
      break;
  }
}

final StreamController<String?> onNotifications = StreamController<String?>();

class LocalNotificationService {
  static LocalNotificationService? _instance;

  static LocalNotificationService get instance {
    if (_instance == null) {
      print("LocalNotificationService nulldı oluştu");
      return _instance = LocalNotificationService._init();
    } else {
      print("LocalNotificationService önceki kullanıldı");
      return _instance!;
    }
  }

  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  late final InitializationSettings initializationSettings;

  late final AndroidNotificationChannel channel;

  LocalNotificationService._init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final List<DarwinNotificationCategory> darwinNotificationCategories =
    <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(darwinNotificationCategoryPlain2,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Yardım Al'),
            DarwinNotificationAction.plain(
              'id_2',
              'İptal',
            ),
          ]),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) {
        /*
        onNotifications.add(
          ReceivedNotification(
            id: a,
            title: b,
            body: c,
            payload: d,
          ),
        );
         */
      },
      notificationCategories: darwinNotificationCategories,
    );
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    //flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveBackgroundNotificationResponse:notificationTapBackground);

    init();
  }

  void listenOnTabNotifications({required BuildContext context}) =>
      onNotifications.stream.listen((String? value) {
        _onClickedNotification(value, context: context);
        debugPrint("listen OnTab Notifications");
        onNotifications.stream.forEach((element) {
          debugPrint(element);
          debugPrint("-*-");
        });
      });

  void listenWhenReceived() {
    onNotifications.stream.listen((event) {
      debugPrint("listen when receive");
    });
  }

  void _onClickedNotification(String? payload,
      {required BuildContext context}) {
    if (payload != null) {
      debugPrint("**** _onClickedNotification ***");
    } //Get.to(()=>NotificationDetailPage(payload:payload,));
  }

  static initializeTimeZones() async {
    // mainde çağır
    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));
  }

  Future<void> init() async {
    print("init local notify");
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
      showBadge: true,
      enableLights: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// When app is closed
    final details =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.notificationResponse?.payload);

      debugPrint("Normal behaviour");
      debugPrint(details.notificationResponse?.payload);
      debugPrint(details.notificationResponse?.actionId);
    }
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: didReceiveNotification,
        onDidReceiveBackgroundNotificationResponse:
        didReceiveNotificationBackground);
  }

  Future<void> showNotification(
      {String? title,
        String? body,
        required int hashcode,
        required String? payload}) async {
    debugPrint("****showNotification****");
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'high_importance_channel', 'Bilsem Up Bildirim',
        channelDescription: 'BilsemUp bildirim kanalı',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        channelShowBadge: true,
        icon: '@mipmap/ic_launcher',
        channelAction: AndroidNotificationChannelAction.values[1],
        color: Colors.purple.shade800,
        largeIcon:
        const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ticker: 'Bisem Up');

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      interruptionLevel: InterruptionLevel.critical,
      threadIdentifier: "high_importance_channel",
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iosPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      hashcode,
      title ?? 'plain title',
      body ?? 'plain body',
      platformChannelSpecifics,
      payload: payload ?? 'item x',
    );
  }

  Future<void> showActionNotification({
    String? title,
    String? body,
    required int id,
    bool showsUserInterface = true,
    required String? payload,
  }) async {
    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain2,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      "notificationActionChannelId2",
      "notificationActionChannelName",
      channelDescription: "notificationActionChannelDescription",
      priority: Priority.high,
      importance: Importance.max,
      //groupKey:"notificationActionChannelName",
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('id_1', 'Yardım Al',
            titleColor: Colors.green,
            showsUserInterface: showsUserInterface,
            cancelNotification: true),
        const AndroidNotificationAction('id_2', 'İptal',
            titleColor: Colors.black),
      ],
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iosNotificationDetails, android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      id,
      title ?? 'plain title',
      body ?? 'plain body',
      platformChannelSpecifics,
      payload: payload ?? 'item x',
    );
  }

  Future<void> showActionNotificationScheduled(
      {String? title,
        String? body,
        required int id,
        required String? payload,
        required DateTime scheduledDate}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    const AndroidNotificationDetails(
      "notificationScheduleActionChannelId2",
      "notificationScheduleActionChannelName",
      channelDescription: "notificationActionScheduleChannelDescription",
      priority: Priority.high,
      importance: Importance.max,
      //groupKey:"notificationActionChannelName",
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('id_1', 'Yardım Al',
            titleColor: Colors.green, showsUserInterface: true),
        AndroidNotificationAction('id_2', 'İptal', titleColor: Colors.black),
      ],
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      threadIdentifier: "high_importance_channel",
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iosPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future showScheduledNotification(
      {int id = 0,
        String? title,
        String? body,
        String? payload,
        required DateTime scheduledDate}) async {
    debugPrint("********----*********");
    //scheduledDate mandatory
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      schedulePlatformChannelSpecifics(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails schedulePlatformChannelSpecifics() {
    debugPrint(AndroidNotificationChannelAction.values.toString());
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    const AndroidNotificationDetails(
        'schedule task channel', 'BisemUp Tasks',
        channelDescription: 'Scheduled task notification',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        channelShowBadge: true,
        icon: '@mipmap/ic_launcher',
        /*
      channelAction: AndroidNotificationChannelAction.values[
      1
      ],
       */
        color: Color(0x00960002),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ticker: 'Bisem Up');

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      threadIdentifier: "schedule task channel",
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iosPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);
    return platformChannelSpecifics;
  }
}