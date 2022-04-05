import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart' as up;
import 'package:unifiedpush_webpush/src/keystore.dart';
import 'package:webpush_encryption/webpush.dart';

class UnifiedPush {
  static Future<void> initialize({
    void Function(
            String endpoint, String instance, String p256dh, String authKey)?
        onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(Uint8List message, String instance)? onMessage,
  }) async {
    void newEndpointWP(String endpoint, String instance) async {
      if (onNewEndpoint != null) {
        //gen/fetch keys
        var key = await KeyStore.getOrGen(instance);

        debugPrint(key.pubKeyWeb);
        debugPrint(key.authWeb);
        onNewEndpoint(endpoint, instance, key.pubKeyWeb, key.authWeb);
      }
    }

    void onUnregisteredWP(String instance) async {
      await KeyStore.tryDelete(instance);
      onUnregistered?.call(instance);
    }

    void onMessageWP(Uint8List message, String instance) async {
      if (onMessage != null) {
        message =
            await WebPush.decrypt(await KeyStore.getKey(instance), message);
        onMessage(message, instance);
      }
    }

    up.UnifiedPush.initialize(
      onNewEndpoint: newEndpointWP,
      onRegistrationFailed: onRegistrationFailed,
      onUnregistered: onUnregisteredWP,
      onMessage: onMessageWP,
    );
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
