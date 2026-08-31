import 'package:flutter/material.dart';

void main() {
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

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  int _selectedCategoryIndex = 0;

  final List<_Category> _categories = [
    _Category('Moradia', Icons.home_rounded, const Color(0xFF7C3AED), 850, 1200),
    _Category('Alimentação', Icons.fastfood_rounded, const Color(0xFF10B981), 420, 700),
    _Category('Transporte', Icons.directions_car_rounded, const Color(0xFF0EA5E9), 260, 500),
    _Category('Lazer', Icons.sports_esports_rounded, const Color(0xFFF59E0B), 180, 400),
    _Category('Educação', Icons.school_rounded, const Color(0xFFEC4899), 210, 500),
  ];

  final List<_Transaction> _transactions = [
    _Transaction('Salário', 'Renda', 4200, true, 'Hoje', const Color(0xFF10B981)),
    _Transaction('Mercado', 'Alimentação', -320, false, 'Hoje', const Color(0xFF10B981)),
    _Transaction('Aluguel', 'Moradia', -1200, false, 'Ontem', const Color(0xFF7C3AED)),
    _Transaction('Uber', 'Transporte', -90, false, 'Ontem', const Color(0xFF0EA5E9)),
    _Transaction('Cinema', 'Lazer', -85, false, 'Seg', const Color(0xFFF59E0B)),
  ];

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

  void _addIncome() {
    final category = _categories[_selectedCategoryIndex % _categories.length];
    setState(() {
      _transactions.insert(
        0,
        _Transaction(
          'Renda extra', category.name,
          150,
          true,
          'Agora',
          category.color,
        ),
      );
    });
  }

  void _addExpense() {
    final category = _categories[_selectedCategoryIndex % _categories.length];
    setState(() {
      _transactions.insert(
        0,
        _Transaction(
          'Despesa em ${category.name}',
          category.name,
          -80,
          false,
          'Agora',
          category.color,
        ),
      );
    });
  }

  void _resetData() {
    setState(() {
      _transactions.clear();
      _transactions.addAll([
        _Transaction('Salário', 'Renda', 4200, true, 'Hoje', const Color(0xFF10B981)),
        _Transaction('Mercado', 'Alimentação', -320, false, 'Hoje', const Color(0xFF10B981)),
        _Transaction('Aluguel', 'Moradia', -1200, false, 'Ontem', const Color(0xFF7C3AED)),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
  const _Category(this.name, this.icon, this.color, this.spent, this.limit);

  final String name;
  final IconData icon;
  final Color color;
  final double spent;
  final double limit;
}

class _Transaction {
  const _Transaction(
    this.title,
    this.category,
    this.amount,
    this.isIncome,
    this.date,
    this.color,
  );

  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final String date;
  final Color color;
}
