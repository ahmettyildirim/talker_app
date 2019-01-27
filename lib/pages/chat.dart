import 'package:flutter/material.dart';
import 'package:talker_app/common/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:toast/toast.dart';

class Chat extends StatelessWidget {

  Chat({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key key,
   
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key});

  UserModel user = UserModelRepository.currentUser;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  bool isLoading = false;
  bool isShowSticker = false;
  bool toastShowed = false;
  int latestShowedDateDay = 0;
  var listMessage;
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('conversations')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'senderId': user.uid,
            'sender': user.displayName,
            'text': content,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Toast.show("Nothing to send", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['senderId'] == user.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['senderId'] != user.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    String content = document.data["text"];
    String senderId = document.data["senderId"];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(document.data['timestamp']));
    if (date.day != DateTime.now().day && date.day != latestShowedDateDay) {
      Toast.show('${date.day}.${date.month}.${date.year}', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
      latestShowedDateDay = date.day;
    }
    // Right (my message)
    return Row(
      children: <Widget>[
        Container(
          child: Column(children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(
                 document.data["sender"] ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),
            SizedBox(
              height: 7.0,
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(
                  content,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(
                  "${date.hour}:${date.minute}",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          ]),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          width: 200.0,
          decoration: BoxDecoration(
              color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
        )
      ],
      mainAxisAlignment: senderId == user.uid
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
    );
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
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
                  hintText: 'Type your message...',
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

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('conversations')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}