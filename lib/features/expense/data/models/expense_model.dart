import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime expenseDate;

  @HiveField(5)
  DateTime? paymentDate;

  @HiveField(6)
  bool isPaid;

  @HiveField(7)
  String? note;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.expenseDate,
    this.paymentDate,
    required this.isPaid,
    this.note,
  });

  factory ExpenseModel.fromEntity(Expense e) {
    return ExpenseModel(
      id: e.id,
      title: e.title,
      amount: e.amount,
      category: e.category,
      expenseDate: e.expenseDate,
      paymentDate: e.paymentDate,
      isPaid: e.isPaid,
      note: e.note,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      expenseDate: expenseDate,
      paymentDate: paymentDate,
      isPaid: isPaid,
      note: note,
    );
  }
}
