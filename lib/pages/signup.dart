import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/functions/auth_provider.dart';
import 'package:talker_app/common/functions/validations.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:toast/toast.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  SignUpPage({this.onSignedIn});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AnimationController _controller;
  String _email;
  String _password;
  String _passwordRepeat;
  String _displayName;
  String _photoUrl;
  void signUp() async {
    var auth = AuthProvider.of(context).auth;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      UserModel user = await auth.createNewUser(
          email: _email, password: _password,displayName: _displayName);
      if(user != null){
        widget.onSignedIn();
        Navigator.pop(context);
      }
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new ExactAssetImage('assets/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.only(top: 60.0, left: 20, right: 20),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Registration Form",
                      style: TextStyle(
                          color: greyColor,
                          fontFamily: 'Roboto',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                    validator: Validations.validateEmail,
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
                    validator: Validations.validatePass,
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
                        color: inputIconColor,
                        size: 20.0,
                      ),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                    validator: Validations.validatePass,
                    obscureText: true,
                    style: genericTextStyle,
                    onSaved: (String val) {
                      _password = val;
                    },
                    decoration: InputDecoration(
                      labelText: "Password Repeat",
                      labelStyle: genericTextStyle,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: inputIconColor,
                        size: 20.0,
                      ),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                    validator: Validations.validatePass,
                    style: genericTextStyle,
                    onSaved: (String val) {
                      _displayName = val;
                    },
                    decoration: InputDecoration(
                      labelText: "Display Name",
                      labelStyle: genericTextStyle,
                      prefixIcon: Icon(
                        Icons.account_box,
                        color: inputIconColor,
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
                      'Signup',
                      style: TextStyle(color: Color(0xfff9f9f9)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        // If the form is valid, we want to show a Snackbar
                        signUp();
                      }
                    },
                  ),
                ],
              )
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
