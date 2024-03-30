import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalPlugin =
    FlutterLocalNotificationsPlugin();

FlutterBackgroundService? service;
bool? isServiceRunning;

const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
    "coding is life", // Changed to match the ID used in the service configuration
    "coding is life foreground service",
    description: "This is channel des....",
    importance: Importance.high);
void printStatus(String text) {
  print('====================');
  print(text);
  print('====================');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> initservice() async {
  service = FlutterBackgroundService();

  // Set for iOS
  if (Platform.isIOS) {
    await flutterLocalPlugin.initialize(
        const InitializationSettings(iOS: DarwinInitializationSettings()));
  }

  await flutterLocalPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  // Service init and start
  await service!.configure(
      iosConfiguration:
          IosConfiguration(onBackground: iosBackground, onForeground: onStart),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId:
              "coding is life", // Now matches the ID of the notification channel
          initialNotificationTitle: "Coding is life",
          initialNotificationContent: "Awesome Content",
          foregroundServiceNotificationId: 90));

  service!.startService();

  int counter = 0;
  Timer.periodic(Duration(seconds: 1), (timer) async {
    counter++;
    print('Counter: $counter');
    if (counter >= 5) {
      service!.isRunning().then((value) {
        value ? service!.invoke("stopService") : print('Service not running');
      });

      timer.cancel();
      // Perform any actions after 30 seconds here
    }
  });

  // For iOS enable background fetch from add capability inside background mode
}

// onStart method
@pragma("vm:entry-point")
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  service.on("setAsForeground").listen((event) {
    print("foreground ===============");
  });
  service.on("setAsBackground").listen((event) {
    print("background ===============");
  });
  service.on("stopService").listen((event) {
    service.stopSelf();
    isServiceRunning = false;
    printStatus(isServiceRunning.toString());
  });
  // Display notification as service
}

//iosbackground
@pragma("vm:entry-point")
Future<bool> iosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Background Service'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isServiceRunning != null
                  ? isServiceRunning!
                      ? Text(
                          'Service is running',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          'Service is stopped',
                          style: TextStyle(color: Colors.red),
                        )
                  : Text('Service is not running'),
              ElevatedButton(
                onPressed: () async {
                  await initservice();
                  setState(() {
                    isServiceRunning = true;
                  });
                },
                child: Text('Start Background Service'),
              ),
              ElevatedButton(
                onPressed: () async {},
                child: Text('Stop Background Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
