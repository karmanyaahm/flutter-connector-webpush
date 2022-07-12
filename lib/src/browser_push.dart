import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart' as up;
import 'dart:html' as html;
import 'package:unifiedpush_webpush/src/keystore.dart';
import 'package:webpush_encryption/webpush_encryption.dart';

const BROWSER_DISTRIBUTOR = 'org.unifiedpush.distributors.web_browser';
const ON_FG_MESSAGE = 'org.unifiedpush.flutter.webpush.on_fg_message'; //TODO

class UnifiedPush {
  static void Function(
          String endpoint, String instance, String p256dh, String authKey)?
      _onNewEndpoint;
  static void Function(String instance)? _onUnregistered;
  static bool updated = false;

  static Future<html.ServiceWorkerRegistration?>? get _worker async {
    //return html.window.navigator.serviceWorker?.getRegistration();
    //var r = await html.window.navigator.serviceWorker?.register('worker.js');
    //if (!updated) {
    //  //update once on each start
    //  await r?.update();
    //  updated = true;
    //}
    // return html.window.navigator.serviceWorker?.ready;
    //return r;
    var regs = (await html.window.navigator.serviceWorker?.getRegistrations())
            ?.cast<html.ServiceWorkerRegistration>() ??
        [];
    //var reg = await html.window.navigator.serviceWorker
    //   ?.register('/unifiedpush-worker.js');
    // TODO idk wtf is going on between here and the service worker registration in web/index.html
    html.ServiceWorkerRegistration? reg;
    regs.forEach((element) {
      print(element.scope);
      var uri = Uri.parse(element.active?.scriptUrl ?? "");
      if (uri.pathSegments[0] == 'unifiedpush-worker.js') reg = element;
    });
    print(reg?.scope);
    print("HI");
    return reg;
  }

  static Future<void> initialize({
    void Function(
            String endpoint, String instance, String p256dh, String authKey)?
        onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(Uint8List message, String instance)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onUnregistered = onUnregistered;
    //this is only for foreground, background is TODO
    html.window.navigator.serviceWorker?.addEventListener('message',
        (event) async {
      var myevent =
          (event as html.MessageEvent).data as LinkedHashMap<dynamic, dynamic>;
      var data = myevent['message'] as ByteBuffer?;
      //var time = myevent['time'] as String;
      //TODO restirct to ON_FG_MESSAGE type
      onMessage?.call(data?.asUint8List() ?? Uint8List(0), defaultInstance);
    });
  }

  static Future<void> registerAppWithDialog(BuildContext context,
      {String instance = defaultInstance,
      List<String>? features,
      bool userVisibleOnly = false,
      String? appServerKey}) async {
    registerApp(
        instance: instance,
        features: features,
        userVisibleOnly: userVisibleOnly,
        appServerKey: appServerKey);
  }

  static Future<void> registerApp(
      {String instance = defaultInstance,
      List<String>? features,
      bool userVisibleOnly = false,
      String? appServerKey}) async {
    var sub = await (await _worker)?.pushManager?.subscribe({
      "userVisibleOnly": userVisibleOnly,
      "applicationServerKey": appServerKey
    });

    var endpoint = sub?.endpoint;

    //TODO test null handling here, test poor connectivity results
    List<int>? p256dhraw = sub?.getKey('p256dh')?.asUint8List();
    List<int>? authraw = sub?.getKey('auth')?.asUint8List();

    if ([endpoint, p256dhraw, authraw].any((n) => n == null))
      return; // TODO call failed

    var p256dh = base64UrlEncode(p256dhraw!);
    var auth = base64UrlEncode(authraw!);

    if (endpoint != null) {
      _onNewEndpoint?.call(endpoint, defaultInstance, p256dh, auth);
    }
  }

  static Future<void> unregister([String instance = defaultInstance]) async {
    var sub = await (await _worker)?.pushManager?.getSubscription();
    sub?.unsubscribe();
    _onUnregistered?.call(defaultInstance);
  }

  static Future<List<String>> getDistributors([List<String>? features]) async {
    return [BROWSER_DISTRIBUTOR];
  }

  static Future<String> getDistributor() async {
    return BROWSER_DISTRIBUTOR;
  }

  static Future<void> saveDistributor(String distributor) async {
    //nop
  }
}
