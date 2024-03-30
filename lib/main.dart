import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterbackgroundservice/backgroundServicesProvider.dart';

final FlutterLocalNotificationsPlugin flutterLocalPlugin =
    FlutterLocalNotificationsPlugin();

FlutterBackgroundService? service;
bool? isServiceRunning;

final sPro = BackgroundService();

const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
    "coding is life", // Changed to match the ID used in the service configuration
    "coding is life foreground service",
    description: "This is channel des....",
    importance: Importance.high);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
                  sPro.initService();
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
