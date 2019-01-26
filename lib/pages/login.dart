import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talker_app/common/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:talker_app/widgets/google_signin.dart';
import 'package:talker_app/widgets/login_form.dart';
import 'package:toast/toast.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';


class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _resetEmailController = new TextEditingController();
  var currentLocation = <String, double>{};
  var location = new Location();
  final _formKey = GlobalKey<FormState>();
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

  
  void resetPassword(String mailAddress) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: mailAddress);
      Toast.show("Reset mail has sent you mail address", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
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

  _showDialog() async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Full Name', hintText: 'eg. John Smith'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('OPEN'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: new ExactAssetImage('assets/bg1.png'),
          fit: BoxFit.cover,
        ),
      ),
      // padding: EdgeInsets.all(10.0),

      child: Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
            colors: <Color>[
              const Color.fromRGBO(162, 146, 199, 0.8),
              const Color.fromRGBO(51, 51, 63, 0.9),
            ],
            stops: [0.2, 1.0],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
          )),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 250.0,
                      height: 250.0,
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        image: DecorationImage(
                          image: new ExactAssetImage('assets/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    LoginForm(),
                    // TextField(
                    //     controller: _emailController,
                    //     keyboardType: TextInputType.emailAddress,
                    //     style: genericTextStyle,
                    //     decoration: InputDecoration(
                    //       // fillColor: Color(0xffe9e9e9),
                    //       labelText: "Email",
                    //       labelStyle: genericTextStyle,
                    //       prefixIcon: Icon(
                    //         Icons.email,
                    //         color: Color(0xffe9e9e9),
                    //         size: 20.0,
                    //       ), // icon is 48px widget.
                    //     )),
                    // SizedBox(
                    //   height: 10.0,
                    // ),
                    // TextField(
                    //   controller: _passwordController,
                    //   obscureText: true,
                    //   style: genericTextStyle,
                    //   decoration: InputDecoration(
                    //       labelText: "Password",
                    //       labelStyle: genericTextStyle,
                    //       prefixIcon: Icon(
                    //         Icons.lock,
                    //         color: Color(0xffe9e9e9),
                    //         size: 20.0,
                    //       )),
                    // ),
                    // SizedBox(
                    //   height: 10.0,
                    // ),
                    // Row(
                    //   children: <Widget>[
                    //     Column(
                    //       children: <Widget>[
                    //         RaisedButton(
                    //           // shape: shapeBorderroundedWith30,
                    //           color: Color(0xffDAE0E2),
                    //           child: Text(
                    //             'Login',
                    //             style: TextStyle(color: Color(0xff2F363F)),
                    //           ),
                    //           onPressed: login,
                    //         ),
                    //         FlatButton(
                    //           child: Text(
                    //             "Forgot Password?",
                    //             softWrap: true,
                    //             style: loginFlatButtonStyle,
                    //           ),
                    //           onPressed: () {
                    //             Alert(
                    //                 context: context,
                    //                 title: "Reset Pasword",
                    //                 content: Column(
                    //                   children: <Widget>[
                    //                     TextField(
                    //                       keyboardType:
                    //                           TextInputType.emailAddress,
                    //                       controller: _resetEmailController,
                    //                       decoration: InputDecoration(
                    //                         icon: Icon(Icons.account_circle),
                    //                         labelText: 'Enter your mail',
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 buttons: [
                    //                   DialogButton(
                    //                     onPressed: () {
                    //                       Navigator.pop(context);
                    //                       resetPassword(_resetEmailController.text);
                    //                     },
                    //                     color: Color(0xffD63031),
                    //                     child: Text(
                    //                       "Reset Password",
                    //                       style: TextStyle(
                    //                           color: Colors.white,
                    //                           fontSize: 15),
                    //                     ),
                    //                   )
                    //                 ]).show();
                    //           },
                    //         ),
                    //       ],
                    //     )
                    //   ],
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    // ),
                    Row(
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            "Don't have an account? Sign Up",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: loginFlatButtonStyle,
                          ),
                          onPressed: () {},
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),

                    Text(
                      "OR",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: loginFlatButtonStyle,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(width: 400.0, child: SignInWithGoogle()),

                    // SizedBox(width: 400.0, child: SignInWithFacebook()),
                    // Text(
                    //     'LOCATIOOON : Lat/Lng:${currentLocation != null && currentLocation.containsKey('latitude') ? currentLocation["latitude"] : null}'),
                    // Text(
                    //     'LOCATIOOON : Lat/Lng:${currentLocation != null && currentLocation.containsKey('longitude') ? currentLocation["longitude"] : null}')
                  ],
                ),
              ),
            ),
          )),
    ));
  }
}
