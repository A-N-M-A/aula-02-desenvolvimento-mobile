import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7C3AED),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0C1220),
      fontFamily: 'Roboto',
    );

    return MaterialApp(
      title: 'Finance Counter',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const FinanceCounterPage(),
    );
  }
}

class FinanceCounterPage extends StatefulWidget {
  const FinanceCounterPage({super.key});

  @override
  State<FinanceCounterPage> createState() => _FinanceCounterPageState();
}

class _FinanceCounterPageState extends State<FinanceCounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  void _decrementCounter() {
    setState(() => _counter--);
  }

  void _resetCounter() {
    setState(() => _counter = 0);
  }

  String get _formattedValue => 'R\$ ${_counter.toString()},00';

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Center(
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF111827), Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                            ),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carteira',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'Nexus Pay',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F2937), Color(0xFF111827)],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo disponível',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formattedValue,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34D399).withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Estável',
                                  style: TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Última atualização agora',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white54,
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
                        _buildActionButton(Icons.remove_rounded, _decrementCounter, const Color(0xFFF59E0B)),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.refresh_rounded, _resetCounter, const Color(0xFF60A5FA)),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.add_rounded, _incrementCounter, const Color(0xFF34D399)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(label: 'Movimentos', value: '$_counter', color: const Color(0xFF8B5CF6)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(label: 'Meta', value: '70%', color: const Color(0xFF22D3EE)),
                        ),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
