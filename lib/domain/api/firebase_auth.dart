import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/domain/api/firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseApi _api = FirebaseApi();

  Future<bool> createNewUser({
    required String userEmail,
    required String userPassword
  }) async{

    try{
      final exists = await _api.checkEmail(userEmail);
      if (!exists) return false;

      final authResult = await _auth.createUserWithEmailAndPassword(
          email: userEmail,
          password: userPassword
      );

      final createdUser = authResult.user;

      if (createdUser == null) return false;

        TextInput.finishAutofillContext();
        final String newUserId = createdUser.uid;
        await _api.createUserProfile(newUserId, userEmail);

        return true;
    }catch(e, stackTrace) {
      printer('Auth Error', e);
      printer('Auth StackTrace', stackTrace);
      return false;
    }
  }

  Future<User?> logInAuth(String email, String pass) async{
    try{
      final response = await
      _auth.signInWithEmailAndPassword(email: email, password: pass);
      if (response.user == null) return null;

      final user = response.user;

      TextInput.finishAutofillContext();
      return user!;

    }catch(e, stackTrace) {
      printer('Auth Error', e);
      printer('Auth StackTrace', stackTrace);
      return null;
    }
  }

  String? getUserId() {
    try{
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      return uid;
    }catch(e, stackTrace) {
      printer('Auth Error', e);
      printer('Auth StackTrace', stackTrace);
      return null;
    }
  }
}