import 'package:flutter/material.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/functions/auth_firebase.dart';
import 'package:talker_app/common/functions/auth_provider.dart';
import 'package:talker_app/pages/root.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: FirebaseAuthentication(),
      child: MaterialApp(
        title: 'Marlok',
        theme: ThemeData(
          primaryColor: themeColor,
        ),
        home: RootPage(),
      ),
    );
  }
}
