import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talker_app/common/functions/data_repository.dart';
class UserLocation{
  final double latitude;
  final double longitude;
  UserLocation(this.latitude,this.longitude);
  
}
class UserModel {
  String _uid;
  String email;
  String displayName;
  String photoUrl;
  String phoneNumber;
  String providerId;
  UserLocation currentLocation;
  bool useCustomLocation = false;
  String get uid => this._uid;
  UserModel(this._uid,
      {this.email,
      this.displayName = "",
      this.phoneNumber = "",
      this.providerId = "",
      this.photoUrl = ""});
  DocumentReference reference;
           
  UserModel.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[FieldKeys.uid] != null, "UserId cannot be null"),
        _uid = map[FieldKeys.uid],
        email = map[FieldKeys.email] ?? "",
        displayName = map[FieldKeys.displayName],
        photoUrl = map[FieldKeys.photoUrl] ?? "",
        phoneNumber = map[FieldKeys.phoneNumber],
        providerId = map[FieldKeys.providerId];

  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}





class UserModelRepository {
  static final UserModelRepository instance = UserModelRepository();
  static UserModel _currentUser;
  StreamSubscription<Position> locationSubscribe;
  Future<DocumentSnapshot> _getUserDetails(String id) async {
    DocumentSnapshot res =
        await Firestore.instance.collection('users').document(id).get();
    return res;
  }

  UserModel get currentUser => _currentUser;
  Future<void> setCurrentUserWithFirebaseUser(FirebaseUser user) async {
    _currentUser = UserModel(user.uid, email: user.email);
     _currentUser.displayName=user.displayName;
     _currentUser.phoneNumber=user.phoneNumber;
     _currentUser.photoUrl=user.photoUrl;
    DocumentSnapshot values = await _getUserDetails(user.uid);
    if (values.data != null) {
      _currentUser.displayName =
          values["displayName"] ?? _currentUser.displayName;
      _currentUser.phoneNumber =
          values["phoneNumber"] ?? _currentUser.phoneNumber;
      _currentUser.photoUrl = values["photoUrl"] ?? _currentUser.photoUrl;
    }else{
      await Firestore.instance
            .collection('users')
            .document(user.uid).setData({
              'uid': user.uid,
              'displayName': user.displayName,
              'photoUrl':user.photoUrl,
              'email':user.email
            });
    }
    await setUserLocation();
    
  }
  Future<void> setUserLocation()async{
    Geolocator().getCurrentPosition().then((onValue) {
        _currentUser.currentLocation = UserLocation(onValue.latitude, onValue.longitude);
        subscribeLocationChanges();
    });
  }
  void subscribeLocationChanges(){
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    locationSubscribe =  geolocator.getPositionStream(locationOptions).listen(
    (Position position) {
        _currentUser.currentLocation =  UserLocation(position.latitude, position.longitude);
    });
  }
  
  void unsubscribeLocationChanges(){
    locationSubscribe.cancel();
  }
  void resubscribeLocationChanges(){
    locationSubscribe.resume();
  }
  void clearCurrentUser(){
   _currentUser = null; 
  }
}
