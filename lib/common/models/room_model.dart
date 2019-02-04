import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talker_app/common/functions/data_repository.dart';
import 'package:talker_app/common/models/user_model.dart';

class RoomModel {
  String name;
  String createdUser;
  double distance;
  GeoPoint location;
  DateTime createdDate;

  DocumentReference reference;
  RoomModel(
      {@required this.name,
      @required this.createdUser,
      this.createdDate});
           
  RoomModel.fromMap(Map<String, dynamic> map, {this.reference})
      { assert(map[FieldKeys.name] != null, "Room name cannot be null");
        assert(map[FieldKeys.createdUser] != null, "Created user cannot be null");

        name = map[FieldKeys.name];
        createdUser = map[FieldKeys.createdUser] ?? "";
        createdDate = map[FieldKeys.createdDate];
        location = map[FieldKeys.location];
        findDistance(location);
      }
  RoomModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


    Future<void> findDistance(GeoPoint location)async{
       var result = await Geolocator().distanceBetween(
            location.latitude,
            location.longitude,
            UserModelRepository.instance.currentUser.currentLocation.latitude,
            UserModelRepository.instance.currentUser.currentLocation.longitude);
        distance=result;
    }
}
