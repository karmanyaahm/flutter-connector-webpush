import 'dart:html' as html;

abstract class UPNotificationUtilsPlatform {
  static Future<void> notify(String title, String body) {
    html.Notification(title, body: body);
  }
}
