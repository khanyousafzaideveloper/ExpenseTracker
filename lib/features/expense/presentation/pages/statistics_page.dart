import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controller/expense_controller.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No data yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // ── Summary totals ──────────────────────────────────────────
    final thisMonthExpenses = expenses.where((e) =>
    e.expenseDate.year == now.year &&
        e.expenseDate.month == now.month).toList();

    final totalAllTime =
    expenses.fold<double>(0, (s, e) => s + e.amount);
    final totalThisMonth =
    thisMonthExpenses.fold<double>(0, (s, e) => s + e.amount);
    final totalPaid = expenses
        .where((e) => e.isPaid)
        .fold<double>(0, (s, e) => s + e.amount);
    final totalUnpaid = expenses
        .where((e) => !e.isPaid)
        .fold<double>(0, (s, e) => s + e.amount);

    // ── Category totals ─────────────────────────────────────────
    final categoryTotals = <String, double>{};
    for (final e in expenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ── Last 7 days ─────────────────────────────────────────────
    final last7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final total = expenses
          .where((e) =>
      e.expenseDate.year == day.year &&
          e.expenseDate.month == day.month &&
          e.expenseDate.day == day.day)
          .fold<double>(0, (s, e) => s + e.amount);
      return _DayTotal(day: day, total: total);
    });

    // ── Monthly trend (current year) ────────────────────────────
    final monthlyTotals = List.generate(12, (i) {
      final month = i + 1;
      return expenses
          .where((e) =>
      e.expenseDate.year == now.year &&
          e.expenseDate.month == month)
          .fold<double>(0, (s, e) => s + e.amount);
    });

    // ── Pie chart colors ────────────────────────────────────────
    final pieColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Summary cards ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _summaryCard(context,
                  label: 'All Time',
                  amount: totalAllTime,
                  icon: Icons.account_balance_wallet_outlined,
                  color: colorScheme.primaryContainer,
                  onColor: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(context,
                  label: 'This Month',
                  amount: totalThisMonth,
                  icon: Icons.calendar_month_outlined,
                  color: colorScheme.secondaryContainer,
                  onColor: colorScheme.onSecondaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(context,
                  label: 'Paid',
                  amount: totalPaid,
                  icon: Icons.check_circle_outline,
                  color: colorScheme.tertiaryContainer,
                  onColor: colorScheme.onTertiaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(context,
                  label: 'Unpaid',
                  amount: totalUnpaid,
                  icon: Icons.hourglass_empty_outlined,
                  color: colorScheme.errorContainer,
                  onColor: colorScheme.onErrorContainer),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Donut chart — category breakdown ──────────────────
        _sectionTitle(context, 'Spending by Category'),
        const SizedBox(height: 12),
        _chartCard(
          context,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 52,
                    sections: List.generate(sortedCategories.length, (i) {
                      final entry = sortedCategories[i];
                      final percent = totalAllTime > 0
                          ? entry.value / totalAllTime
                          : 0.0;
                      final color = pieColors[i % pieColors.length];
                      return PieChartSectionData(
                        value: entry.value,
                        color: color,
                        radius: 40,
                        title: '${(percent * 100).toStringAsFixed(0)}%',
                        titleStyle: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: List.generate(sortedCategories.length, (i) {
                  final entry = sortedCategories[i];
                  final color = pieColors[i % pieColors.length];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Bar chart — last 7 days ────────────────────────────
        _sectionTitle(context, 'Last 7 Days'),
        const SizedBox(height: 12),
        _chartCard(
          context,
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: last7
                    .map((d) => d.total)
                    .fold(0.0, (a, b) => a > b ? a : b) *
                    1.3,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                    colorScheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Rs ${rod.toY.toStringAsFixed(0)}',
                        TextStyle(
                          color: colorScheme.onInverseSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final day = last7[value.toInt()].day;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat.E().format(day),
                            style:
                            Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colorScheme.outlineVariant,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(last7.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: last7[i].total,
                        color: last7[i].total > 0
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Line chart — monthly trend ─────────────────────────
        _sectionTitle(context, 'Monthly Trend (${now.year})'),
        const SizedBox(height: 12),
        _chartCard(
          context,
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: monthlyTotals.fold(0.0, (a, b) => a > b ? a : b) *
                    1.3,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                    colorScheme.inverseSurface,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                      'Rs ${s.y.toStringAsFixed(0)}',
                      TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                        .toList(),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'J', 'F', 'M', 'A', 'M', 'J',
                          'J', 'A', 'S', 'O', 'N', 'D'
                        ];
                        final i = value.toInt();
                        if (i < 0 || i > 11) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[i],
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colorScheme.outlineVariant,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(12, (i) {
                      return FlSpot(i.toDouble(), monthlyTotals[i]);
                    }),
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: colorScheme.surface,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _chartCard(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _summaryCard(
      BuildContext context, {
        required String label,
        required double amount,
        required IconData icon,
        required Color color,
        required Color onColor,
      }) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onColor, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: onColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs ${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: onColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper model ───────────────────────────────────────────────────
class _DayTotal {
  final DateTime day;
  final double total;
  const _DayTotal({required this.day, required this.total});
}