import 'package:dmv_admin/domain/models/education_model.dart';

class ChatMessageModel {
  final String role;
  final String? content;
  final List<EducationModel>? responseAI;

  ChatMessageModel({required this.role, this.content, this.responseAI});

  ChatMessageModel copyWith({
    String? role,
    String? content,
    List<EducationModel>? responseAI
  }) {
    return ChatMessageModel(
        role: role ?? this.role,
        content: content ?? this.content,
        responseAI: responseAI ?? this.responseAI
    );
  }
}