import 'dart:convert';
import 'package:dmv_admin/domain/models/education_model.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';

class FileService {

  // Save Questions into Json on a device
  Future<bool> saveFileService ({
    required List<EducationModel> questions,
    required String language,
    required String usState,
  }) async{
    try{
      final String jsonString = JsonEncoder.withIndent(' ').convert(
        questions.map((item) =>item.toJson()).toList()
      );

      // Конвертируем строку в байты для сохранения
      Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
      String fileName = '${language}_$usState';

      // file_saver автоматически определит платформу.
      // На Web файл будет скачан, на Desktop - сохранен.
      await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'txt',
          mimeType: MimeType.text
      );

      return true;
    }catch (e, stackTrace) {
      if (kDebugMode){
        print('Error -> $e');
        print('Error StackTrace -> $stackTrace');
      }
      return false;
    }
  }
}