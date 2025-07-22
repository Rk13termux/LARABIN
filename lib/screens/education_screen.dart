import 'package:flutter/material.dart';
import '../services/groq_service.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _response;
  bool _loading = false;

  // Usar GroqService sin pasar apiKey, se toma de dotenv
  final GroqService _groqService = GroqService();

  Future<void> _askAI() async {
    setState(() {
      _loading = true;
      _response = null;
    });
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        _loading = false;
        _response = 'Por favor, escribe una pregunta.';
      });
      return;
    }
    final result = await _groqService.sendPrompt(prompt);
    setState(() {
      _response = result ?? 'No se pudo obtener respuesta.';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educación IA')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Pregunta a la IA sobre trading o criptomonedas',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loading ? null : _askAI,
              icon: const Icon(Icons.send),
              label: const Text('Preguntar'),
            ),
            const SizedBox(height: 24),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_response != null && !_loading)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_response!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
