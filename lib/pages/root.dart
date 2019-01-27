import 'package:flutter/material.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/common/functions/auth_provider.dart';
import 'package:talker_app/pages/home.dart';
import 'package:talker_app/pages/login.dart';
import 'package:toast/toast.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = AuthProvider.of(context).auth;
    auth.currentUser().then((user) {
      setState(() {
        UserModelRepository.currentUser = user;
        authStatus =
            user == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
      Toast.show("Logged in successfully", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    });
  }

  void _signedOut() {
    setState(() {
      Toast.show("Logged out successfully", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return HomePage(onSignedOut: _signedOut,);
    }
    return null;
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new ExactAssetImage('assets/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
