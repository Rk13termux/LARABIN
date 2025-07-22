import 'package:flutter/material.dart';

class TradingJournalScreen extends StatefulWidget {
  const TradingJournalScreen({Key? key}) : super(key: key);

  @override
  State<TradingJournalScreen> createState() => _TradingJournalScreenState();
}

class _TradingJournalScreenState extends State<TradingJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tradeController = TextEditingController();
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  final List<Map<String, String>> _entries = [
    {'trade': 'BTC/USDT Long', 'emotion': 'Confianza', 'result': '+2.5%'},
    {'trade': 'ETH/USDT Short', 'emotion': 'Duda', 'result': '-1.2%'},
  ];

  void _addEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _entries.insert(0, {
          'trade': _tradeController.text,
          'emotion': _emotionController.text,
          'result': _resultController.text,
        });
        _tradeController.clear();
        _emotionController.clear();
        _resultController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diario de Trading')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tradeController,
                    decoration: const InputDecoration(
                      labelText: 'Operación (ej: BTC/USDT Long)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa la operación'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emotionController,
                    decoration: const InputDecoration(
                      labelText: 'Emoción (ej: Confianza, Miedo)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa la emoción'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _resultController,
                    decoration: const InputDecoration(
                      labelText: 'Resultado (ej: +2.5%)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa el resultado'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Entrada'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No hay registros aún.'))
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(entry['trade'] ?? ''),
                          subtitle: Text(
                            'Emoción: ${entry['emotion']}\nResultado: ${entry['result']}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
