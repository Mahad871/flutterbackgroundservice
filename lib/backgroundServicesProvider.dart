import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterbackgroundservice/main.dart';

class BackgroundService {
  FlutterBackgroundService? service;
  static bool? isServiceRunning;

  Future<void> initService() async {
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
        iosConfiguration: IosConfiguration(
            onBackground: iosBackground, onForeground: onStart),
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

  static void printStatus(String text) {
    print('====================');
    print(text);
    print('====================');
  }

  @pragma("vm:entry-point")
  static void onStart(ServiceInstance service) {
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

  @pragma("vm:entry-point")
  Future<bool> iosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }
}
