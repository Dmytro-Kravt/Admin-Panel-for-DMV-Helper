import 'package:dmv_admin/core/services/file_service.dart';
import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/domain/api/ai_service.dart';
import 'package:dmv_admin/domain/api/firebase_api.dart';
import 'package:dmv_admin/domain/models/education_model.dart';
import 'package:dmv_admin/domain/models/response_log.dart';
import 'package:dmv_admin/ui/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/models/user.dart';
import '../screens/practice_screen.dart';

class PracticeProvider with ChangeNotifier {
  final AuthProvider authProve;
  PracticeProvider(this.authProve);

  final FileService _fileService = FileService();
  final FirebaseApi _api = FirebaseApi();
  final AIService _aiService = AIService();
  List<EducationModel> allQuestion = [];
  Map<String, CellStatus> cellStatus = {};
  List<ResponseLog> response = [];
  List<ChatMessageModel> aiResponses = [];
  bool isLoading = false;
  bool isResponseWaite = false;
  bool loadError = false;
  bool create = false;
  UserAccessRole get role => authProve.role;
  String? correctField;

  void init(String value) {
    ResponseLog responseLog = ResponseLog(
      logNumber: response.length,
      log: value,
    );
    response.add(responseLog);
    notifyListeners();
  }

  void initSetCorrectField() {
    final first = allQuestion.first;
    final correct = allQuestion.first.correctAnswer;

    if(correct == first.answerA) {
      correctField = 'Answer_A';
    } else if (correct == first.answerB) {
      correctField = 'Answer_B';
    } else if (correct == first.answerC) {
      correctField = 'Answer_C';
    } else if (first.answerD != null && correct == first.answerD) {
      correctField = 'Answer_D';
    }

    printer('correctField', correctField);
    notifyListeners();
  }
  void setCorrectField(String value) {
    if(correctField == value) return;
    correctField = value;
    notifyListeners();
  }


  EducationModel onlyRU(List<EducationModel> list) {
      final questionRu = list.where((q) => q.language == 'ru').firstOrNull;
      if(questionRu == null) {
        return EducationModel(
            image: '',
            question: '',
            handBook: '',
            answerA: '',
            answerB: '',
            answerC: '',
            correctAnswer: '',
            enableAnswerD: false,
            language: 'Error!',
            questionId: 0,
            usState: ''
        );
      }
    return questionRu;
  }

  void setCreate(bool value) {
    if (role == .viewer) return;
    create = value;
    notifyListeners();
  }

  int getQuestionIndex(EducationModel question) {
    return allQuestion.indexWhere(
      (q) =>
          q.language == question.language &&
          q.questionId == question.questionId &&
          q.usState == question.usState,
    );
  }

  Future<void> loadQuestions({
    String? language,
    String? state,
    String? qid,
  }) async {
    if (role == .viewer) return;
    isLoading = true;
    notifyListeners();
    int? id;
    if (qid != null) id = int.tryParse(qid);
    try {
      final response = await _api.fetchQuestions(
        language: language,
        state: state,
        qid: id,
      );
      _sortQuestionList(response);
    } catch (e) {
      loadError = true;
    }
    isLoading = false;
    notifyListeners();
  }

  String getCellKey(String lan, String id, String state, String columKey) {
    return '${lan}_${id}_${state}_$columKey';
  }

  void setStatus(String key, CellStatus value) {
    cellStatus[key] = value;
    notifyListeners();
  }

  void createQuestion() {
    if (role == .viewer) return;
    if (create) {
      allQuestion.clear();
      response.clear();
      cellStatus.updateAll((_, _) => CellStatus.normal);
      for (int i = 0; i < 8; i++) {
        List<String> lang = ['en', 'es', 'ru', 'uk', 'pl', 'kk', 'ky', 'ar'];
        final newQuestion = EducationModel(
          image: null,
          question: '',
          handBook: '',
          answerA: '',
          answerB: '',
          answerC: '',
          correctAnswer: '',
          enableAnswerD: false,
          language: lang[i],
          questionId: 1000,
          usState: 'new',
        );
        allQuestion.add(newQuestion);
      }
    } else {
      response.clear();
      allQuestion.clear();
      cellStatus.updateAll((_, _) => CellStatus.normal);
    }

    notifyListeners();
  }

