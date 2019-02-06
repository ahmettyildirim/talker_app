import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/functions/data_repository.dart';
import 'package:talker_app/common/models/conversation_model.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/common/string_values.dart';
import 'package:talker_app/pages/map.dart';
import 'package:talker_app/pages/maps_location.dart';
import 'package:toast/toast.dart';

class Chat extends StatefulWidget {
  final String roomId;
  final String title;
  Chat({Key key, @required this.roomId, this.title = ""}) : super(key: key);
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  double sliderValue = 0.0;
  onChanged(double value) {
    setState(() {
      sliderValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        appBar: AppBar(
          title: new Text(
            widget.title == null ? "" : widget.title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: 'Change distsance',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                            title: const Text('Set Distanceees'),
                            content: Container(
                              height: 200.0,
                              child: Column(
                                children: <Widget>[
                                  Slider(
                                    min: 0.0,
                                    max: 5000.0,
                                    divisions: 20,
                                    value: sliderValue,
                                    label: sliderValue.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        sliderValue = value;
                                      });
                                    },
                                  ),
                                  Text(
                                      "Current distance is :$sliderValue meters"),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  child: const Text('Cancesl'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              FlatButton(
                                  child: const Text('Save'), onPressed: () {})
                            ]));
              },
            ),
          ],
        ),
        body: ChatScreen(roomId: widget.roomId),
      ),
    );
  }

  Future<bool> _backButtonPressed() async {
    DataRepository.instance.removeUserActiveRoom();
    return Future.value(true);
  }
}
// class Chat extends StatelessWidget {
//   final String roomId;
//   final String title;
//   Chat({Key key, @required this.roomId, this.title = ""}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _backButtonPressed,
//       child: Scaffold(
//         appBar: AppBar(
//           // title: new Text(
//           //   title == null ? "" : title,
//           //   style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
//           // ),
//           // centerTitle: true,
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.settings),
//               tooltip: 'Change distance',
//               onPressed: () {
//                   showDialog(
//                       context: context,
//                       builder: (BuildContext context) => AlertDialog(
//                               title: const Text('Set Distance'),
//                               content:
//                               Slider(

//                                 min: 0.0,
//                                 max: 5000.0,
//                                 value: 500.0,
//                                 onChanged: (value){},),
//                               actions: <Widget>[
//                                 FlatButton(
//                                     child: const Text('Cancel'),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     }),
//                                 FlatButton(
//                                     child: const Text('Save'),
//                                     onPressed: () {

//                                     })
//                               ]));
//                 },
//             ),

//           ],
//         ),
//         body: ChatScreen(roomId: roomId),
//       ),
//     );
//   }

//   Future<bool> _backButtonPressed() async {
//     DataRepository.instance.removeUserActiveRoom();
//     return Future.value(true);
//   }
// }

class ChatScreen extends StatefulWidget {
  final String roomId;
  ChatScreen({Key key, this.roomId}) : super(key: key);

  @override
  State createState() => new ChatScreenState(roomId: roomId);
}

class ChatScreenState extends State<ChatScreen> {
  final String roomId;
  ChatScreenState({Key key, this.roomId});

  final DataRepository _dataInstance = DataRepository.instance;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isLoading = false;
  double sliderValue = 500.0;

  List<DocumentSnapshot> listMessage;

