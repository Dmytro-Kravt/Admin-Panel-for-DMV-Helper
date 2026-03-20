import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/domain/models/education_model.dart';
import 'package:dmv_admin/domain/models/user.dart';
import 'package:flutter/foundation.dart';

class FirebaseApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkEmail(String email) async{
    try{
      final response = await _firestore
          .collection('white_list').doc(email).get();

      return response.exists;
    }catch(e, stackTrace) {
      printer('Firebase API Error', e);
      printer('Firebase API StackTrace', stackTrace);
      return false;
    }
  }

  Future<void> createUserProfile(String uid, String userEmail) async{
    try{
      final newUser = UserModel(
          userId: uid,
          userEmail: userEmail,
          accessRole: UserAccessRole.viewer,
          isApproved: false
      );
      await _firestore.collection('users').doc(uid).set(newUser.toJson());
    }catch(e, stackTrace) {
      printer('Firebase API Error', e);
      printer('Firebase API StackTrace', stackTrace);
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async{
    try{
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final userData = snapshot.data();

      if (userData == null) return null;

      return UserModel.fromJson(userData);
    }catch(e, stackTrace) {
      printer('Firebase Api Error', e);
      printer('Firebase Api StackTrace', stackTrace);
      return null;
    }
  }

  Future<List<EducationModel>> fetchQuestions({
    String? language,
    String? state,
    int? qid,
  }) async {
    try{
      Query query = _firestore.collection('Car');

      if (language != null) {
        query = query.where('Language', isEqualTo: language);
      }

      if (state != null) {
        query = query.where('State', isEqualTo: state);
      }

      if (qid != null) {
        query = query.where('Question_ID', isEqualTo: qid);
      }

      final response = await query.get();

      if (response.docs.isEmpty) return [];

      final docs = response.docs;

      return docs
          .map((d) => EducationModel.fromJson(d.data() as Map<String, dynamic>))
          .toList();
    }catch(e, stackTrace) {
      if (kDebugMode) {
        print(e);
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<void> saveChanges({
    required String lang,
    required int id,
    required String state,
    required dynamic newValue,
    required String fieldName,
}) async{
    try{
      final querySnapshot = await _firestore
          .collection('Car')
          .where('Language', isEqualTo: lang)
          .where('Question_ID', isEqualTo: id)
          .where('State', isEqualTo: state)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({fieldName: newValue});

      }
    } catch(e, stackTrace) {
      if (kDebugMode){
        print('Error -> $e');
        print('stackTrace -> $stackTrace');
      }
      rethrow;
    }
  }

  Future<bool> saveNewQuestionAPI(EducationModel newQuestions, String docID) async{
    try{
      await _firestore.collection('Car').doc(docID).set(newQuestions.toJson());
      return true;
    }catch(e, stackTrace) {
      printer('Firebase API Error', e);
      printer('Firebase API StackTrace', stackTrace);
      return false;
    }
  }

  Stream<UserModel> streamUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      return UserModel.fromJson(snapshot.data()!);
    });
  }
  
  Future<({bool isDone, bool notExista})> addStateIdApi(String usState, int newId) async{
    try{
      final querySnapshot = await _firestore
          .collection('State_IDS')
          .where('name', isEqualTo: usState)
          .limit(1)
          .get();

      if(querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first;
        await data.reference.update({'idList': FieldValue.arrayUnion([newId])});
        return (isDone: true, notExista: false);
      } else {
        printer('Doc For State $usState', 'is not found');
        return (isDone: false, notExista: true);
      }
    }catch(e, stackTrace) {
      printer('Firebase API Error', e);
      printer('Firebase API StackTrace', stackTrace);
      return (isDone: false, notExista: false);
    }
  }
}
