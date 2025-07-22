import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  const SettingsScreen({Key? key, this.onToggleTheme, this.isDarkMode = false})
    : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: Text(widget.isDarkMode ? 'Modo Oscuro' : 'Modo Claro'),
            trailing: Switch(
              value: widget.isDarkMode,
              onChanged: (_) => widget.onToggleTheme?.call(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Descargo de Responsabilidad'),
            subtitle: const Text(
              'El trading de criptomonedas implica alto riesgo de pérdida de capital. La información proporcionada no constituye asesoramiento financiero.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
