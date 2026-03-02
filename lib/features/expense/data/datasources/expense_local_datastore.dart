import 'package:hive/hive.dart';
import '../hive/hiver_service.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  final Box box = Hive.box(HiveService.expenseBoxName);

  Future<void> addExpense(ExpenseModel model) async {
    await box.put(model.id, model);
  }

  Future<void> updateExpense(ExpenseModel model) async {
    await box.put(model.id, model);
  }

  Future<void> deleteExpense(String id) async {
    await box.delete(id);
  }

  List<ExpenseModel> getAllExpenses() {
    return box.values.cast<ExpenseModel>().toList();
  }
}
