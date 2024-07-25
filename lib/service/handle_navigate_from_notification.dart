import 'package:untitled1/utils/logger.dart';

class HandleNavigateFromNotification {
  static handleNavigate(Map<String, dynamic> notificationData) async {
    logger.i("FCM: - Implement TAP TO PUSH NOTIFICATION");
    logger.i(notificationData);

    final notificationType = notificationData["notification_type"] as String?;
    if (notificationType == null) {
      logger.e("notificationType is null");
      return;
    }
  }
}