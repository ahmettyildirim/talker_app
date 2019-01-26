import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/pages/home.dart';
import 'package:toast/toast.dart';

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  final TextEditingController _resetEmailController =
      new TextEditingController();
   void login() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      FirebaseUser user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _email, password: _password);
      Toast.show("Logged in successfully", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(user,
                  )));
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              style: genericTextStyle,
              onSaved: (String val) {
                _email = val;
              },
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: genericTextStyle,
                prefixIcon: Icon(
                  Icons.email,
                  color: Color(0xf9f9f9f9),
                  size: 20.0,
                ),
              )),
          SizedBox(
            height: 10.0,
          ),
          TextFormField(
              validator: _validatePass,
              obscureText: true,
              style: genericTextStyle,
              onSaved: (String val) {
                _password = val;
              },
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: genericTextStyle,
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color(0xf9f9f9f9),
                  size: 20.0,
                ),
              )),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  RaisedButton(
                    // shape: shapeBorderroundedWith30,
                    color: Color(0xff),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Color(0xfff9f9f9)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        // If the form is valid, we want to show a Snackbar
                        login();
                        }
                    },
                  ),
                  FlatButton(
                    child: Text(
                      "Forgot Password?",
                      softWrap: true,
                      style: loginFlatButtonStyle,
                    ),
                    onPressed: () {
                      Alert(
                          context: context,
                          title: "Reset Pasword",
                          content: Column(
                            children: <Widget>[
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _resetEmailController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.account_circle),
                                  labelText: 'Enter your mail',
                                ),
                              ),
                            ],
                          ),
                          buttons: [
                            DialogButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // resetPassword(_resetEmailController.text);
                              },
                              color: Color(0xffD63031),
                              child: Text(
                                "Reset Password",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            )
                          ]).show();
                    },
                  ),
                ],
              )
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please Enter Your Email';
    }
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please Enter Valid Email';
    else
      return null;
  }

  String _validatePass(String value) {
    if (value.isEmpty) {
      return 'Please Enter Your Password';
    }
  }
}
