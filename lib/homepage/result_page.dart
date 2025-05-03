// lib/homepage/result_page.dart
// result_page.dart
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats'),
      ),
      body: Center(child: Text('Voici les résultats')),
    );
  }
}

