import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talker_app/common/models/user_model.dart';
import 'package:talker_app/common/functions/base_auth.dart';

class FirebaseAuthentication extends BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<UserModel> signInWithEmailAndPassword(
      {@required String email, @required String password}) async {
    try {
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return UserModel.withFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> signInWithProvider(Providers provider) async {
    switch (provider) {
      case Providers.Google:
        try {
          GoogleSignIn _googleSignIn = new GoogleSignIn(
            scopes: [
              'email',
              'https://www.googleapis.com/auth/contacts.readonly',
            ],
          );
          GoogleSignInAccount googleUser = await _googleSignIn.signIn();
          GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          FirebaseUser user = await _firebaseAuth.signInWithGoogle(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          return UserModel.withFirebaseUser(user);
        } catch (e) {
          return null;
        }
        break;
    }
    return null;
  }

  @override
  Future<UserModel> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    return user == null ? null : UserModel.withFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
