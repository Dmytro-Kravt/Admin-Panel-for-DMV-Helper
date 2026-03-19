import 'dart:async';
import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/domain/api/firebase_api.dart';
import 'package:dmv_admin/domain/api/firebase_auth.dart';
import 'package:dmv_admin/domain/models/user.dart';
import 'package:dmv_admin/ui/providers/practice_provider.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  PracticeProvider? _pracProv;
  void setProvider(PracticeProvider provider) {
    _pracProv = provider;
  }


  final FirebaseAuthentication _auth = FirebaseAuthentication();
  final FirebaseApi _api = FirebaseApi();
  bool isLoading = false;
  UserModel? newUser;
  bool userLogedIn = false;
  bool isLogIn = true;
  String? safePass;
  String? error;
  UserModel? currentUser;
  UserAccessRole get role => currentUser?.accessRole ?? UserAccessRole.viewer;
  StreamSubscription<UserModel>? _userStream;



  void toggleSignInLogIn() {
    if (isLogIn) {
      isLogIn = false;
      generationPass();
      return;
    } else {
      isLogIn = true;
      safePass = null;
    }
    notifyListeners();
  }

  void generationPass() {
    final newPass = createSafetyPassword();
    safePass = newPass;
    notifyListeners();
  }

  Future<void> createUser(String userEmail) async {
    if (safePass == null || userEmail.isEmpty) {
      error = 'Please fill in all fields';
      notifyListeners();
      return;
    }
    try {
      isLoading = true;
      notifyListeners();

      final result = await _auth.createNewUser(
        userEmail: userEmail,
        userPassword: safePass!,
      );
      if (!result) {
        error = 'Please check your Email';
        return;
      }

      final String? currentUserID = _auth.getUserId();
      if (currentUserID == null) {
        error = 'Ups, please try agene';
        return;
      }

      final UserModel? user = await _api.getUserData(currentUserID);
      if (user == null) {
        error = 'Ups, please try agene';
        return;
      }

      currentUser = user;

      initUserListener(currentUserID);

      userLogedIn = true;

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logIn(String email, String pass) async{
    try{
      if (email.isEmpty || pass.isEmpty) {
        error = 'Please fill in all fields';
        notifyListeners();
        return;
      }
      isLoading = true;
      notifyListeners();

      final newUser = await _auth.logInAuth(email, pass);
      if (newUser == null) {
        error = 'User has not found';
        return;
      }

      final UserModel? user = await _api.getUserData(newUser.uid);
      if (user == null) {
        error = 'Ups, please try agene';
        return;
      }

      currentUser = user;

      initUserListener(user.userId);
      userLogedIn = true;

    }finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  void initUserListener(String userId) {
    _userStream = _api.streamUserData(userId).listen((newValue) {
      currentUser = currentUser?.copyWith(accessRole: newValue.accessRole);
      notifyListeners();
      _pracProv?.notifyListeners();
    });
  }
}
