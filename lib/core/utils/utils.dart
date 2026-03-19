
import 'dart:math';

import 'package:flutter/foundation.dart';

void printer(String title, var value) {
  if (kDebugMode) {
    print('$title: ---> | $value | <---');
  }
}

String createSafetyPassword() {
  final safeRandom = Random.secure();

  const letterPool = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numberPool = '0123456789';
  const symbolPool = '!@#\$%^&*()-_=+';

  const allChars = letterPool + numberPool + symbolPool;

  List<String> tempResult = [];

  tempResult.add(letterPool[safeRandom.nextInt(letterPool.length)]);
  tempResult.add(numberPool[safeRandom.nextInt(numberPool.length)]);
  tempResult.add(symbolPool[safeRandom.nextInt(symbolPool.length)]);

  for (int i = 0; i < 13; i++) {
    tempResult.add(allChars[safeRandom.nextInt(allChars.length)]);
  }

  tempResult.shuffle(safeRandom);
  return tempResult.join('');
}