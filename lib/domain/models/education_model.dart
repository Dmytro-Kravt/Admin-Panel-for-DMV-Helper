class EducationModel {
  final bool saved;
  final String? image;
  final String question;
  final String handBook;
  final String answerA;
  final String answerB;
  final String answerC;
  final String? answerD;
  final String correctAnswer;
  final bool enableAnswerD;
  final String language;
  final int questionId;
  final String usState;

  const EducationModel({
    this.saved = false,
    required this.image,
    required this.question,
    required this.handBook,
    required this.answerA,
    required this.answerB,
    required this.answerC,
    this.answerD,
    required this.correctAnswer,
    required this.enableAnswerD,
    required this.language,
    required this.questionId,
    required this.usState,
  });

  EducationModel copyWith({
    bool? saved,
    String? image,
    String? question,
    String? handBook,
    String? answerA,
    String? answerB,
    String? answerC,
    String? answerD,
    String? correctAnswer,
    bool? enableAnswerD,
    String? language,
    int? questionId,
    String? usState,}) {
    return EducationModel(
      saved: saved ?? this.saved,
      image: image ?? this.image,
      question: question ?? this.question,
      handBook: handBook ?? this.handBook,
      answerA: answerA ?? this.answerA,
      answerB: answerB ?? this.answerB,
      answerC: answerC ?? this.answerC,
      answerD: answerD ?? this.answerD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      enableAnswerD: enableAnswerD ?? this.enableAnswerD,
      language: language ?? this.language,
      questionId: questionId ?? this.questionId,
      usState: usState ?? this.usState,
    );
  }

  dynamic getFieldValue(String firebaseKey) {
    switch (firebaseKey) {
      case 'Language':
        return language;
      case 'Question_ID':
        return questionId;
      case 'State':
        return usState;
      case 'Question':
        return question;
      case 'Answer_A':
        return answerA;
      case 'Answer_B':
        return answerB;
      case 'Answer_C':
        return answerC;
      case 'Answer_D':
        return answerD;
      case 'Correct_Answer':
        return correctAnswer;
      case 'Hendbook':
        return handBook;
      case 'Choose_Wrong':
        return enableAnswerD;
      case 'Image':
        return image;
      default:
        return null;
    }
  }

  EducationModel updateField(dynamic newValue, String fieldName) {
    switch (fieldName) {
      case 'Language':
        return copyWith(language: newValue as String);
      case 'Question_ID':
        return copyWith(questionId: newValue as int);
      case 'State':
        return copyWith(usState: newValue as String);
      case 'Question':
        return copyWith(question: newValue as String);
      case 'Answer_A':
        return copyWith(answerA: newValue as String);
      case 'Answer_B':
        return copyWith(answerB: newValue as String);
      case 'Answer_C':
        return copyWith(answerC: newValue as String);
      case 'Answer_D':
        return copyWith(answerD: newValue as String?);
      case 'Correct_Answer':
        return copyWith(correctAnswer: newValue as String);
      case 'Hendbook':
        return copyWith(handBook: newValue as String);
      case 'Choose_Wrong':
        return copyWith(enableAnswerD: newValue as bool);
      case 'Image':
        return copyWith(image: newValue as String?);
      default: return this; // Если поле не найдено, возвращаем объект без изменений

    }
  }

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    final String? chackD = json['Answer_D'];
    final String? answerD =
    (chackD != null && chackD.isNotEmpty) ? chackD : null;
    return EducationModel(
        saved: json['saved'] ?? false,
        image: json['Image'],
        question: json['Question'] ?? '',
        handBook: json['Hendbook'] ?? '',
        answerA: json['Answer_A'] ?? '',
        answerB: json['Answer_B'] ?? '',
        answerC: json['Answer_C'] ?? '',
        answerD: answerD,
        correctAnswer: json['Correct_Answer'] ?? '',
        enableAnswerD: json['Choose_Wrong'] ?? false,
        language: json['Language'] ?? '',
        questionId: json['Question_ID'] ?? 0,
        usState: json['State'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'saved': saved,
      "Image": image,
      "Question": question,
      "Hendbook": handBook,
      "Answer_A": answerA,
      "Answer_B": answerB,
      "Answer_C": answerC,
      "Answer_D": answerD,
      "Correct_Answer": correctAnswer,
      "Choose_Wrong": enableAnswerD,
      "Language": language,
      "Question_ID": questionId,
      "State": usState,
    };
  }

  // Method toMap is for debug question list
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'question': question,
      'handBook': handBook,
      'answerA': answerA,
      'answerB': answerB,
      'answerC': answerC,
      'answerD': answerD,
      'correctAnswer': correctAnswer,
      'enableAnswerD': enableAnswerD,
      'language': language,
      'questionId': questionId,
      'usState': usState,
    };
  }

  @override
  String toString() {
    return 'Questions: |----| '
        'image: $image, |----| '
        ' question: $question, |----| '
        'handBook: $handBook, |----| '
        ' answerA: $answerA, |----| '
        ' answerB: $answerB, |----| '
        ' answerC: $answerC, |----| '
        'correctAnswer: $correctAnswer, |----| '
        ' enableAnswerD: $enableAnswerD, |----| '
        ' language: $language, |----| '
        ' questionId: $questionId,  |----| '
        'usState: $usState |----| ';
  }
}
