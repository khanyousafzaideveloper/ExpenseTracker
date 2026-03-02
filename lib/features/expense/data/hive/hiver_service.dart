import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String expenseBoxName = 'expenses_box';

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> openExpenseBox() async {
    return await Hive.openBox(expenseBoxName);
  }
}
