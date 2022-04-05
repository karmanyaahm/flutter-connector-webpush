import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webpush_encryption/webpush.dart' show WebPushKeys;
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

    var b64str = await _prefs!.getString(sharedPrefKeyPrefix + instance);
    if (b64str == null) {
      throw WebPushKeyNotFound();
    }
    try {
      return await WebPushKeys.fromBase64(b64str);
    } catch (e) {
      print(e); // todo better handling
      throw WebPushKeyNotFound();
    }
  }

  static Future<void> _genKey(String instance) async {
    _prefs ??= await SharedPreferences.getInstance();

    var k = await WebPushKeys.random();
    await _prefs!.setString(sharedPrefKeyPrefix + instance, k.toBase64);
  }

  static Future<void> tryDelete(String instance) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.remove(sharedPrefKeyPrefix + instance);
  }
}
