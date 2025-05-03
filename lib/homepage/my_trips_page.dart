import 'package:flutter/material.dart';

class MyTripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Ici, tes trajets publiés s’afficheront',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
