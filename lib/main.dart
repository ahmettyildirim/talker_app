import 'package:flutter/material.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/pages/login.dart';
// import 'package:flutter/rendering.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String textValue = "Hello worldd";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  update(String token) {
    print(token);
    textValue = token;
    setState(() {});
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print('ON-LAUNCH called');
      },
      onResume: (Map<String, dynamic> msg) {
        print('ON-RESUME called');
      },
      onMessage: (Map<String, dynamic> msg) {
        print('ON-MESSAGE called');
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('IOS settings registered');
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      home: LoginPage(),
    );
  }
}
