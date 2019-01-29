// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show lowerBound;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/widgets/bottom_navigation.dart';
import 'package:uuid/uuid.dart';

enum UserListTabAction { reset, horizontalSwipe, leftSwipe, rightSwipe }



class UserListTab extends StatefulWidget {
  const UserListTab({Key key, this.scaffoldKey, this.tabItem})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TabItem tabItem;
  static const String routeName = '/material/leave-behind';

  @override
 UserListTabState createState() =>UserListTabState();
}

class UserListTabState extends State<UserListTab> {
  DismissDirection _dismissDirection = DismissDirection.horizontal;
  final TextEditingController roomNamecontroller = TextEditingController();
  var listMessage;
  void getAllRooms() {}
  
  Widget buildListMessage() {
    return StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView(
                padding: const EdgeInsets.all(0.0),
              children: listMessage.map<Widget>((dynamic item) {
                return _UserListItem(
                  snapShot: item,
                   onArchive: _handleArchive,
                   onDelete: _handleDelete,
                  dismissDirection: _dismissDirection,
                );
              }).toList(),
            );
          }
        },
    );
  }
  void handleDemoAction(UserListTabAction action) {
    setState(() {
      switch (action) {
        case UserListTabAction.reset:
          break;
        case UserListTabAction.horizontalSwipe:
          _dismissDirection = DismissDirection.horizontal;
          break;
        case UserListTabAction.leftSwipe:
          _dismissDirection = DismissDirection.endToStart;
          break;
        case UserListTabAction.rightSwipe:
          _dismissDirection = DismissDirection.startToEnd;
          break;
      }
    });
  }
  Future<void> _handleArchive (String roomId) async{
      var roomReference =
          Firestore.instance.collection('rooms').document(roomId);
      await roomReference.updateData(
        {
          'users':FieldValue.arrayUnion([UserModelRepository.instance.currentUser.uid]),
        },
      );
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('You\'ve entered new room'),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              _handleDelete(roomId);
            })));
  }
  Future<void> _handleDelete(String roomId) async{
    try {
      
     var roomReference =
      Firestore.instance.collection('rooms').document(roomId);
      
      await roomReference.updateData(
        {
          'users':FieldValue.arrayRemove([UserModelRepository.instance.currentUser.uid]),
        },
      );
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('You\'ve left from room'),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              _handleArchive(roomId);
            })));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
   
      body = Scaffold(
          body: buildListMessage());
    return body;
  }
}

class _UserListItem extends StatelessWidget {
  const _UserListItem({
    Key key,
    @required this.snapShot,
    @required this.onArchive,
    @required this.onDelete,
     @required this.dismissDirection,
  }) : super(key: key);

  final DocumentSnapshot snapShot;
  final DismissDirection dismissDirection;
  final Future<void> Function(String) onArchive;
  final Future<void> Function(String) onDelete;

  Future<void> _handleArchive() async{
     onArchive(snapShot["roomId"]);
  }

  Future<void> _handleDelete() async{
     onDelete(snapShot["roomId"]);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        const CustomSemanticsAction(label: 'Archive'): _handleArchive,
        const CustomSemanticsAction(label: 'Delete'): _handleDelete,
      },
      child: Dismissible(
        key: ObjectKey(snapShot),
        direction: dismissDirection,
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.endToStart)
            _handleArchive();
          else
            _handleDelete();
        },
        background: Container(
            color: theme.primaryColor,
            child: const ListTile(
                leading: Icon(Icons.delete, color: Colors.grey, size: 36.0))),
        secondaryBackground: Container(
            color: theme.primaryColor,
            child: const ListTile(
                trailing: Icon(Icons.archive, color: Colors.grey, size: 36.0))),
        child: Container(
          decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor))),
          child: ListData(
              title: snapShot["displayName"] ?? "",
              subtitle:  snapShot["email"],
              image: snapShot["photoUrl"] == null ? DecorationImage(
                  image: ExactAssetImage('assets/user.png'),
                  fit: BoxFit.cover,
                ): DecorationImage(
                  image: NetworkImage(snapShot["photoUrl"]),
                  fit: BoxFit.cover,
                )
            ),
        ),
      ),
    );
  }
}

class ListData extends StatelessWidget {
  final EdgeInsets margin;
  final double width;
  final String title;
  final String subtitle;
  final DecorationImage image;
  ListData({this.margin, this.subtitle, this.title, this.width, this.image});
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return (new Container(
      alignment: Alignment.center,
      margin: margin,
      width: width,
      decoration: new BoxDecoration(
        color: theme.selectedRowColor,
        border: new Border(
          top: new BorderSide(
              width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
          bottom: new BorderSide(
              width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
        ),
      ),
      child: new Row(
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.only(
                  left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
              width: 60.0,
              height: 60.0,
              decoration:
                  new BoxDecoration(shape: BoxShape.circle, image: image)),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                title,
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
              new Padding(
                padding: new EdgeInsets.only(top: 5.0),
                child: new Text(
                  subtitle,
                  style: new TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300),
                ),
              )
            ],
          )
        ],
      ),
    ));
  }
}
