import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:background_service/page_one/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shake/shake.dart';




const notificationChannelId = 'acn_foreground';
const notificationActionChannelId = 'acn_action';
const notificationActionChannelName = 'AcnTurk Korumam';
const notificationActionChannelDescription = 'Sarsıntı izleme bildirimleri';
const notificationId = 888;

@pragma('vm:entry-point')
void backHand(NotificationResponse response){
  final service = FlutterBackgroundService();
  debugPrint("<<<<<<<<<< BBBBxxxxxBBBB >>>>>>>>>>");
  debugPrint(">>>>>>>>>>>>>>>${response.actionId??"null"}");

    service.invoke("coming", {
    'count': 200,
  });
}
void onStart(ServiceInstance service) async{
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);


  AndroidNotificationDetails androidPlatformChannelSpecifics =
  const AndroidNotificationDetails(
    "notificationActionChannelId3",
    "notificationActionChannelName3",
    channelDescription: "notificationActionChannelDescription3",
    priority: Priority.high,
    importance: Importance.max,
    //groupKey:"notificationActionChannelName",
    ticker: 'ticker',
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('id_1', 'Yardım Al',titleColor: Colors.green,showsUserInterface: false,cancelNotification: true),
      AndroidNotificationAction('id_2', 'İptal',titleColor: Colors.black),
    ],
  );
  const DarwinNotificationDetails iosPlatformChannelSpecifics =
  DarwinNotificationDetails(
    threadIdentifier: "high_importance_channel",
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iosPlatformChannelSpecifics,
      android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response){
      debugPrint("<<<<<<<<<< AAAAAAAAAAAAAAA >>>>>>>>>>");
      onNotifications.add(response.payload);
      onNotifications.add(response.actionId);
    },                        //  callback A 🅰
    onDidReceiveBackgroundNotificationResponse:backHand,    //  callback B 🅱
  );
  String url =
      "https://www.mediacollege.com/downloads/sound-effects/alien/laser-01.wav";
  final audioPlayer = AudioPlayer();
  int count = 0;
  late final ShakeDetector? detector;
  service.on("start").listen((event) {
    debugPrint("<<<<<<<<<< Dinlenen : $event >>>>>>>>>>");
    if (event!['action'] == 'startService') {
      debugPrint("<<<<<<<<<< From Service : $event >>>>>>>>>>");
      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
      }
      detector = ShakeDetector.autoStart(onPhoneShake: () async{
        Map<String, dynamic> dataToSend = {
          'count': count++,
        };
        service.invoke("coming", dataToSend);
        await flutterLocalNotificationsPlugin.show(
          count,
         'plain title',
           'plain body',
          platformChannelSpecifics,
          payload:  'item x',
        ).then((value){
          service.invoke("coming", {
            'count': 500,
          });
        });
        audioPlayer.play(UrlSource(url));
        debugPrint("<<<<<<<<<< From Service TO DEVICE : $dataToSend >>>>>>>>>>");
      });
      return;
    }
    if (event['action'] == 'stopService') {
      debugPrint("<<<<<<<<<< From Service : $event >>>>>>>>>>");
      service.stopSelf();
      detector?.stopListening();
    }
  });

  /*
    audioPlayer.onPlayerComplete.listen((event) {
    debugPrint("<<<<<<<<<< onPlayerComplete >>>>>>>>>>");
     Map<String,dynamic>dataToSend={
       'count':count++,
     };
     service.invoke("coming",dataToSend);
     debugPrint("<<<<<<<<<< Data Sent : $dataToSend >>>>>>>>>>");
     audioPlayer.play(UrlSource(url));
  });
   */
  audioPlayer.play(UrlSource(url));
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'AcnTurk Güvendeyim', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low,
    // importance must be at low or higher level
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
/*
  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: IOSInitializationSettings(),
      ),
    );
  }
 */
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
        notificationChannelId: notificationChannelId,
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        autoStart: false,
        isForegroundMode: false,
        autoStartOnBoot: true,
      initialNotificationTitle: 'AcnTurk Guvendeyim',
      initialNotificationContent: 'Adımlarınız bizimle güvende.',),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  //service.startService();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final audioPlayer = AudioPlayer();
  int playCount = 0;
  bool isRunning=false;
  String actionResponse="";
  late final FlutterBackgroundService service;
  //final Source _urlSource=UrlSource("https://www.mediacollege.com/downloads/sound-effects/alien/laser-01.wav");
  void _startOrStopService() async {
    isRunning=await service.isRunning();
    if (isRunning) {
      Future.delayed(const Duration(seconds: 2),(){
        FlutterBackgroundService().invoke('start', {'action': 'stopService'});
      });
      print('Service running and will be stopped');
    } else {
      service.startService();
      await initializeBackground();
      print('Service will be starting');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeService();
    service = FlutterBackgroundService();
  }

  @override
  void didChangeDependencies() {
    debugPrint("**********didChangeDependencies***********");
    service.isRunning().then((value){
      if(value){
        print("ÇALIŞIYOOOOOOOR");
        service.startService();
        service.on("coming").listen((event) {
          debugPrint('initstate>>>>>>>>$event');
          if (event!.isNotEmpty && event['count'] != null) {
            setState(() {
              playCount = event['count'] as int;
            });
            debugPrint('count from service >>>>>>>> $event');
          }
        });
       /*
        service.on("action").listen((event) {
          debugPrint('initstate>>>>>>>>$event');
          if (event!.isNotEmpty && event['action'] != null) {
            setState(() {
              actionResponse = event['action'];
            });
            debugPrint('count from service >>>>>>>> $event');
          }
        });
        */
      }else {
        print("KAPALIIIIIIIIII");
      }
    });
    super.didChangeDependencies();
  }

  /*
  void player () async{
   audioPlayer.onPlayerComplete.listen((duration) async{
     debugPrint("<<<<<<<<<< onPlayerStateChanged >>>>>>>>>>");
     debugPrint("<<<<<<<<<< event sate :>>>>>>>>>>");
       setState(()=>playCount++);
      await audioPlayer.play(_urlSource);

   });
  await audioPlayer.play(_urlSource);
  }
  */
  Future<void> initializeBackground() async {
    Future.delayed(const Duration(seconds: 2), () {
      FlutterBackgroundService().invoke('start', {'action': 'startService'});
    });
    FlutterBackgroundService().on("coming").listen((event) {
      debugPrint('initstate>>>>>>>>$event');
      if (event!.isNotEmpty && event['count'] != null) {
        setState(() {
          playCount = event['count'] as int;
        });
        debugPrint('count from service >>>>>>>> $event');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(actionResponse,style: const TextStyle(color: Colors.blueAccent,fontSize: 40),),
            TextButton(
              onPressed: () {
                LocalNotificationService.instance.showNotification(hashcode:1, payload: "123213");
                //FlutterBackgroundService().invoke('start', {'action': 'startService'});
                //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const PageOne()));
              },
              child: const Text(
                'Page 1',
              ),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$playCount',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _startOrStopService,
            tooltip: 'Increment',
            child: const Icon(Icons.star),
          ),
          const SizedBox(
            height: 30,
          ),
          FloatingActionButton(
            heroTag: "1",
            onPressed:()async{
             await LocalNotificationService.instance.showActionNotification(hashcode: 1, payload: "Action Payload",title: "deneme",body: "deneme body");
            },
            tooltip: 'Increment',
            child: const Icon(Icons.close),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
