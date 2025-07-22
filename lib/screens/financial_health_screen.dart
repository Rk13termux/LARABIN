import 'package:flutter/material.dart';

class FinancialHealthScreen extends StatelessWidget {
  const FinancialHealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salud Financiera')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Umbrales de Riesgo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.7, // Simulación: 70% del umbral
              minHeight: 16,
              backgroundColor: Colors.red.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Atención! Estás cerca de tu límite de riesgo semanal.',
            ),
            const SizedBox(height: 24),
            Text(
              'Alertas de Comportamiento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.orange.shade100,
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Posible overtrading detectado'),
                subtitle: const Text(
                  'Has realizado 12 operaciones hoy. Considera tomar un descanso.',
                ),
              ),
            ),
            Card(
              color: Colors.blue.shade100,
              child: ListTile(
                leading: const Icon(Icons.self_improvement, color: Colors.blue),
                title: const Text('Mensaje de Contención'),
                subtitle: const Text(
                  'Recuerda: la disciplina y el descanso son clave para el éxito a largo plazo.',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recomendaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '• Programa períodos de descanso.\n• Revisa tu diario emocional.\n• No persigas pérdidas, acepta y aprende.',
            ),
          ],
        ),
      ),
    );
  }
}
