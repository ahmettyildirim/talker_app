import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talker_app/common/functions/helper.dart';
import 'package:talker_app/common/models/conversation_model.dart';
import 'package:talker_app/common/models/room_model.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

enum SortDirection { Ascending, Descending }

class CollectionKeys {
  static final conversations = "conversations";
  static final messages = "messages";
  static final users = "users";
  static final rooms = "rooms";
}


class FieldKeys {
  static final timestamp = "timestamp";
  static final roomId = "roomId";
  static final rooms = "rooms";
  static final senderId = "senderId";
  static final text = "text";
  static final sender = "sender";
  static final currentRoomId = "currentRoomId";
  static final lastAccessTime = "lastAccessTime";
  static final users = "users";
  static final name = "name";
  static final createdUser = "createdUser";
  static final createdDate = "createdDate";
  static final roomUsers = "roomUsers";
  static final uid = "uid";
  static final email = "email";
  static final displayName = "displayName";
  static final photoUrl = "photoUrl";
  static final phoneNumber = "phoneNumber";
  static final providerId = "providerId";
  static final location = "location";
  
}

class DataRepository {
  static final DataRepository instance = DataRepository();
  final Firestore _firestore = Firestore.instance;
  final UserModelRepository _userModel = UserModelRepository.instance;



  void geofire(roomId)async{
    Geofire.initialize(CollectionKeys.rooms);
    List<String> response;
      // Platform messages may fail, so we use a try/catch PlatformException.
   
      try {
        response = await Geofire.queryAtLocation(_userModel.currentUser.currentLocation.latitude,_userModel.currentUser.currentLocation.longitude, 5);
      } catch (e)  {
        response = ['Failed to get platform version.'];
      }
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
     

  }
  CollectionReference roomReference() => _firestore.collection(CollectionKeys.rooms);
  CollectionReference userReference() => _firestore.collection(CollectionKeys.users);
  DocumentReference _getNewDocumentReference(String collectionName) =>
      _firestore.collection(collectionName).document();
  DocumentReference _getCurrentDocumentReference(String collectionName,String documentId) =>
      _firestore.collection(collectionName).document(documentId);
  DocumentReference _newRoomRef() =>
      _getNewDocumentReference(CollectionKeys.rooms);
  DocumentReference _roomRef(String documentId) =>
      _getCurrentDocumentReference(CollectionKeys.rooms,documentId);
  DocumentReference _userRef() =>
      _getNewDocumentReference(CollectionKeys.users);
  DocumentReference _currentUserRef() =>
      _getCurrentDocumentReference(CollectionKeys.users,_userModel.currentUser.uid);
  DocumentReference _messageRef(String roomId) =>
      _getCurrentDocumentReference(CollectionKeys.rooms,roomId)
          .collection(CollectionKeys.messages)
          .document();
  Future<void> _addNewDocument(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentReference, data);
    });
  }
  //room operations
  Future<void> addNewRoom(RoomModel roomModel)async{
      Map<String, dynamic> model = {
      FieldKeys.name: roomModel.name,
      FieldKeys.createdUser: roomModel.createdUser,
      FieldKeys.createdDate: FieldValue.serverTimestamp(),
      FieldKeys.roomUsers:FieldValue.arrayUnion([_userModel.currentUser.uid])
    };
    return await _addNewDocument(_newRoomRef(),model);
  }

  Stream<QuerySnapshot> getRooms() =>roomReference().snapshots();
      
  
  //user operations

  Stream<QuerySnapshot> getAllUsers() =>userReference().snapshots();
      

  //message operations
 
  Stream<QuerySnapshot> getConversationsOnChatRoom(
      {String roomId, SortDirection direction = SortDirection.Ascending}) {
    // return !isNullEmpty(roomId)
    //     ? _firestore
    //         .collection(CollectionKeys.conversations)
    //         .where(FieldKeys.roomId, isEqualTo: roomId)
    //         .orderBy(FieldKeys.timestamp,
    //             descending: direction == SortDirection.Ascending)
    //         .snapshots()
    //     : _firestore
    //         .collection(CollectionKeys.conversations)
    //         .orderBy(FieldKeys.timestamp, descending: true)
    //         .snapshots();
    //geofire(roomId);
      return _roomRef(roomId)
            .collection(CollectionKeys.messages)
            // .where(FieldKeys.location,)
            .orderBy(FieldKeys.timestamp,
                descending: direction == SortDirection.Ascending)
            .snapshots();

  }

  Future<void> sendNewMessage(ConversationModel conversationModel) async {
    var documentReference =
        // _getNewDocumentReference(CollectionKeys.conversations);
    _messageRef(conversationModel.roomId);
    Map<String, dynamic> model = {
      FieldKeys.senderId: conversationModel.senderId,
      FieldKeys.sender: conversationModel.sender,
      FieldKeys.text: conversationModel.text,
      FieldKeys.timestamp: FieldValue.serverTimestamp(),
      FieldKeys.roomId: conversationModel.roomId,
      FieldKeys.location:conversationModel.location
    };
    await _addNewDocument(documentReference, model);
    // DFawait updateLastAccessTime(conversationModel.roomId);
  }
   Future<void> updateRoomLastAccessTime(String roomId) async {
    _currentUserRef().collection(CollectionKeys.rooms).document(roomId).setData({
      FieldKeys.lastAccessTime : FieldValue.serverTimestamp()
    });
  }



