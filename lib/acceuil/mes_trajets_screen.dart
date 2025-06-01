import 'package:flutter/material.dart';

class MesTrajetsScreen extends StatelessWidget {
  const MesTrajetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Trajets'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Trajet #1234'),
            subtitle: const Text('Paris → Lyon • 15/06/2023'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers le détail du trajet
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Trajet #5678'),
            subtitle: const Text('Marseille → Nice • 16/06/2023'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers le détail du trajet
            },
          ),
          // Ajouter d'autres trajets ici...
        ],
      ),
    );
  }
}