  void createNewFieldValue(
    EducationModel question,
    String fieldName,
    dynamic value,
    String cellKey,
  ) {
    if (role == .viewer) return;
    String chackedCellKey = cellKey;

    switch (fieldName) {
      case == 'Language':
        chackedCellKey = getCellKey(
          value as String,
          question.questionId.toString(),
          question.usState,
          fieldName,
        );
      case == 'Question_ID':
        chackedCellKey = getCellKey(
          question.language,
          value.toString(),
          question.usState,
          fieldName,
        );
      case == 'State':
        chackedCellKey = getCellKey(
          question.language,
          question.questionId.toString(),
          value as String,
          fieldName,
        );
    }

    if (fieldName == 'Question_ID') {
      for (ResponseLog r in response) {
        final isStart = r.cellKey?.startsWith('${question.language}_');
        if (isStart != null && isStart) {
          final isEnd = r.cellKey?.endsWith('_State');

          if ( isEnd != null && isEnd) {
            final oldCellKey = r.cellKey;
            final newCellKey = getCellKey(
              question.language,
              value.toString(),
              question.usState,
              'State',
            );

              cellStatus[newCellKey] = cellStatus.remove(oldCellKey)!;

            int index = response.indexWhere(
              (item) => item.cellKey == oldCellKey,
            );
            if (index != -1) {
              response[index] = ResponseLog(
                logNumber: r.logNumber,
                log: r.log,
                cellKey: newCellKey,
              );
            }
          } else {printer('Not found', '_State');}
        } else {printer('Not found', question.language);}
      }
    } else if (fieldName == 'State') {
      for (ResponseLog r in response) {
        final isStart = r.cellKey?.startsWith('${question.language}_');
        if (isStart != null && isStart) {
          final isEnd = r.cellKey!.endsWith('_Question_ID');
          if (isEnd) {
            final oldCellKey = r.cellKey;
            final newCellKey = getCellKey(
              question.language,
              question.questionId.toString(),
              value as String,
              'Question_ID',
            );
            cellStatus[newCellKey] = cellStatus.remove(oldCellKey)!;
            int index = response.indexWhere(
              (item) => item.cellKey == oldCellKey,
            );
            if (index != -1) {
              response[index] = ResponseLog(
                logNumber: r.logNumber,
                log: r.log,
                cellKey: newCellKey,
              );
            }
          }
        }
      }
    }

    int index = allQuestion.indexWhere((q) => q.language == question.language);

    // Защита от краша:
    if (index == -1) {
      cellStatus[cellKey] = CellStatus.error;
      response.add(
        ResponseLog(
          logNumber: response.length,
          log: 'Ошибка: вопрос не найден',
        ),
      );
      return; // Прерываем функцию
    }


    final fieldBefore = allQuestion[index].getFieldValue(fieldName);


    allQuestion[index] = question.updateField(value, fieldName);


    final fieldAfter = allQuestion[index].getFieldValue(fieldName);

    if (fieldBefore != fieldAfter) {
      cellStatus[chackedCellKey] = CellStatus.created;
      ResponseLog responseLog = ResponseLog(
        logNumber: response.length,
        log: 'Поле $fieldName успешно создано',
        cellKey: chackedCellKey,
      );
      response.add(responseLog);
    } else {
      ResponseLog responseLog = ResponseLog(
        logNumber: response.length,
        log: 'Ошибка поле $fieldName не создано',
        cellKey: chackedCellKey,
      );
      response.add(responseLog);
      cellStatus[chackedCellKey] = CellStatus.error;
    }
    notifyListeners();
  }

  Future<void> updateQuestion({
    required int indexToUpdate,
    required String lang,
    required int id,
    required String state,
    required dynamic newValue,
    required String fieldName,
    required String cellKey,
    required EducationModel question,
  }) async {
    if (role == .viewer) return;
    final oldValue = question.getFieldValue(fieldName);

    if (newValue != oldValue) {
      cellStatus[cellKey] = CellStatus.loading;
      notifyListeners();
      try {
        await _api.saveChanges(
          lang: lang,
          id: id,
          state: state,
          newValue: newValue,
          fieldName: fieldName,
        );

        ResponseLog responseLog = ResponseLog(
          logNumber: response.length,
          log: 'Поле $fieldName успешно обновленно',
        );
        response.add(responseLog);
        cellStatus[cellKey] = CellStatus.saved;

        if (indexToUpdate != -1) {
          allQuestion[indexToUpdate] = allQuestion[indexToUpdate].updateField(
            newValue,
            fieldName,
          );
        }

        notifyListeners();
      } catch (e) {
        ResponseLog responseLog = ResponseLog(
          logNumber: response.length,
          log: 'Ошибка обновления $fieldName. E -> $e',
        );
        response.add(responseLog);
        cellStatus[cellKey] = CellStatus.error;
      }
    } else {
      cellStatus[cellKey] = CellStatus.notChanged;
      ResponseLog responseLog = ResponseLog(
        logNumber: response.length,
        log: 'Поле $fieldName не обновленно',
      );
      response.add(responseLog);

      notifyListeners();
    }
  }

