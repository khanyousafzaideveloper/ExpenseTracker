import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/get_expense.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/delete_expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final AddExpense addExpenseUseCase;
  final UpdateExpense updateExpenseUseCase;
  final DeleteExpense deleteExpenseUseCase;
  final GetExpenses getExpensesUseCase;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  bool _loading = false;
  bool get loading => _loading;

  ExpenseProvider({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) {
    loadExpenses(); // ← add this
  }


  Future<void> loadExpenses() async {
    _loading = true;
    notifyListeners();

    _expenses = await getExpensesUseCase();

    _loading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await addExpenseUseCase(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await updateExpenseUseCase(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await deleteExpenseUseCase(id);
    await loadExpenses();
  }

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  List<Expense> get filteredExpenses {
    if (_searchQuery.isEmpty) return _expenses;

    return _expenses.where((e) =>
        e.title.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }


  void setSortType(SortType type) {
    notifyListeners();
  }

  double get totalSpent =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double totalForMonth(DateTime month) {
    return _expenses
        .where((e) =>
    e.expenseDate.month == month.month &&
        e.expenseDate.year == month.year)
        .fold(0, (sum, e) => sum + e.amount);
  }
}


enum SortType { dateNewest, dateOldest, amountHigh, amountLow }