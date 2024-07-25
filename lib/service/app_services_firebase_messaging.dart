import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:untitled1/service/handle_navigate_from_notification.dart';
import 'package:untitled1/utils/logger.dart';

import 'local_notification_service.dart';

class AppServicesFirebaseMessaging {
  AppServicesFirebaseMessaging._privateConstructor();
  static final AppServicesFirebaseMessaging _instance =
  AppServicesFirebaseMessaging._privateConstructor();
  static AppServicesFirebaseMessaging get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? fcmToken;
  final localPush = LocalNotificationService();

  Future<void> initNotifications() async {
    try {
      await _requestPermission();
      await localPush.init();
      await fcmGetToken();
      await listenInBackgroundMode();
      await _getInitialMessage();
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    if (Platform.isAndroid) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        localPush.showNotification(
          id: notification.hashCode,
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? "",
          payload: json.encode(message.data),
        );
      }
    }
  }

  /// Only in iOS, android not need request permission
  Future<void> _requestPermission() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: true,
        sound: true,
      );

      /// setup Show alert when app in foreground
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> fcmGetToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM TOKEN: $token");
      fcmToken = token;
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> listenInBackgroundMode() async {
    try {
      // FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        logger.log("FirebaseMessaging.onMessage.listen");
        logger.log(message);

        if (Platform.isAndroid) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            localPush.showNotification(
              id: notification.hashCode,
              title: message.notification?.title ?? "",
              body: message.notification?.body ?? "",
              payload: json.encode(message.data),
            );
          }
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        logger.log("FirebaseMessaging.onMessageOpenedApp.listen");
        HandleNavigateFromNotification.handleNavigate(message.data);
      });
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> _getInitialMessage() async {
    try {
      RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        logger.log("FirebaseMessaging.instance.getInitialMessage");
        HandleNavigateFromNotification.handleNavigate(message.data);
      }
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // TODO: handle Message
    // TODO: -
    logger.log("_handleBackgroundMessage");
    logger.log(message);
  }
}