  Future<void> saveNewQuestion() async {
    if (role == .viewer) return;
    final addToKey = [
      'Language',
      'Question_ID',
      'State',
      'Question',
      'Answer_A',
      'Answer_B',
      'Answer_C',
      'Answer_D',
      'Correct_Answer',
      'Hendbook',
      'Choose_Wrong',
      'Image',
    ];

    for (EducationModel q in allQuestion) {
      final docID = '${q.language}_${q.questionId}_${q.usState}';

      bool isFull =
          q.usState != 'new' &&
          q.question.isNotEmpty &&
          q.answerA.isNotEmpty &&
          q.answerB.isNotEmpty &&
          q.answerC.isNotEmpty &&
          q.correctAnswer.isNotEmpty;

      if (isFull) {
        for (var addition in addToKey) {
          final newKey = getCellKey(
            q.language,
            q.questionId.toString(),
            q.usState,
            addition,
          );
          cellStatus[newKey] = CellStatus.loading;
        }
        notifyListeners();

        final result = await _api.saveNewQuestionAPI(q, docID);

        for (var addition in addToKey) {
          final newKey = getCellKey(
            q.language,
            q.questionId.toString(),
            q.usState,
            addition,
          );
          cellStatus[newKey] = result ? CellStatus.saved : CellStatus.error;
        }

        ResponseLog responseLog = ResponseLog(
          logNumber: response.length,
          log: result
              ? 'Новый вопрос добавлен ID -> $docID'
              : 'Сбой отправки ID -> $docID',
        );

        response.add(responseLog);
        notifyListeners();
      } else {
        for (var addition in addToKey) {
          final newKey = getCellKey(
            q.language,
            q.questionId.toString(),
            q.usState,
            addition,
          );
          cellStatus[newKey] = CellStatus.error;
        }
        ResponseLog responseLog = ResponseLog(
          logNumber: response.length,
          log: 'Вопрос не полностью заполнен ID -> $docID ',
        );
        response.add(responseLog);
        notifyListeners();
      }
    }
  }

  void _sortQuestionList(List<EducationModel> que) {
    List<String> lang = ['en', 'es', 'ru', 'uk', 'pl', 'kk', 'ky', 'ar'];
    int count = 0;

    que.sort((a, b) {
      if(count == 8) count = 0;
      // 1. СНАЧАЛА сравниваем по ID вопроса (Primary sort)
      // int idComparison = a.questionId.compareTo(b.questionId);
      int isEqual = a.usState.compareTo(b.usState);

      // Если ID разные (например, вопрос 1 и вопрос 2),
      // охранник сразу ставит меньший ID вперед и дальше даже не смотрит.
      if (isEqual != 0) {
        return isEqual;
      }

      // 2. Если ID одинаковые (например, оба вопроса имеют ID 175),
      // тогда охранник достает шпаргалку с языками и выстраивает их по порядку (Secondary sort).
      int indexA = lang.indexOf(a.language);
      int indexB = lang.indexOf(b.language);

      int result = indexA.compareTo(indexB);
        return result;

    });
    allQuestion = que;
  }

  void refreshPage() {
    setCreate(false);
    allQuestion.clear();
    response.clear();
    isLoading = false;
    loadError = false;
    notifyListeners();
  }

  void replayAllCellInColumn(EducationModel question ,String fieldName, dynamic value, String cellKey) {
    if (role == .viewer) return;
    final currentType = question.getFieldValue(fieldName);
    dynamic parsedValue = value;
    bool error = false;

    if (currentType is int) {
      try{
        parsedValue = int.parse(value);
      }catch(e) {
        ResponseLog responseLog = ResponseLog(
            logNumber: response.length,
            log: 'Ошибка: поле - $fieldName должно иметь только числа'
        );
        response.add(responseLog);
        cellStatus[cellKey] = CellStatus.error;
        error = true;
      }
    } else if (currentType is bool) {
      parsedValue = value.toLowerCase() == 'true';
    }

    if (!error) {
      for (int i = 0; i < allQuestion.length; i++) {
        final q = allQuestion[i];
        String newCellKey = getCellKey(q.language, q.questionId.toString(), q.usState, fieldName);
        createNewFieldValue(allQuestion[i], fieldName, parsedValue, newCellKey);
      }
    }
    notifyListeners();
  }

