import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/domain/models/education_model.dart';

class AIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<List<EducationModel>?> generateQuestionsApi(
    String text,
    String systemPrompt
  ) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'generateQuestions',
      );

      final response = await callable.call(<String, dynamic>{
        'rawText': text,
        'systemPrompt': systemPrompt,
      });

      final newJson = jsonDecode(response.data['resultData']) as List<dynamic>;
      final newAnswer = newJson
          .map((item) => EducationModel.fromJson(item))
          .toList();

      return newAnswer;
    } catch (e, stackTrace) {
      printer('Error AIService', e);
      printer('StackTrace', stackTrace);
      return null;
    }
  }
}
