import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final FirebaseUser _user;
  HomePage(this._user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
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
                  backgroundImage: NetworkImage(_user.photoUrl),
                  backgroundColor: Colors.grey,
                ),
              ),
              accountName: Text(_user.displayName),
              accountEmail: Text(_user.email),
            ),
            ListTile(
              title: Text("Search Rooms"),
              trailing: Icon(Icons.search),
            ),
            ListTile(
              title: Text("Conversations"),
              trailing: Icon(Icons.chat),
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
