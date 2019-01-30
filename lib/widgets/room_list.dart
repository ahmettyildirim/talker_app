// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show lowerBound;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:talker_app/widgets/bottom_navigation.dart';
import 'package:uuid/uuid.dart';

enum RoomListTabAction { reset, horizontalSwipe, leftSwipe, rightSwipe }

class RoomListTab extends StatefulWidget {
  const RoomListTab(
      {Key key, this.scaffoldKey, this.tabItem, this.onlyMyRoom = false})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TabItem tabItem;
  final bool onlyMyRoom;
  static const String routeName = '/material/leave-behind';

  @override
  RoomListTabState createState() => RoomListTabState();
}

class RoomListTabState extends State<RoomListTab> {
  DismissDirection _dismissDirection = DismissDirection.horizontal;
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();
  final TextEditingController roomNamecontroller = TextEditingController();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text("");
  var listMessage;

 RoomListTabState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }


  void getAllRooms() {}

  Widget buildListMessage() {
    return StreamBuilder(
      stream: widget.onlyMyRoom
          ? Firestore.instance.collection('rooms').where("users", arrayContains: UserModelRepository.instance.currentUser.uid).snapshots() :
         Firestore.instance.collection('rooms').snapshots(),
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
              return 
               _RoomListItem(
                snapShot: item,
                onArchive: _handleArchive,
                onDelete: _handleDelete,
                dismissDirection: _dismissDirection,
                searchText: _searchText,
              );
            
            }).toList(),
          );
        }
      },
    );
  }

  void handleDemoAction(RoomListTabAction action) {
    setState(() {
      switch (action) {
        case RoomListTabAction.reset:
          break;
        case RoomListTabAction.horizontalSwipe:
          _dismissDirection = DismissDirection.horizontal;
          break;
        case RoomListTabAction.leftSwipe:
          _dismissDirection = DismissDirection.endToStart;
          break;
        case RoomListTabAction.rightSwipe:
          _dismissDirection = DismissDirection.startToEnd;
          break;
      }
    });
  }

  Future<void> _handleArchive(String roomId) async {
    var roomReference = Firestore.instance.collection('rooms').document(roomId);
    await roomReference.updateData(
      {
        'users': FieldValue.arrayUnion(
            [UserModelRepository.instance.currentUser.uid]),
      },
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => Chat(roomId:roomId)));
    // widget.scaffoldKey.currentState.showSnackBar(SnackBar(
    //     content: Text('You\'ve entered new room'),
    //     action: SnackBarAction(
    //         label: 'UNDO',
    //         onPressed: () {
    //           _handleDelete(roomId);
    //         })));
  }

  Future<void> _handleDelete(String roomId) async {
    try {
      var roomReference =
          Firestore.instance.collection('rooms').document(roomId);

      await roomReference.updateData(
        {
          'users': FieldValue.arrayRemove(
              [UserModelRepository.instance.currentUser.uid]),
        },
      );
      // setState(() {
      //   leaveBehindItems.remove(item);
      // });
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

  Future<void> _handleAddNewRoom(BuildContext context, String roomName) async {
    try {
      String uuid = Uuid().v1();
      String userId = UserModelRepository.instance.currentUser.uid;
      var documentReference =
          Firestore.instance.collection('rooms').document(uuid);
      await documentReference.setData({
        'roomId': uuid,
        'ownerId': userId,
        'name': roomName,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'users': [userId]
      });
      var userReference =
          Firestore.instance.collection('users').document(userId);
      await userReference.updateData(
        {
          'rooms': FieldValue.arrayUnion([uuid]),
        },
      );
      Navigator.pop(context);
    } catch (e) {}
  }


  Widget _buildBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new AppBar(
      centerTitle: true,
      backgroundColor: theme.selectedRowColor,
      title: TextField(
          controller: _filter,
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search),
            hintText: 'Search...'
          ),
      ),
      elevation: 0.0,
      
    );
  }
  
 
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget body;
    body = Scaffold(
        appBar:  _buildBar(context) ,
        floatingActionButton: widget.tabItem == TabItem.allRooms
            ? FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: theme.primaryColor,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                              title: const Text('Creating New Room'),
                              content: TextFormField(
                                controller: roomNamecontroller,
                                decoration: InputDecoration(
                                  labelText: "New Room Name",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(
                                    Icons.cloud_circle,
                                    color: Colors.grey,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                FlatButton(
                                    child: const Text('Create'),
                                    onPressed: () {
                                      _handleAddNewRoom(
                                          context, roomNamecontroller.text);
                                    })
                              ]));
                })
            : null,
        body: buildListMessage());
    return body;
  }
}

class _RoomListItem extends StatelessWidget {
  const _RoomListItem({
    Key key,
    @required this.snapShot,
    @required this.onArchive,
    @required this.onDelete,
    @required this.dismissDirection,
    this.searchText = "",
  }) : super(key: key);

  final DocumentSnapshot snapShot;
  final String searchText;
  final DismissDirection dismissDirection;
  final Future<void> Function(String) onArchive;
  final Future<void> Function(String) onDelete;

  Future<void> _handleArchive() async {
    onArchive(snapShot["roomId"]);
  }

  Future<void> _handleDelete() async {
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
      child: !snapShot["name"].toString().contains(searchText) ? 
      null:
      Dismissible(
        key: ObjectKey(snapShot),
        direction: dismissDirection,
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.endToStart) {
            _handleArchive();
          } else
            _handleDelete();
          // Scaffold.of(context)
          //           .showSnackBar(SnackBar(content: Text("snackbar")));
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
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            roomId: snapShot["roomId"],
                            title: snapShot["name"],
                          )));
            },
            child: ListData(
                title: snapShot["name"],
                subtitle:
                    '${snapShot["users"].length.toString()} user${snapShot["users"].length > 1 ? 's are' : ' is'} online in this room',
                image: DecorationImage(
                  image: new ExactAssetImage('assets/room.png'),
                  fit: BoxFit.cover,
                )),
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
