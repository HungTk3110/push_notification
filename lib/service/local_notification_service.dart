import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled1/utils/logger.dart';

import 'handle_navigate_from_notification.dart';

// Docs: https://firebase.flutter.dev/docs/messaging/notifications#foreground-notifications
class LocalNotificationService {
  static final _localNotificationService = FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel? channel;

  Future<void> init() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings("@drawable/launch_background");

    DarwinInitializationSettings initializationSettingsDarwin =
    const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel!);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotificationService.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Map<String, dynamic> notificationData =
            json.decode(notificationResponse.payload!);
            // HandleNavigateFromNotification.handleNavigate(notificationData);

            ///Indicates that a user has selected a notification
            break;
          case NotificationResponseType.selectedNotificationAction:
            logger.d('------------------Click  action notification');

            ///Indicates the a user has selected a notification action.
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      _localNotificationService.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel!.id,
            channel!.name,
            channelDescription: channel?.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel?.id ?? "",
      channel?.name ?? "",
      channelDescription: channel?.description ?? 'description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails();
    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static void onDidReceiveLocalNotification(
      int? id,
      String? title,
      String? body,
      String? payload,
      ) async {
    logger.d(
        '------------------- onDidReceiveLocalNotification -------------- $title');
  }

  static void notificationTapBackground(
      NotificationResponse notificationResponse,
      ) {
    logger.d('LOCAL PUSH SERVICE: notificationTapBackground');

    final notificationData = json.decode(notificationResponse.payload!);
    HandleNavigateFromNotification.handleNavigate(notificationData);
  }
}