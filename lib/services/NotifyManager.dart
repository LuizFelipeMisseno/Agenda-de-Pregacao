import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("ic_logo");

    IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings();

    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    //onSelectNotification:
  }

  Future instantNotification() async {
    var android = AndroidNotificationDetails("id", "channel", "description");

    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.show(
        0, "Demo instant notification", "Tap to do something", platform,
        payload: "Welcome to demo app");
  }

  Future imageNotification() async {
    var bigPicture = BigPictureStyleInformation(
      DrawableResourceAndroidBitmap("ic_logo"),
      largeIcon: DrawableResourceAndroidBitmap("ic_logo"),
      contentTitle: "Demo image notification",
      summaryText: "This is some text",
      htmlFormatContent: true,
      htmlFormatContentTitle: true,
    );

    var android = AndroidNotificationDetails("id", "channel", "description",
        styleInformation: bigPicture);
    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.show(
        0, "Demo Image notification", "Tap to do something", platform,
        payload: "Welcome to demo app");
  }

  Future stylishNotification() async {
    var android = AndroidNotificationDetails("id", "channel", "description",
        color: Colors.deepOrange,
        enableLights: true,
        enableVibration: true,
        largeIcon: DrawableResourceAndroidBitmap("ic_logo"),
        styleInformation: MediaStyleInformation(
          htmlFormatContent: true,
          htmlFormatTitle: true,
        ));
    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.show(
      0,
      "Demo Stylish notification",
      "Tap to do something",
      platform,
    );
  }

  Future scheduleNotification(
      id, title, description, interval, hour, minute) async {
    var time = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.saturday, hour, minute, 0, 0, 0);
    var android = AndroidNotificationDetails(
      "id",
      "channel",
      "description",
    );
    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: ios);

    /* await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id,
      title,
      description,
      interval,
      time,
      platform,
    ); */

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      description,
      _nextInstanceOfMondayTenAM(hour, minute, interval),
      platform,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM(hour, minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMondayTenAM(hour, minute, day) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM(hour, minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancel(id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
