import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart' as up;
import 'dart:html' as html;
import 'package:unifiedpush_webpush/src/keystore.dart';
import 'package:webpush_encryption/webpush_encryption.dart';

class UnifiedPush {
  late void Function(
          String endpoint, String instance, String p256dh, String authKey)?
      _onNewEndpoint;
  static Future<void> initialize({
    void Function(
            String endpoint, String instance, String p256dh, String authKey)?
        onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(Uint8List message, String instance)? onMessage,
  }) async {
    assert(2 == 1 + 1);
    print((await html.window.navigator.serviceWorker?.getRegistration()));
    var curr = await html.window.navigator.serviceWorker?.getRegistration();
    //var reg = await html.window.navigator.serviceWorker?.register('');
    var sub = await curr?.pushManager?.getSubscription();
    print(sub?.endpoint.toString());
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      sub = await curr?.pushManager?.getSubscription();
      print(sub?.endpoint.toString() ?? null);
    }
  }

  static Future<void> registerAppWithDialog(BuildContext context,
      [String instance = defaultInstance, List<String>? features]) async {
    return up.UnifiedPush.registerAppWithDialog(
        context, instance, [...(features ?? []), featureAndroidBytesMessage]);
  }

  static Future<void> registerApp(
      [String instance = defaultInstance, List<String>? features]) async {
    return up.UnifiedPush.registerApp(
        instance, [...(features ?? []), featureAndroidBytesMessage]);
  }

  static Future<void> unregister([String instance = defaultInstance]) async {
    return up.UnifiedPush.unregister(instance);
  }

  static Future<List<String>> getDistributors([List<String>? features]) async {
    return up.UnifiedPush.getDistributors(
        [featureAndroidBytesMessage, ...(features ?? [])]);
  }

  static Future<String> getDistributor() async {
    return up.UnifiedPush.getDistributor();
  }

  static Future<void> saveDistributor(String distributor) async {
    return up.UnifiedPush.saveDistributor(distributor);
  }
}
