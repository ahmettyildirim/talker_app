import 'package:flutter/material.dart';
import 'package:talker_app/common/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talker_app/pages/signup.dart';
import 'package:talker_app/widgets/google_signin.dart';
import 'package:talker_app/widgets/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  LoginPage({this.onSignedIn});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  SharedPreferences prefs;
  FirebaseAuth auth;

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
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 230.0,
                          height: 230.0,
                          alignment: Alignment.center,
                          decoration: new BoxDecoration(
                            image: DecorationImage(
                              image: new ExactAssetImage('assets/logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        LoginForm(
                          onSignedIn: widget.onSignedIn,
                        ),
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
                              onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage(onSignedIn: widget.onSignedIn)));
                              }
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
                        SizedBox(
                            width: 400.0,
                            child: SignInWithGoogle(
                              onSignedIn: widget.onSignedIn,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    ));
  }
}
