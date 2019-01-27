import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talker_app/common/functions/auth_provider.dart';

class UserModel {
  String _uid;
  String email;
  String displayName;
  String photoUrl;
  String phoneNumber;
  String providerId;
  FirebaseUser _fireBaseUser;
  UserModel(this._uid,
      {this.email,
      this.displayName,
      this.phoneNumber,
      this.providerId,
      this.photoUrl});
  UserModel.withFirebaseUser(this._fireBaseUser) {
    if (FirebaseUser != null) {
      this._uid = _fireBaseUser.uid;
      this.displayName = _fireBaseUser.displayName;
      this.email = _fireBaseUser.email;
      this.phoneNumber = _fireBaseUser.phoneNumber;
      this.photoUrl = _fireBaseUser.photoUrl;
      this.providerId = _fireBaseUser.providerId;
    }
  }
  String get uid => this._uid;
  static Future<UserModel> getCurrentUser(BuildContext context) async{
    var user = await AuthProvider.of(context).auth.currentUser();
    return user;
  }
}
class UserModelRepository{
  static UserModel currentUser;
}
