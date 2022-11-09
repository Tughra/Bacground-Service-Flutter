import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shake/shake.dart';
import 'package:shake_detector/page_one/local_notification_service.dart';
import 'package:shake_detector/page_one/local_storage.dart';


@pragma('vm:entry-point')
void onStart(ServiceInstance service) async{
  DartPluginRegistrant.ensureInitialized();
  LocalStorage.initPrefs();
  String url =
      "https://www.mediacollege.com/downloads/sound-effects/alien/laser-01.wav";
  final audioPlayer = AudioPlayer();
  int count = 0;
  double threshold=1.2;
  late ShakeDetector? detector;
  service.on("start").listen((event) {
    debugPrint("<<<<<<<<<< Dinlenen : $event >>>>>>>>>>");
    if (event!['action'] == 'startService') {
      debugPrint("<<<<<<<<<< From Service : $event >>>>>>>>>>");
      /*
      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
      }
       */

      detector = ShakeDetector.autoStart(onPhoneShake: () async{
        Map<String, dynamic> dataToSend = {
          'count': count++,
        };
        service.invoke("coming", dataToSend);
        audioPlayer.play(UrlSource(url));
        LocalStorage.setInt("shakeCount", count);
        debugPrint("<<<<<<<<<< From Service TO DEVICE : $dataToSend >>>>>>>>>>");
      },shakeThresholdGravity:threshold);

      return;
    }
    if (event['action'] == 'stopService') {
      debugPrint("<<<<<<<<<< From Service : $event >>>>>>>>>>");
      service.stopSelf();
      detector?.stopListening();
    }
  });

  audioPlayer.play(UrlSource(url));
}

const notificationChannelId = 'titdet_foreground';
const notificationActionChannelName = 'Titdet Service';
const notificationActionChannelDescription = 'Shake detection notification';
const notificationId = 1;

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

Future<void> initializeService() async {
/*
  AndroidInitializationSettings initializationSettingsAndroid =
  const AndroidInitializationSettings('@mipmap/ic_launcher');
 */
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'TitDet Channel', // title
    description:
    'This channel is used for background service notifications.', // description
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
      isForegroundMode: true,
      autoStartOnBoot: true,
      initialNotificationTitle: 'TitDet Dinliyor',
      initialNotificationContent: 'Sarsıntı algılama açık.',),
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
  LocalStorage.initPrefs();
  LocalNotificationService.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sarsıntı Algılama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sarsıntı Algılama Demo'),
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
  int shakeCount = 0;
  bool isRunning=false;
  String actionResponse="";
  late final FlutterBackgroundService service;
  //final Source _urlSource=UrlSource("https://www.mediacollege.com/downloads/sound-effects/alien/laser-01.wav");
  void _startOrStopService() async {
    isRunning=await service.isRunning();
    if (isRunning) {
      await Future.delayed(const Duration(seconds: 2),(){
        FlutterBackgroundService().invoke('start', {'action': 'stopService'});
      });
      isRunning=false;
      LocalStorage.setInt('shakeCount', 0);
      print('Service running and will be stopped');
    } else {
      await service.startService();
      await initializeBackground();
      isRunning=await service.isRunning();
      print('Service will be starting');
    }
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    initializeService();
    service = FlutterBackgroundService();
    shakeCount=LocalStorage.getInt('shakeCount')??0;
  }

  @override
  void didChangeDependencies() {
    debugPrint("**********didChangeDependencies***********");
    service.isRunning().then((value){
      if(value){
        isRunning=true;
        print("ÇALIŞIYOOOOOOOR");
        service.startService();
        service.on("coming").listen((event) {
          debugPrint('initstate>>>>>>>>$event');
          if (event!.isNotEmpty && event['count'] != null) {
              shakeCount = event['count'] as int;
            debugPrint('count from service >>>>>>>> $event');
          }
        });
      }else {
        print("KAPALIIIIIIIIII");
      }
      setState(() {});
    });
    super.didChangeDependencies();
  }

  Future<void> initializeBackground() async {
    Future.delayed(const Duration(seconds: 2), () {
      FlutterBackgroundService().invoke('start', {'action': 'startService'});
    });
    FlutterBackgroundService().on("coming").listen((event) {
      debugPrint('initstate>>>>>>>>$event');
      if (event!.isNotEmpty && event['count'] != null) {
        setState(() {
          shakeCount = event['count'] as int;
        });
        debugPrint('count from service >>>>>>>> $event');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromRGBO(39, 39, 45, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Text(actionResponse,style: const TextStyle(color: Colors.blueAccent,fontSize: 40),),
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0,right: 10,left: 10),
              child: Text(
                'Önce Servisi Başlatın Ardından Sarsıntı Hassasiyetini Ayarlayın',textAlign: TextAlign.center,
                style: buildTextStyle(),
              ),
            ),
            const SizedBox(height: 20,),
            const Text(
              'Hissedilen sarsıntı sayısı :',
            ),
            Text(
              '$shakeCount',
              style: Theme.of(context).textTheme.headline4,
            ),
            MaterialButton(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),onPressed: _startOrStopService,padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 50),color: Colors.red.shade700,child: Text(isRunning?"Servisi Kapat":"Servisi Aç",style:const TextStyle(fontSize: 16,color: Colors.white) ,),
            ),
            const SizedBox(height: 20,),
            TextButton(onPressed: (){
              LocalNotificationService.instance.showActionNotification(id: 1, payload: "action notification",title: "Sarsıntı",body: "Sarsıntı hissettik. Yardım cağırmamızı ister misiniz?",showsUserInterface: false);
            }, child: const Text("Dene"))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  TextStyle buildTextStyle({double? fontSize}) => TextStyle(fontSize: fontSize,color:const Color.fromRGBO(0, 175, 183, 1));
}
/*
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
             await LocalNotificationService.instance.showActionNotification(id: 1, payload: "Action Payload",title: "deneme",body: "deneme body");
            },
            tooltip: 'Increment',
            child: const Icon(Icons.close),
          ),
        ],
      )0,175,183
 */

int? topla({required int deger1,required int deger2}){
  return deger1+deger2;
}