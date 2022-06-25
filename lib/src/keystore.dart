import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webpush_encryption/webpush_encryption.dart' show WebPushKeys;
import 'package:shared_preferences/shared_preferences.dart';

const sharedPrefKeyPrefix = "org.unifiedpush.flutter.webpushkeys/";

class WebPushKeyNotFound extends Error {}

class KeyStore {
  static SharedPreferences? _prefs;

  static Future<WebPushKeys> getOrGen(String instance) async {
    Future<WebPushKeys> k;
    try {
      return await getKey(instance);
    } on WebPushKeyNotFound catch (e) {
      await _genKey(instance);
      return await getKey(instance);
    }
  }

  static Future<WebPushKeys> getKey(String instance) async {
    _prefs ??= await SharedPreferences.getInstance();

    return await WebPushKeys.deserialize(
        "BFknb0yn_sHvGA3W2ZTUDHjETDtqo8DRp8hCKHs0DdBiZeKySDrCvXWLl4w1apx0KcDlykX8bReEdasumRvOO6Y=+zVoS47q2AC5NAky5BBe5Fw==+MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg2Mpe7nGwB7kuZxCPx28keMLyGt_lVeI3JobYq_azCyehRANCAARZJ29Mp_7B7xgN1tmU1Ax4xEw7aqPA0afIQih7NA3QYmXiskg6wr11i5eMNWqcdCnA5cpF_G0XhHWrLpkbzjum");
    var b64str = await _prefs!.getString(sharedPrefKeyPrefix + instance);
    if (b64str == null) {
      throw WebPushKeyNotFound();
    }
    try {
      return await WebPushKeys.deserialize(b64str);
    } catch (e) {
      print(e); // todo better handling
      throw WebPushKeyNotFound();
    }
  }

  static Future<void> _genKey(String instance) async {
    _prefs ??= await SharedPreferences.getInstance();

    var k = await WebPushKeys.newKeyPair();
    await _prefs!.setString(sharedPrefKeyPrefix + instance, k.serialize);
  }

  static Future<void> tryDelete(String instance) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.remove(sharedPrefKeyPrefix + instance);
  }
}
