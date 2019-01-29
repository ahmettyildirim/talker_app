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
      this.displayName = "",
      this.phoneNumber = "",
      this.providerId = "",
      this.photoUrl = ""});

  String get uid => this._uid;
}

class UserModelRepository {
  static final UserModelRepository instance = UserModelRepository();
  static UserModel _currentUser;
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
  }
  void clearCurrentUser(){
   _currentUser = null; 
  }
}
