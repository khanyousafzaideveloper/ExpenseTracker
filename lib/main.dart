import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'features/expense/data/hive/hiver_service.dart';
import 'features/expense/data/models/expense_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  Hive.registerAdapter(ExpenseModelAdapter());
  await HiveService.openExpenseBox();

  runApp(const MyApp());
}