//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
  Future<String> getUserActiveRoom() async {
    var user = await _firestore
        .collection(CollectionKeys.users)
        .document(_userModel.currentUser.uid)
        .get();
    return isNullEmpty(user.data[FieldKeys.currentRoomId])
        ? Future.value(null)
        : Future.value(user.data[FieldKeys.currentRoomId]);
  }

  Future<void> removeUserActiveRoom() async {
    String currentRoomId = await getUserActiveRoom();
    if (isNullEmpty(currentRoomId)) {
      return Future.value();
    }
    await _firestore
        .collection(CollectionKeys.users)
        .document(_userModel.currentUser.uid)
        .updateData({FieldKeys.currentRoomId: null});

    await updateLastAccessTime(currentRoomId);
  }

  Future<void> addUserActiveRoom(String roomId) async {
    await _firestore
        .collection(CollectionKeys.users)
        .document(_userModel.currentUser.uid)
        .updateData({FieldKeys.currentRoomId: roomId});

    await _firestore
        .collection(CollectionKeys.rooms)
        .document(roomId)
        .updateData({
      CollectionKeys.users: FieldValue.arrayUnion([_userModel.currentUser.uid])
    });
    readNewMessagesInRoom(roomId);
    return Future.value(null);
  }

  Future<void> updateLastAccessTime(String roomId) async {
    var doc = _firestore
        .collection(CollectionKeys.users)
        .document(_userModel.currentUser.uid)
        .collection(CollectionKeys.rooms)
        .document(roomId);
    return await doc.setData({
      FieldKeys.roomId: roomId,
      FieldKeys.lastAccessTime: FieldValue.serverTimestamp()
    });
  }

  Future<void> readNewMessagesInRoom(String roomId) async {
    var lastAccessTimeDoc = await _firestore
        .collection(CollectionKeys.users)
        .document(_userModel.currentUser.uid)
        .collection(CollectionKeys.rooms)
        .document(roomId)
        .get();

    var query = _firestore
        .collection(CollectionKeys.conversations)
        .where(FieldKeys.roomId, isEqualTo: roomId);
    if (lastAccessTimeDoc.data != null) {
      query.where(FieldKeys.timestamp,
          isGreaterThan: lastAccessTimeDoc.data[FieldKeys.lastAccessTime]);
    }

    var list = await query.getDocuments();

    for (var doc in list.documents) {
      doc.reference.updateData({
        FieldKeys.users: [_userModel.currentUser.uid]
      });
    }
    return Future.value(null);
  }

  Future<int> getBadgeCount(roomId) async {
    var document = await _firestore
        .collection(CollectionKeys.users)
        .document(_userModel.currentUser.uid)
        .collection(CollectionKeys.rooms)
        .document(roomId)
        .get();
    var unreadMessageList = await _firestore
        .collection(CollectionKeys.rooms)
        .document(roomId)
        .collection(CollectionKeys.messages)
        .where(FieldKeys.timestamp,
            isGreaterThan: document.data[FieldKeys.lastAccessTime])
        .getDocuments();
    return unreadMessageList.documents.length;
  }

  Future<void> markMessageAsRead(String messageId) {
    // _firestore.collection(CollectionKeys.conversations)
    // .document(messageId)
    // .updateData({data})
  }
}
