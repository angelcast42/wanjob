import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
  Future<String> signInWithFacebook();
  Future<String> currentUser();
  Future<void> singOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signInWithEmail(String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user.uid != null) {
      final userdata =
          await Firestore.instance.collection('users').document(user.uid).get();
      if (userdata.data['registroterminado']) {
        return 'usuario registrado';
      } else {
        return 'usuario pendiente';
      }
    } else {
      return ('usuario no registrado');
    }
  }

  Future<String> signUpWithEmail(String email, String password) async {
      FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .setData({'tipo': 'trabajador', 'registroterminado': false});
      return user.uid;
  }

  Future<String> signInWithFacebook() async {
    final facebookLoginResult =
        await FacebookAuth().login(permissions: ['email']);
    final userfb = await FacebookAuth().getUserData();

    final facebookAuthCredential = await FacebookAuth().isLogged();
    AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: facebookAuthCredential.token);
    final user = await FirebaseAuth.instance.signInWithCredential(credential);
    if (user.additionalUserInfo.isNewUser) {
      await Firestore.instance
          .collection('users')
          .document(user.user.uid)
          .setData({
        'nombre': userfb['name'],
        'tipo': 'trabajador',
        'registroterminado': false
      });
      return 'usuario nuevo';
    } else {
      final userdata = await Firestore.instance
          .collection('users')
          .document(user.user.uid)
          .get();
      if (userdata.data['registroterminado']) {
        return 'usuario registrado';
      } else {
        return 'usuario pendiente';
      }
    }
  }

  Future<String> loginWithFacebook() async {
    final facebookLoginResult =
        await FacebookAuth().login(permissions: ['email']);
    final userfb = await FacebookAuth().getUserData();

    final facebookAuthCredential = await FacebookAuth().isLogged();
    AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: facebookAuthCredential.token);
    final user = await FirebaseAuth.instance.signInWithCredential(credential);
    await Firestore.instance
        .collection('users')
        .document(user.user.uid)
        .setData({'nombre': userfb['name'], 'tipo': 'trabajador'});
    return "sfdsf";
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> singOut() async {
    return _firebaseAuth.signOut();
  }
}
