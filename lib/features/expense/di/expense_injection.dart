import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasources/expense_local_datastore.dart';
import '../data/repositories/expense_repository_imp.dart';
import '../domain/usecases/add_expense.dart';
import '../domain/usecases/get_expense.dart';
import '../domain/usecases/update_expense.dart';
import '../domain/usecases/delete_expense.dart';
import '../presentation/controller/expense_controller.dart';

List<SingleChildWidget> expenseProviders = [
  Provider(create: (_) => ExpenseLocalDataSource()),

  ProxyProvider<ExpenseLocalDataSource, ExpenseRepositoryImpl>(
    update: (_, ds, __) => ExpenseRepositoryImpl(ds),
  ),

  ProxyProvider<ExpenseRepositoryImpl, AddExpense>(
    update: (_, repo, __) => AddExpense(repo),
  ),

  ProxyProvider<ExpenseRepositoryImpl, UpdateExpense>(
    update: (_, repo, __) => UpdateExpense(repo),
  ),

  ProxyProvider<ExpenseRepositoryImpl, DeleteExpense>(
    update: (_, repo, __) => DeleteExpense(repo),
  ),

  ProxyProvider<ExpenseRepositoryImpl, GetExpenses>(
    update: (_, repo, __) => GetExpenses(repo),
  ),

  ChangeNotifierProxyProvider4<AddExpense, UpdateExpense, DeleteExpense, GetExpenses, ExpenseProvider>(
    create: (context) => ExpenseProvider(
      addExpenseUseCase: context.read<AddExpense>(),
      updateExpenseUseCase: context.read<UpdateExpense>(),
      deleteExpenseUseCase: context.read<DeleteExpense>(),
      getExpensesUseCase: context.read<GetExpenses>(),
    ),
    update: (_, add, update, delete, get, __) => ExpenseProvider(
      addExpenseUseCase: add,
      updateExpenseUseCase: update,
      deleteExpenseUseCase: delete,
      getExpensesUseCase: get,
    ),
  ),
];
