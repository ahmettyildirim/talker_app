import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talker_app/common/functions/data_repository.dart';

class RoomModel {
  final String name;
  final String createdUser;
  DateTime createdDate;

  DocumentReference reference;
  RoomModel(
      {@required this.name,
      @required this.createdUser,
      this.createdDate});
           
  RoomModel.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[FieldKeys.name] != null, "SenderId cannot be null"),
        assert(map[FieldKeys.createdUser] != null, "Timestamp cannot be null"),

        name = map[FieldKeys.name],
        createdUser = map[FieldKeys.createdUser] ?? "",
        createdDate = map[FieldKeys.createdDate];

  RoomModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
