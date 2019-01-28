import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedOut;
  // final UserModel _user;

  HomePage({this.onSignedOut});
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserModel _user;
  File image;

  Future<void> logOut() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    await FirebaseAuth.instance.signOut();
    bool isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    }
    UserModelRepository.instance.clearCurrentUser();
    widget.onSignedOut();
  }

  picker() async {
    print('Picker is called');
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        image = img;
      });
    }
  }

  Future<String> _pickSaveImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("${UserModelRepository.instance.currentUser.uid}_avatar.jpg ");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();
    print(url);

    var documentReference = Firestore.instance
        .collection('users')
        .document(UserModelRepository.instance.currentUser.uid);
    var doc = await documentReference.get();
    if(doc.data ==null){
      await documentReference.setData({'photoUrl': url,});
    }else{
      await documentReference.updateData({'photoUrl': url,});
    }
    // Firestore.instance.runTransaction((transaction) async {
    //   await transaction.set(
    //     documentReference,
    //     {
    //       'uid': UserModelRepository.instance.currentUser.uid,
    //       'photoUrl': url,
    //     },
    //   );
    // });

    setState(() {
      UserModelRepository.instance.currentUser.photoUrl = url;
    });

    return url;
  }

  @override
  Widget build(BuildContext context) {
    _user = UserModelRepository.instance.currentUser;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: picker,
      ),
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
                  _pickSaveImage();
                },
                child: _user.photoUrl == null || _user.photoUrl == ""
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            _user.photoUrl == null ? '' : _user.photoUrl),
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
        child: image == null
            ? new Text('No Image to Show ')
            : new Image.file(image),
      )),
    );
  }
}
