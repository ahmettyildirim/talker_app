import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talker_app/common/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:talker_app/pages/home.dart';
import 'package:talker_app/widgets/google_signin.dart';
import 'package:talker_app/widgets/login_form.dart';
import 'package:toast/toast.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  var currentLocation = <String, double>{};
  var location = new Location();
  bool isLoggedIn = false;
  SharedPreferences prefs;
  FirebaseAuth auth;
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

    isSignedIn();
  }

  void isSignedIn() async {
    try {
      GoogleSignIn _googleSignIn = new GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      FirebaseUser user;
      prefs = await SharedPreferences.getInstance();
      bool isSignedIn = await _googleSignIn.isSignedIn();

      if (isSignedIn) {
        GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        await FirebaseAuth.instance.reauthenticateWithGoogleCredential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      } else {
        var id = prefs.getString('id') ?? '';
        if (id.isNotEmpty) {
          await FirebaseAuth.instance.reauthenticateWithEmailAndPassword(
              email: prefs.getString("email"),
              password: prefs.getString("password"));
        }
      }
      user = await FirebaseAuth.instance.currentUser();
      if (user != null)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user)),
        );
    } catch (e) {}
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
                     
                        LoginForm(),
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
                  ],
                ),
              ),
            ),
          )),
    ));
  }
}
