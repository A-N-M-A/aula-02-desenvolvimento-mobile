import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await FinanceStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        fontFamily: 'Roboto',
      ),
      home: const FinanceDashboardPage(),
    );
  }
}

class FinanceStorage {
  static const String _boxName = 'finance_box';
  static const String _key = 'transactions';
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    if (!_box.containsKey(_key)) {
      await _box.put(
        _key,
        [
          {
            'id': 'default_1',
            'title': 'Salário',
            'category': 'Renda',
            'amount': 4200.0,
            'isIncome': true,
            'date': 'Hoje',
            'color': const Color(0xFF10B981).value,
          },
          {
            'id': 'default_2',
            'title': 'Mercado',
            'category': 'Alimentação',
            'amount': 320.0,
            'isIncome': false,
            'date': 'Hoje',
            'color': const Color(0xFF10B981).value,
          },
          {
            'id': 'default_3',
            'title': 'Aluguel',
            'category': 'Moradia',
            'amount': 1200.0,
            'isIncome': false,
            'date': 'Ontem',
            'color': const Color(0xFF7C3AED).value,
          },
        },
      )
    }
  }

  Future<List<FinanceTransaction>> readTransactions() async {
    final raw = _box.get(_key, defaultValue: <Map<String, dynamic>>[]);
    final items = raw as List;
    return items
        .map((item) => FinanceTransaction.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> writeTransactions(List<FinanceTransaction> transactions) async {
    await _box.put(
      _key,
      transactions.map((transaction) => transaction.toMap()).toList(),
    );
  }
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.color,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final String date;
  final Color color;

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'Transação',
      category: map['category']?.toString() ?? 'Outros',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      isIncome: map['isIncome'] as bool? ?? false,
      date: map['date']?.toString() ?? 'Hoje',
      color: Color((map['color'] as num?)?.toInt() ?? const Color(0xFF4F46E5).toARGB32()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'isIncome': isIncome,
      'date': date,
      'color': color.toARGB32(),
    };
  }
}

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  final List<_Category> _categories = [
    const _Category('Moradia', Icons.home_rounded, Color(0xFF7C3AED), 1200),
    const _Category('Alimentação', Icons.fastfood_rounded, Color(0xFF10B981), 700),
    const _Category('Transporte', Icons.directions_car_rounded, Color(0xFF0EA5E9), 500),
    const _Category('Lazer', Icons.sports_esports_rounded, Color(0xFFF59E0B), 400),
    const _Category('Educação', Icons.school_rounded, Color(0xFFEC4899), 500),
  ];

  List<FinanceTransaction> _transactions = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await FinanceStorage.readTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _saveTransactions() async {
    await FinanceStorage.writeTransactions(_transactions);
  }

  double get _totalIncome {
    return _transactions
        .where((entry) => entry.isIncome)
        .fold(0.0, (sum, entry) => sum + entry.amount.abs());
  }

  double get _totalExpense {
    return _transactions
        .where((entry) => !entry.isIncome)
        .fold(0.0, (sum, entry) => sum + entry.amount.abs());
  }

  double get _balance => _totalIncome - _totalExpense;

  String get _balanceText => 'R\$ ${_balance.toStringAsFixed(0)}';

  List<ChartCategoryData> get _chartData {
    final totals = <String, double>{};
    for (final transaction in _transactions) {
      if (!transaction.isIncome) {
        totals[transaction.category] =
            (totals[transaction.category] ?? 0) + transaction.amount.abs();
      }
    }

    final items = <ChartCategoryData>[];
    for (final category in _categories) {
      final total = totals[category.name] ?? 0;
      if (total > 0) {
        items.add(ChartCategoryData(category.name, total, category.color));
      }
    }
    return items;
  }

  void _addIncome() {
    final category = _categories[_selectedCategoryIndex % _categories.length];
    final transaction = FinanceTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Renda extra',
      category: category.name,
      amount: 150,
      isIncome: true,
      date: 'Agora',
      color: category.color,
    );
    setState(() {
      _transactions.insert(0, transaction);
    });
    _saveTransactions();
  }

  void _addExpense() {
    final category = _categories[_selectedCategoryIndex % _categories.length];
    final transaction = FinanceTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Despesa em ${category.name}',
      category: category.name,
      amount: 80,
      isIncome: false,
      date: 'Agora',
      color: category.color,
    );
    setState(() {
      _transactions.insert(0, transaction);
    });
    _saveTransactions();
  }

  void _resetData() {
    setState(() {
      _transactions = [
        const FinanceTransaction(
          id: 'default_1',
          title: 'Salário',
          category: 'Renda',
          amount: 4200,
          isIncome: true,
          date: 'Hoje',
          color: Color(0xFF10B981),
        ),
        const FinanceTransaction(
          id: 'default_2',
          title: 'Mercado',
          category: 'Alimentação',
          amount: 320,
          isIncome: false,
          date: 'Hoje',
          color: Color(0xFF10B981),
        ),
        const FinanceTransaction(
          id: 'default_3',
          title: 'Aluguel',
          category: 'Moradia',
          amount: 1200,
          isIncome: false,
          date: 'Ontem',
          color: Color(0xFF7C3AED),
        ),
      ];
    });
    _saveTransactions();
  }

  Future<void> _openAddTransactionScreen() async {
    final result = await Navigator.of(context).push<FinanceTransaction>(
      MaterialPageRoute(
        builder: (_) => const AddTransactionPage(),
      ),
    );

    if (result == null) return;

    setState(() {
      _transactions.insert(0, result);
    });
    await _saveTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chartData = _chartData;
    final totalChart = chartData.fold<double>(0, (sum, item) => sum + item.value);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransactionScreen,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova transação'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F6FF), Color(0xFFE7EEFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, usuário',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                'Controle financeiro',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6D5EF6), Color(0xFF14B8A6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saldo total',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'ativo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                            child: Text(
                              _balanceText,
                              key: ValueKey<double>(_balance),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryPill(
                                  label: 'Receitas',
                                  value: 'R\$ ${_totalIncome.toStringAsFixed(0)}',
                                  color: const Color(0xFF8EF0B2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryPill(
                                  label: 'Despesas',
                                  value: 'R\$ ${_totalExpense.toStringAsFixed(0)}',
                                  color: const Color(0xFFFCC2C2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Receita',
                            icon: Icons.arrow_downward_rounded,
                            color: const Color(0xFF16A34A),
                            onTap: _addIncome,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Despesa',
                            icon: Icons.arrow_upward_rounded,
                            color: const Color(0xFFEF4444),
                            onTap: _addExpense,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Reset',
                            icon: Icons.refresh_rounded,
                            color: const Color(0xFF6366F1),
                            onTap: _resetData,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Categorias',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = index == _selectedCategoryIndex;
                          final totalSpent = _transactions
                              .where((entry) => entry.category == category.name && !entry.isIncome)
                              .fold<double>(0, (sum, item) => sum + item.amount.abs());
                          final progress = (totalSpent / category.limit).clamp(0.0, 1.0);

                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategoryIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? category.color : Colors.black.withValues(alpha: 0.04),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? category.color.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: category.color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(category.icon, color: category.color, size: 18),
                                      ),
                                      const Spacer(),
                                      if (isSelected)
                                        const Icon(Icons.check_rounded, size: 18, color: Colors.green),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    category.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'R\$ ${totalSpent.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: category.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(99),
                                        backgroundColor: category.color.withValues(alpha: 0.12),
                                        valueColor: AlwaysStoppedAnimation<Color>(category.color),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Despesas por categoria',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (chartData.isEmpty)
                            const Text('Sem despesas registradas.')
                          else ...[
                            SizedBox(
                              height: 170,
                              child: CustomPaint(
                                painter: DonutChartPainter(chartData, totalChart),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...chartData.map((item) {
                              final share = totalChart == 0 ? 0.0 : item.value / totalChart;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: item.color,
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${item.name} (${(share * 100).toStringAsFixed(0)}%)',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${item.value.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: item.color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Transações recentes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._transactions.map((transaction) {
                      final sign = transaction.isIncome ? '+' : '-';
                      final amountText = '$sign R\$ ${transaction.amount.abs().toStringAsFixed(0)}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: transaction.color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                transaction.isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: transaction.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${transaction.category} • ${transaction.date}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              amountText,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: transaction.isIncome ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChartCategoryData {
  const ChartCategoryData(this.name, this.value, this.color);

  final String name;
  final double value;
  final Color color;
}

class DonutChartPainter extends CustomPainter {
  const DonutChartPainter(this.items, this.total);

  final List<ChartCategoryData> items;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.32;
    final ringWidth = radius * 0.52;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    for (final item in items) {
      final sweep = total == 0 ? 0.0 : (item.value / total) * (math.pi * 2);
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - ringWidth * 0.75, innerPaint);

    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'R\$',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(canvas, Offset(center.dx - 8, center.dy - 18));

    final totalPainter = TextPainter(
      text: TextSpan(
        text: total.toStringAsFixed(0),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    totalPainter.paint(canvas, Offset(center.dx - 18, center.dy + 4));
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.total != total;
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  const _Category(this.name, this.icon, this.color, this.limit);

  final String name;
  final IconData icon;
  final Color color;
  final double limit;
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Moradia';
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Moradia',
    'Alimentação',
    'Transporte',
    'Lazer',
    'Educação',
    'Renda',
  ];

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final color = {
      'Moradia': const Color(0xFF7C3AED),
      'Alimentação': const Color(0xFF10B981),
      'Transporte': const Color(0xFF0EA5E9),
      'Lazer': const Color(0xFFF59E0B),
      'Educação': const Color(0xFFEC4899),
      'Renda': const Color(0xFF16A34A),
    }[_selectedCategory] ?? const Color(0xFF4F46E5);

    final transaction = FinanceTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: _selectedCategory,
      amount: _isIncome ? amount : -amount,
      isIncome: _isIncome,
      date: '${_selectedDate.day}/${_selectedDate.month}',
      color: color,
    );

    Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova transação'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      ToggleButtons(
                        isSelected: [_isIncome == false, _isIncome == true],
                        onPressed: (index) {
                          setState(() {
                            _isIncome = index == 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        constraints: const BoxConstraints(minHeight: 42, minWidth: 120),
                        children: const [
                          Text('Despesa'),
                          Text('Receita'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe um título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe um valor';
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                              const Icon(Icons.calendar_today_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveTransaction,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Salvar transação'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
