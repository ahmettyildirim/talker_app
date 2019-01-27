import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/pages/chat.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedOut;
  // final UserModel _user;

  HomePage({this.onSignedOut});
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserModel _user;
  Future<void> logOut() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    bool isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      _googleSignIn.signOut();
    }
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    UserModelRepository.currentUser=null;
    widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    _user = UserModelRepository.currentUser;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeColor,
      appBar: AppBar(
        title: Text(""),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 1.0 : 0.0,
        leading: new IconButton(
            icon: new Icon(Icons.account_circle),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),
      ),
      drawer: Drawer(
        child: ListView(
          // padding: EdgeInsets.only(left: 10.0, top: 30.0, right: 10.0),
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                onTap: () {
                  print("onTap called.");
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_user.photoUrl == null ? '' : _user.photoUrl),
                  backgroundColor: Colors.grey,
                ),
              ),
              accountName: Text(_user.displayName ?? ""),
              accountEmail: Text(_user.email ?? ""),
            ),
            ListTile(
              title: Text("Search Rooms"),
              trailing: Icon(Icons.search),
            ),
            ListTile(
              title: Text("Conversations"),
              trailing: Icon(Icons.chat),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Chat()));
              },
            ),
            Divider(),
            ListTile(
              title: Text("Account Details"),
              trailing: Icon(Icons.account_circle),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
                title: Text("Logout"),
                trailing: Icon(Icons.exit_to_app),
                onTap: () {
                  logOut();
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
      body: Container(
          child: Center(
        child: Text("Home Page"),
      )),
    );
  }
}
