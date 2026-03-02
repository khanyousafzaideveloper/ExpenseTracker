import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';
import '../controller/expense_controller.dart';

class AddEditExpensePage extends StatefulWidget {
  final Expense? expense;
  const AddEditExpensePage({super.key, this.expense});

  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = "Food";
  DateTime _expenseDate = DateTime.now();
  DateTime? _paymentDate;
  bool _isPaid = true;

  final List<String> categories = [
    "Food",
    "Transport",
    "Bills",
    "Shopping",
    "Health",
    "Entertainment",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final e = widget.expense!;
      _titleController.text = e.title;
      _amountController.text = e.amount.toString();
      _selectedCategory = e.category;
      _expenseDate = e.expenseDate;
      _paymentDate = e.paymentDate;
      _isPaid = e.isPaid;
      _noteController.text = e.note ?? "";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.expense != null;

    final inputDecoration = InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Expense" : "Add Expense"),
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(inputDecorationTheme: inputDecoration),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  prefixIcon: Icon(Icons.title_outlined),
                  counterText: '',
                ),
                maxLength: 75, // ~15 words buffer, word-count validated below
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title cannot be empty";
                  }
                  final wordCount =
                      value.trim().split(RegExp(r'\s+')).length;
                  if (wordCount > 15) {
                    return "Title cannot exceed 15 words";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.currency_rupee_outlined),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Allow digits and a single decimal point, max 6 digits before decimal
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,6}\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Amount is required";
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return "Enter a valid amount greater than 0";
                  }
                  final integerPart = value.split('.')[0];
                  if (integerPart.length > 6) {
                    return "Amount cannot exceed 6 digits";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.label_outline),
                ),
                borderRadius: BorderRadius.circular(12),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),

              const SizedBox(height: 16),

              // Expense Date
              _DatePickerTile(
                label: "Expense Date",
                date: _expenseDate,
                onPicked: (picked) => setState(() => _expenseDate = picked),
              ),

              const SizedBox(height: 16),

              // Paid toggle
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: SwitchListTile(
                  title: const Text("Mark as Paid"),
                  secondary: Icon(
                    _isPaid
                        ? Icons.check_circle_outline
                        : Icons.hourglass_empty_outlined,
                    color: _isPaid
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value;
                      _paymentDate =
                      _isPaid ? (_paymentDate ?? DateTime.now()) : null;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Note (optional)",
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.notes_outlined),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 28),

              // Save button
              FilledButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_isPaid && _paymentDate == null) {
                      _paymentDate = DateTime.now();
                    }
                    final expense = Expense(
                      id: widget.expense?.id ?? const Uuid().v4(),
                      title: _titleController.text.trim(),
                      amount: double.parse(_amountController.text),
                      category: _selectedCategory,
                      expenseDate: _expenseDate,
                      paymentDate: _isPaid ? _paymentDate : null,
                      isPaid: _isPaid,
                      note: _noteController.text.trim().isEmpty
                          ? null
                          : _noteController.text.trim(),
                    );

                    if (isEditing) {
                      await provider.updateExpense(expense);
                    } else {
                      await provider.addExpense(expense);
                    }

                    if (mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? "Update Expense" : "Save Expense"),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: colorScheme.onSurfaceVariant, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${date.toLocal()}".split(' ')[0],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}