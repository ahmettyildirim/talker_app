import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talker_app/common/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:talker_app/widgets/facebook_signin.dart';
import 'package:talker_app/widgets/google_signin.dart';
import 'package:toast/toast.dart';
import 'package:location/location.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  var currentLocation = <String, double>{};
  var location = new Location();
  StreamSubscription<Map<String, double>> locationSubscription;

  void initPlatformState() async {
    Map<String, double> myLocation;
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENİED') {
        Toast.show("Please allow permission for locations", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        myLocation = null;
      }
    }
    currentLocation = myLocation;
  }

  @override
  void initState() {
    super.initState();
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState();
    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = result;
      });
    });
  }


  
  void login() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      FirebaseUser user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      Toast.show("Logged in successfully", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                   user: user,
                  )));
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  void signup() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      FirebaseUser user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      Toast.show("Created  successfully ${user.email}", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.9), BlendMode.dstATop)),
          ),
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: genericTextStyle,
                        decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),
                          // fillColor: Color(0xffe9e9e9),
                          labelText: "Email",
                          labelStyle: genericTextStyle,
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color(0xffe9e9e9),
                            size: 20.0,
                          ), // icon is 48px widget.
                        )),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: genericTextStyle,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),
                          labelText: "Password",
                          labelStyle: genericTextStyle,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xffe9e9e9),
                            size: 20.0,
                          )),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          shape: shapeBorderroundedWith30,
                          child: Text("Signup"),
                          onPressed: signup,
                        ),
                        RaisedButton(
                          shape: shapeBorderroundedWith30,
                          color: Colors.indigo,
                          child: Text(
                            'Login',
                            style: genericTextStyle,
                          ),
                          onPressed: login,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 400.0,
                      child: SignInWithGoogle()
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 400.0,
                      child: SignInWithFacebook()
                    ),
                    Text(
                        'LOCATIOOON : Lat/Lng:${currentLocation != null && currentLocation.containsKey('latitude') ? currentLocation["latitude"] : null}'),
                    Text(
                        'LOCATIOOON : Lat/Lng:${currentLocation != null && currentLocation.containsKey('longitude') ? currentLocation["longitude"] : null}')
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
