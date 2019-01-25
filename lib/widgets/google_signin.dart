import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:toast/toast.dart';

class SignInWithGoogle extends StatefulWidget {
  _SignInWithGoogleState createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {

  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  void signIn() async{
      try {
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
          MaterialPageRoute(
              builder: (context) => Chat(
                   user: user,
                  )));
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
          shape: shapeBorderroundedWith30,
          onPressed: signIn,
          child: Text(
            'SIGN IN WITH GOOGLE',
            style: TextStyle(fontSize: 16.0),
          ),
          color: Color(0xffdd4b39),
          highlightColor: Color(0xffff7f7f),
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
    );
  }
}
