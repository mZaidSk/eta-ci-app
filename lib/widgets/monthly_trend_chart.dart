import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<dynamic> trends;
  final ColorScheme colorScheme;

  const MonthlyTrendChart({
    super.key,
    required this.trends,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            _buildLegend(context),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Bar Chart
                SizedBox(
                  height: 220,
                  child: _buildBarChart(),
                ),
                const SizedBox(height: 24),
                // Analytics Summary
                _buildAnalyticsSummary(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        _LegendItem(
          color: Colors.green,
          label: 'Income',
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: Colors.red,
          label: 'Expense',
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final maxIncome = trends.fold<double>(
      0,
      (max, trend) =>
          (trend['income'] ?? 0).toDouble() > max
              ? (trend['income'] ?? 0).toDouble()
              : max,
    );
    final maxExpense = trends.fold<double>(
      0,
      (max, trend) =>
          (trend['expense'] ?? 0).toDouble() > max
              ? (trend['expense'] ?? 0).toDouble()
              : max,
    );
    final maxY = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final trend = trends[group.x.toInt()];
              final month = _getMonthLabel(trend['month'] ?? '');
              final isIncome = rodIndex == 0;
              final value = isIncome
                  ? (trend['income'] ?? 0).toDouble()
                  : (trend['expense'] ?? 0).toDouble();
              return BarTooltipItem(
                '$month\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${isIncome ? 'Income' : 'Expense'}: ₹${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= trends.length) return const SizedBox.shrink();
                final trend = trends[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getMonthLabel(trend['month'] ?? ''),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  _formatAmount(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(trends.length, (index) {
      final trend = trends[index];
      final income = (trend['income'] ?? 0).toDouble();
      final expense = (trend['expense'] ?? 0).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.green,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          BarChartRodData(
            toY: expense,
            color: Colors.red,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAnalyticsSummary(BuildContext context) {
    final totalIncome = trends.fold<double>(
      0,
      (sum, trend) => sum + (trend['income'] ?? 0).toDouble(),
    );
    final totalExpense = trends.fold<double>(
      0,
      (sum, trend) => sum + (trend['expense'] ?? 0).toDouble(),
    );
    final avgIncome = totalIncome / trends.length;
    final avgExpense = totalExpense / trends.length;
    final savingsRate =
        totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100) : 0;

    // Calculate trend (comparing first and last month)
    final firstMonthNet =
        (trends.first['income'] ?? 0).toDouble() -
        (trends.first['expense'] ?? 0).toDouble();
    final lastMonthNet =
        (trends.last['income'] ?? 0).toDouble() -
        (trends.last['expense'] ?? 0).toDouble();
    final netChange = lastMonthNet - firstMonthNet;
    final isImproving = netChange > 0;

    return Column(
      children: [
        // Key Metrics Row
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Avg Income',
                value: '₹${avgIncome.toStringAsFixed(0)}',
                icon: Icons.arrow_downward_rounded,
                color: Colors.green,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Avg Expense',
                value: '₹${avgExpense.toStringAsFixed(0)}',
                icon: Icons.arrow_upward_rounded,
                color: Colors.red,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Savings Rate',
                value: '${savingsRate.toStringAsFixed(1)}%',
                icon: Icons.savings_outlined,
                color: savingsRate > 20 ? Colors.green : Colors.orange,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Trend',
                value: isImproving ? 'Improving' : 'Declining',
                icon: isImproving ? Icons.trending_up : Icons.trending_down,
                color: isImproving ? Colors.green : Colors.red,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthLabel(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length == 2) {
        final month = int.parse(parts[1]);
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[month - 1];
      }
    } catch (_) {}
    return monthStr;
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme colorScheme;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
