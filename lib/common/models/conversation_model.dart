import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talker_app/common/functions/data_repository.dart';

class ConversationModel {
  final String senderId;
  final String sender;
  final String text;
  DateTime timestamp;
  final String roomId;
  double latitude;
  double longitude;
  GeoPoint location;

  DocumentReference reference;
  ConversationModel(
      {@required this.senderId,
      this.sender,
      @required this.text,
      @required this.roomId,
      this.longitude,
      this.latitude}){
        location = GeoPoint(latitude,longitude);
      }
           
  ConversationModel.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[FieldKeys.senderId] != null, "SenderId cannot be null"),
        assert(map[FieldKeys.timestamp] != null, "Timestamp cannot be null"),
        assert(map[FieldKeys.roomId] != null, "roomId cannot be null"),
        assert(map[FieldKeys.text] != null, "text cannot be null"),
        senderId = map[FieldKeys.senderId],
        sender = map[FieldKeys.sender] ?? "",
        text = map[FieldKeys.text],
        timestamp = map[FieldKeys.timestamp],
        roomId = map[FieldKeys.roomId],
        location = map[FieldKeys.location];

  ConversationModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
