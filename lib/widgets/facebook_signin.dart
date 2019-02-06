// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import 'package:talker_app/common/constants.dart';
// import 'package:talker_app/pages/chat.dart';
// import 'package:toast/toast.dart';

// class SignInWithFacebook extends StatefulWidget {
//   _SignInWithFacebookState createState() => _SignInWithFacebookState();
// }

// class _SignInWithFacebookState extends State<SignInWithFacebook> {
//   final FirebaseAuth _fAuth = FirebaseAuth.instance;
//   static final FacebookLogin facebookSignIn = new FacebookLogin();
//   void signIn() async {
//     try {
//       final FacebookLoginResult result =
//           await facebookSignIn.logInWithReadPermissions(['email']);

//       FirebaseUser user = await _fAuth.signInWithFacebook(
//           accessToken: result.accessToken.token);
//       //Token: ${accessToken.token}

//       Toast.show("Logged in successfully", context,
//           duration: Toast.LENGTH_LONG, gravity: Toast.TOP);

//      Navigator .push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => Chat(
//                     user: user,
//                   )));
//     } catch (e) {
//       Toast.show(e.message, context,
//           duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: FlatButton(
//           shape: shapeBorderroundedWith30,
//           onPressed: signIn,
//           child: Text(
//             'SIGN IN WITH FACEBOOK',
//             style: TextStyle(fontSize: 16.0),
//           ),
//           color: Color(0xff3b5998),
//           highlightColor: Color(0xffff7f7f),
//           splashColor: Colors.transparent,
//           textColor: Colors.white,
//           padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
//     );
//   }
// }
