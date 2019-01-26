import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talker_app/pages/home.dart';
import 'package:toast/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInWithGoogle extends StatefulWidget {
  _SignInWithGoogleState createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {
  static final GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final FirebaseAuth _fAuth = FirebaseAuth.instance;

  void signIn() async {
    try {
      var account = await _googleSignIn.isSignedIn();
      Toast.show("User has logged in: $account", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      // if (account) {
      //   GoogleSignInAccount disabled = await _googleSignIn.disconnect();
      //         Toast.show("User has logged out", context,
      //     duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      //   return;

      // }

      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      FirebaseUser user = await _fAuth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      Toast.show("Logged in successfully", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      Navigator.push(
          context,
          // MaterialPageRoute(
          //     builder: (context) => Chat(
          //           user: user,
          //         )));
          MaterialPageRoute(
              builder: (context) => HomePage(user
                  )));
                  
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        minWidth: null,
        elevation: 2.0,
        padding: const EdgeInsets.all(3.0),
        color: Color(0xFFDD4B39),
        onPressed: signIn,
        splashColor: Colors.white30,
        child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.5,
            ),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 20),
                    child: Icon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Sign in With Google",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            )));
  }
  // Container(
  //   child: FlatButton(
  //       // shape: shapeBorderroundedWith30,
  //       onPressed: signIn,
  //       child: Text(
  //         'SIGN IN WITH GOOGLE',
  //         style: TextStyle(fontSize: 16.0),
  //       ),
  //       color: Color(0xffdd4b39),
  //       highlightColor: Color(0xffff7f7f),
  //       splashColor: Colors.transparent,
  //       textColor: Colors.white,
  //       padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
  // );
}
