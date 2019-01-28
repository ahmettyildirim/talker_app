import 'package:flutter/material.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/common/functions/auth_provider.dart';
import 'package:talker_app/common/functions/base_auth.dart';
import 'package:toast/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInWithGoogle extends StatefulWidget {
  final VoidCallback onSignedIn;
  SignInWithGoogle({this.onSignedIn});
  _SignInWithGoogleState createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {

  void signIn() async {
    try {
      var auth = AuthProvider.of(context).auth;
      UserModel user = await auth.signInWithProvider(Providers.Google);
      user.photoUrl= await user.getPhotoUrl(user.uid);
      
      if(user!=null){
          widget.onSignedIn();
      }
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
