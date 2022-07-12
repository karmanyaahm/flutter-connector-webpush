import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class UPNotificationUtilsPlatform {
  static Future<void> notify(String title, String body) {}
}
