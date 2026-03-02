class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime expenseDate;
  final DateTime? paymentDate;
  final bool isPaid;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.expenseDate,
    this.paymentDate,
    required this.isPaid,
    this.note,
  });
}