  Widget warningIsEqual(Widget toDefault, Widget toReturn, String columKey, EducationModel q) {
    switch (columKey) {
      case 'Answer_A':
        if (q.answerA.isNotEmpty && q.answerA == q.answerB) {
          return toReturn;
        }
        if (q.answerA.isNotEmpty && q.answerA == q.answerC) {
          return toReturn;
        }
        if (q.answerA.isNotEmpty && q.answerA == q.answerD) {
          return toReturn;
        }
        return toDefault;
      case 'Answer_B':
        if (q.answerB.isNotEmpty && q.answerB == q.answerA) {
          return toReturn;
        }
        if (q.answerB.isNotEmpty && q.answerB == q.answerC) {
          return toReturn;
        }
        if (q.answerB.isNotEmpty && q.answerB == q.answerD) {
          return toReturn;
        }
        return toDefault;
      case 'Answer_C':
        if (q.answerC.isNotEmpty && q.answerC == q.answerB) {
          return toReturn;
        }
        if (q.answerC.isNotEmpty && q.answerC == q.answerA) {
          return toReturn;
        }
        if (q.answerC.isNotEmpty && q.answerC == q.answerD) {
          return toReturn;
        }
        return toDefault;
      case 'Answer_D':
        if (q.answerD != null && q.answerD!.isNotEmpty && q.answerD == q.answerB) {
          return toReturn;
        }
        if (q.answerD != null && q.answerD!.isNotEmpty && q.answerD == q.answerC) {
          return toReturn;
        }
        if (q.answerD != null && q.answerD!.isNotEmpty && q.answerD == q.answerA) {
          return toReturn;
        }
        return toDefault;
      default: return toDefault;
    }
  }

  Future<void> saveQuestionsToPC(String language, String usState) async{
    if (role == .viewer) return;
    isLoading = true;
    notifyListeners();

    if (allQuestion.isEmpty) {
      ResponseLog responseLog = ResponseLog(
        logNumber: response.length,
        log: 'Questions List is Empty',
      );
      response.add(responseLog);
      return;
    }

    try{
      String state = '';
      String lang = '';
      if (language.isEmpty) lang = 'Any language';
      if (usState.isEmpty) state = 'Any States';


      final result = await _fileService.saveFileService(
          questions: allQuestion, language: lang, usState: state);
      ResponseLog responseLog = ResponseLog(
        logNumber: response.length,
        log: result
            ? 'File has been saved'
            : 'Ошибка сохранения, не создан путь',
      );
      response.add(responseLog);
    }catch(e) {
      ResponseLog responseLog = ResponseLog(
        logNumber: response.length,
        log: 'Error: - $e',
      );
      response.add(responseLog);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> generateQuestions(String text, String systemPrompt) async{
    if(authProve.currentUser?.accessRole == UserAccessRole.viewer ||
    text.isEmpty) {
      return;
    }
    try{
      isResponseWaite = true;
      notifyListeners();

      ChatMessageModel newSent = ChatMessageModel(
          role: 'User', content: text);
      aiResponses.insert(0, newSent);

      final newResponsList = await _aiService.generateQuestionsApi(text, systemPrompt);
      if (newResponsList == null || newResponsList.isEmpty) return;

      ChatMessageModel newResponse = ChatMessageModel(
          role: 'AI', responseAI: newResponsList);

      aiResponses.insert(0, newResponse);
    } finally {
      isResponseWaite = false;
      notifyListeners();
    }
  }

  void saveAiResponseToTable(List<EducationModel> questions, String correctField) {

    for(EducationModel q in questions) {
      final filledField = q.toJson().entries.where((f) =>
          f.value != null &&
          f.value.toString().isNotEmpty &&
          f.value != 0 &&
          f.value != false);
      int index = allQuestion.indexWhere((item) => item.language == q.language);
      if(index == -1) return;
      EducationModel existingQuestion = allQuestion[index];

      for(var entry in filledField) {
        if(entry.key == 'Language') continue;

        if(entry.key == 'Correct_Answer') {
          existingQuestion = existingQuestion.updateField(entry.value, entry.key);
          final newCell = getCellKey(q.language, existingQuestion.questionId.toString(), q.usState, entry.key);
          cellStatus[newCell] = CellStatus.created;

          existingQuestion = existingQuestion.updateField(entry.value, correctField);
          final newCell2 = getCellKey(q.language, existingQuestion.questionId.toString(), q.usState, correctField);
          cellStatus[newCell2] = CellStatus.created;
          createNewFieldValue(allQuestion[index], entry.key, entry.value, newCell2);
        }

        else if(entry.key != 'Correct_Answer'){
          existingQuestion =
              existingQuestion.updateField(entry.value, entry.key);
          final newCell = getCellKey(q.language, existingQuestion.questionId.toString(), q.usState, entry.key);
          cellStatus[newCell] = CellStatus.created;
          createNewFieldValue(allQuestion[index], entry.key, entry.value, newCell);
        }

      }

      allQuestion[index] = existingQuestion;
      notifyListeners();
    }
  }
}
