import 'dart:math';

import 'package:flutter/material.dart';
import 'package:unifiedpush_webpush/unifiedpush_webpush.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'notification_utils.dart';

Future<void> main() async {
  runApp(const MyApp());
  EasyLoading.instance.userInteractions = false;
}

UnifiedPush unifiedPush;

var instance = "myInstance";

var endpoint = "";
var pubkey = "";
var authkey = "";
var registered = false;

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    UnifiedPush.initialize(
      onNewEndpoint:
          onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed: onRegistrationFailed, // takes (String instance)
      onUnregistered: onUnregistered, // takes (String instance)
      onMessage: UPNotificationUtils
          .basicOnNotification, // takes (String message, String instance) in args
    );
    super.initState();
  }

  void onNewEndpoint(
      String _endpoint, String _instance, String p256dh, String auth) {
    if (_instance != instance) {
      return;
    }
    registered = true;
    endpoint = _endpoint;
    pubkey = p256dh;
    authkey = auth;
    setState(() {
      debugPrint(endpoint);
      debugPrint(pubkey);
      debugPrint(authkey);
    });
  }

  void onRegistrationFailed(String _instance) {
    //TODO
  }

  void onUnregistered(String _instance) {
    if (_instance != instance) {
      return;
    }
    registered = false;
    setState(() {
      debugPrint("unregistered");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {HomePage.routeName: (context) => HomePage()},
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';

  final title = TextEditingController(text: "Notification Title");
  final message = TextEditingController(text: "Notification Body");

  HomePage({Key key}) : super(key: key);

  void notify() async => await http.post(Uri.parse(endpoint),
      body: "title=${title.text}&message=${message.text}&priority=6");

  String myPickerFunc(List<String> distributors) {
    // Do not do a random func, this is an example.
    // You should do a context menu/dialog here
    Random rand = Random();
    final max = distributors.length;
    final index = rand.nextInt(max);
    return distributors[index];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      ElevatedButton(
        child: Text(registered ? 'Unregister' : "Register"),
        onPressed: () async {
          if (registered) {
            UnifiedPush.unregister(instance);
          } else {
            /**
             * Registration
             * Option 1:  Use the default distributor picker
             *            which uses a dialog
             */
            UnifiedPush.registerAppWithDialog(context, instance, []);
            /**
             * Registration
             * Option 2: Do your own function to pick the distrib
             */
            /*
            if (await UnifiedPush.getDistributor() != "") {
              UnifiedPush.registerApp(instance);
            } else {
              final distributors = await UnifiedPush.getDistributors();
              if (distributors.length == 0) {
                return;
              }
              final distributor = myPickerFunc(distributors);
              UnifiedPush.saveDistributor(distributor);
              UnifiedPush.registerApp(instance);
            }
            */
          }
        },
      ),
    ];

    if (registered) {
      row.add(ElevatedButton(child: const Text("Notify"), onPressed: notify));
      row.add(
        TextField(
          controller: title,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter a search term'),
        ),
      );

      row.add(TextField(
        controller: message,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), hintText: 'Enter a search term'),
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Unifiedpush Example'),
        ),
        body: Column(
          children: [
            SelectableText("Endpoint: " + (registered ? endpoint : "empty")),
            SelectableText("p256dh key: " + (registered ? pubkey : "empty")),
            SelectableText("Auth key: " + (registered ? authkey : "empty")),
            Center(
              child: Column(
                children: row,
              ),
            ),
          ],
        ));
  }
}
