import 'package:cloud_firestore/cloud_firestore.dart';
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
      await UserModelRepository.instance.setCurrentUserWithFirebaseUser(user);
      return UserModelRepository.instance.currentUser;
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
          await UserModelRepository.instance
              .setCurrentUserWithFirebaseUser(user);
          return UserModelRepository.instance.currentUser;
        } catch (e) {
          return null;
        }
        break;
    }
    return null;
  }

  @override
  Future<UserModel> createNewUser(
      {@required String email,
      @required String password,
      String displayName}) async {
    try {
      FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (user == null) {
        return null;
      }
      if (displayName != null) {
        UserUpdateInfo updateInfo = UserUpdateInfo();
        updateInfo.displayName = displayName;
        await user.updateProfile(updateInfo);
        
        var documentReference = Firestore.instance
            .collection('users')
            .document(user.uid);
        await documentReference.setData( {
              'uid': user.uid,
              'displayName': displayName,
              'email':email,
            });
        // Firestore.instance.runTransaction((transaction) async {
        //   await transaction.set(
        //     documentReference,
        //     {
        //       'uid': user.uid,
        //       'displayName': displayName,
        //     },
        //   );
        // });
      }
      await UserModelRepository.instance.setCurrentUserWithFirebaseUser(user);
      return UserModelRepository.instance.currentUser;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<UserModel> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await UserModelRepository.instance.setCurrentUserWithFirebaseUser(user);
    return UserModelRepository.instance.currentUser;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