  void onSendMessage(String content, int type) async {
    if (content.trim() != '') {
      textEditingController.clear();

      var newConversation = ConversationModel(
        senderId: UserModelRepository.instance.currentUser.uid,
        sender: UserModelRepository.instance.currentUser.displayName,
        text: content,
        roomId: roomId,
      );
      await _dataInstance.sendNewMessage(newConversation);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Toast.show("Nothing to send", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  bool showAvatar(int index) {
    var length = listMessage.length;
    // int index = ((i-length)+2) * (-1);

    if (index == length - 1 ||
        (index >= 0 &&
            listMessage != null &&
            listMessage[index + 1][FieldKeys.senderId] !=
                listMessage[index][FieldKeys.senderId])) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1][FieldKeys.senderId] !=
                UserModelRepository.instance.currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _dataInstance.addUserActiveRoom(roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffdcdcdc),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              // Input content
              buildInput(),
            ],
          ),
          // Loading
          buildLoading(),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: 2.5,
                      spreadRadius: 5.0,
                      color: Colors.black.withOpacity(.12))
                ],
                color: Color(0xFFA4B0BD),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              height: 50.0,
              child: Column(
                children: <Widget>[
                  Slider(
                    min: 0.0,
                    max: 5000.0,
                    divisions: 50,
                    value: sliderValue,
                    label: sliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        sliderValue = value;
                      });
                    },
                  ),
                  Text("Current distance is :$sliderValue meters"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: _dataInstance.getConversationsOnChatRoom(
            roomId: roomId, distance: sliderValue),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            isLoading = false;
            listMessage = snapshot.data;
            listMessage.sort((a, b) =>
                a.data["timestampInt"].compareTo(b.data["timestampInt"]) *
                (-1));
            listMessage = listMessage.reversed.toList();
            _dataInstance.updateRoomLastAccessTime(roomId);
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data[index]),
              itemCount: snapshot.data.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(int index, dynamic document) {
    final message = ConversationModel.fromSnapshot(document);
    String senderId = message.senderId;
    DateTime date = message.timestamp;
    return Container(
      padding: EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment:
            senderId == UserModelRepository.instance.currentUser.uid
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          showAvatar(index)
              ? photoLayout(message,
                  senderId == UserModelRepository.instance.currentUser.uid)
              : Container(),
          messageLayout(
              message, senderId != UserModelRepository.instance.currentUser.uid)
        ],

        // senderId == _currentUser.uid
        //     ? getSentMessageLayout(message, showAvatar(index))
        //     : getReceivedMessageLayout(message, showAvatar(index)),

        // <Widget>[
        // Container(
        //   child: Column(children: <Widget>[
        //     SizedBox(
        //       width: double.infinity,
        //       child: Container(
        //         child: Text(
        //           message.sender,
        //           textAlign: TextAlign.left,
        //           style: TextStyle(
        //               color: Colors.indigo,
        //               fontWeight: FontWeight.w400,
        //               fontSize: 12.0,
        //               fontStyle: FontStyle.italic),
        //         ),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 7.0,
        //     ),
        //     SizedBox(
        //       width: double.infinity,
        //       child: Container(
        //         child: Text(
        //           content,
        //           textAlign: TextAlign.left,
        //           style: TextStyle(color: primaryColor),
        //         ),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 5.0,
        //     ),
        //     SizedBox(
        //       width: double.infinity,
        //       child: Container(
        //         child: Text(
        //           "${date.hour}:${date.minute}",
        //           textAlign: TextAlign.right,
        //           style: TextStyle(color: Colors.grey),
        //         ),
        //       ),
        //     )
        //   ]),
        //   padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        //   width: 200.0,
        //   decoration: BoxDecoration(
        //       color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
        //   margin: EdgeInsets.only(
        //       bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
        // )
        // ],
        mainAxisAlignment:
            senderId == UserModelRepository.instance.currentUser.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
      ),
    );
  }

  List<Widget> getReceivedMessageLayout(
      ConversationModel model, bool showPhoto) {
    return <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showPhoto
              ? Container(
                  child: Row(
                  children: <Widget>[
                    Container(
                        margin: new EdgeInsets.only(
                            left: 0.0, top: 0.0, bottom: 10.0, right: 5.0),
                        width: 40.0,
                        height: 40.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: UserModelRepository
                                    .instance.currentUser.photoUrl.isEmpty
                                ? DecorationImage(
                                    image: ExactAssetImage('assets/user.png'),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: ExactAssetImage('assets/user.png'),
                                    fit: BoxFit.cover,
                                  ))),
                    Text(model.sender)
                  ],
                ))
              : Container(),
          showPhoto
              ? Container(
                  margin: new EdgeInsets.only(
                      left: 0.0, top: 0.0, bottom: 10.0, right: 5.0),
                  width: 40.0,
                  height: 40.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: UserModelRepository
                              .instance.currentUser.photoUrl.isEmpty
                          ? DecorationImage(
                              image: ExactAssetImage('assets/user.png'),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: ExactAssetImage('assets/user.png'),
                              fit: BoxFit.cover,
                            )))
              : Container(),
        ],
      ),
      Container(
        margin: showPhoto
            ? const EdgeInsets.only(top: 20.0)
            : const EdgeInsets.only(left: 55.0),
        padding: const EdgeInsets.only(
            left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 2.5,
                spreadRadius: 5.0,
                color: Colors.black.withOpacity(.12))
          ],
          color: Color(0xFFF0DF87),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            showPhoto
                ? Text(model.sender,
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold))
                : Container(),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(model.text),
            ),
          ],
        ),
      ),
    ];
  }

  Widget getDistance(ConversationModel model) {
    Geoflutterfire geo = Geoflutterfire();
    // return FutureBuilder<double>(

    //     future: Geolocator().distanceBetween(
    //         model.geoPoint.latitude,
    //         model.geoPoint.longitude,
    //         UserModelRepository.instance.currentUser.currentLocation.latitude,
    //         UserModelRepository.instance.currentUser.currentLocation
    //             .longitude), // a previously-obtained Future<String> or null
    //     builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
    //       switch (snapshot.connectionState) {
    //         case ConnectionState.none:
    //           return Text('Press button to start.');
    //         case ConnectionState.active:
    //         case ConnectionState.waiting:
    //           return Text('Distance calculating');
    //         case ConnectionState.done:
    //           if (snapshot.hasError) return Text('Error: ${snapshot.error}');
    //           return Text("${snapshot.data.floor()} meters away");
    //       }
    //       return null; // unreachable
    //     });
    double distance = geo
        .point(
            latitude: model.geoPoint.latitude,
            longitude: model.geoPoint.longitude)
        .distance(
            lat: UserModelRepository
                .instance.currentUser.currentLocation.latitude,
            lng: UserModelRepository
                .instance.currentUser.currentLocation.longitude);
    return Text("${(distance * 1000).floor()} meters away");
  }

  Widget messageLayout(ConversationModel model, bool isLeft) {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    // BubbleScreen()
                    GoogleMapLocation(
                        latitude: model.geoPoint.latitude,
                        longitude: model.geoPoint.longitude)));
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: const Text('Distance'),
                    content: getDistance(model),
                    actions: <Widget>[
                      FlatButton(
                          child: const Text('Ok'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ]));
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 200.0,
          minWidth: 120.0,
        ),
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 2.5,
                spreadRadius: 5.0,
                color: Colors.black.withOpacity(.12))
          ],
          color: isLeft ? Color(0xFFF0DF87) : Color(0xFFEAF0F1),
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? Radius.circular(7.0) : Radius.circular(10.0),
            bottomLeft: isLeft ? Radius.circular(7.0) : Radius.circular(20.0),
            bottomRight: isLeft ? Radius.circular(20.0) : Radius.circular(7.0),
            topRight: isLeft ? Radius.circular(10.0) : Radius.circular(7.0),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 48.0, bottom: 3),
              child: Text(model.text + " "),
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Row(
                children: <Widget>[
                  Text("${model.timestamp.hour}:${model.timestamp.minute}",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 13.0,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget photoLayout(ConversationModel model, bool isRight) {
    return Column(
      children: <Widget>[
        Row(
          textDirection: isRight ? TextDirection.rtl : TextDirection.ltr,
          children: <Widget>[
            Container(
                height: 40.0,
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  // boxShadow: [
                  //   BoxShadow(
                  //       blurRadius: 2.5,
                  //       spreadRadius: 5.0,
                  //       color: Colors.black.withOpacity(.12))
                  // ],
                  color: Color(0xFF192A56),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  model.sender,
                  style: TextStyle(color: Color(0xfff2f2f2)),
                )),
            Container(
                margin: new EdgeInsets.only(
                    left: 5.0, top: 0.0, bottom: 0.0, right: 5.0),
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: isRight
                          ? NetworkImage(
                              UserModelRepository.instance.currentUser.photoUrl)
                          : ExactAssetImage('assets/user.png'),
                      fit: BoxFit.cover,
                    ))),
          ],
        ),
        SizedBox(
          height: 5.0,
        )
      ],
    );
  }

  List<Widget> getSentMessageLayout(ConversationModel model, bool showPhoto) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 2.5,
                spreadRadius: 5.0,
                color: Colors.black.withOpacity(.12))
          ],
          color: Color(0xFFEAF0F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        width: 200.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            showPhoto
                ? Text(model.sender,
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold))
                : Container(),
            new Container(
              margin: const EdgeInsets.only(top: 3.0),
              child: Text(model.text),
            ),
          ],
        ),
      ),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          showPhoto
              ? Container(
                  margin: new EdgeInsets.only(
                      left: 0.0, top: 0.0, bottom: 10.0, right: 5.0),
                  width: 40.0,
                  height: 40.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: ExactAssetImage('assets/user.png'),
                        fit: BoxFit.cover,
                      )))
              : Container(),
        ],
      ),
    ];
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 10.0),
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: StringValues.chatTypeMessage,
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }
}
