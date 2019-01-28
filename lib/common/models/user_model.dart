import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    }
  }
  String get uid => this._uid;
    Future<String> getPhotoUrl(String id) async{
    DocumentSnapshot res = await Firestore.instance
            .collection('users')
            .document(id)
            .get();
      return res["photoUrl"]; 
      
  }  
}


class UserModelRepository{
  static UserModel currentUser;
}
