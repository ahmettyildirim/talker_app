import 'package:flutter/material.dart';
import 'package:talker_app/common/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talker_app/common/functions/data_repository.dart';
import 'package:talker_app/common/models/conversation_model.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/common/string_values.dart';
import 'package:toast/toast.dart';

class Chat extends StatelessWidget {
  final String roomId;
  final String title;
  Chat({Key key, @required this.roomId, this.title = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _backButtonPressed,
          child: Scaffold(
        appBar: AppBar(
          title: new Text(
            title == null ? "" : title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ChatScreen(roomId: roomId),
      ),
    );
  }
  Future<bool> _backButtonPressed()async {
    DataRepository.instance.removeUserActiveRoom();
    return Future.value(true);
   }
}
class ChatScreen extends StatefulWidget {
  final String roomId;
  ChatScreen({Key key, this.roomId}) : super(key: key);

  @override
  State createState() => new ChatScreenState(roomId: roomId);
}
class ChatScreenState extends State<ChatScreen> {
  final String roomId;
  ChatScreenState({Key key, this.roomId});
  
  final UserModel _currentUser = UserModelRepository.instance.currentUser;
  final DataRepository _dataInstance = DataRepository.instance;
  final TextEditingController textEditingController =
      TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isLoading = false;
  var listMessage;
  void onSendMessage(String content, int type)async {
    if (content.trim() != '') {
      textEditingController.clear();
      
      var newConversation = ConversationModel(
          senderId: _currentUser.uid,
          sender: _currentUser.displayName,
          text: content,
          roomId: roomId
      );
      await _dataInstance.sendNewMessage(newConversation);
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
            listMessage[index - 1][FieldKeys.senderId] == _currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1][FieldKeys.senderId] != _currentUser.uid) ||
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
    return 
       Stack(
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
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream:
            _dataInstance.getConversationsOnChatRoom(roomId: roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
             isLoading = false; 
            listMessage = snapshot.data.documents;
            _dataInstance.updateRoomLastAccessTime(roomId);
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

  Widget buildItem(int index, dynamic document) {
    final message = ConversationModel.fromSnapshot(document);
    String content = message.text;
    String senderId = message.senderId;
    DateTime date = message.timestamp;
    return Row(
      children: <Widget>[
        Container(
          child: Column(children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(
                  message.sender,
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
      mainAxisAlignment: senderId == _currentUser.uid
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
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
