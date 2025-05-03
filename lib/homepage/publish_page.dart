import 'package:flutter/material.dart';
import 'date_time_page.dart';
class PublishPage extends StatefulWidget {
  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  String? selectedRegion;
  String? selectedQuarter;
  String? selectedDestination;

  final List<String> regions = ['Dakar', 'Thiès', 'Saint-Louis', 'Kaolack', 'Ziguinchor'];
  final List<String> dakarQuarters = ['Yoff', 'Parcelles', 'Medina', 'Plateau', 'Guédiawaye'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Choix du trajet",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👋 Bonjour, d'où partez-vous ?", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Sélectionnez votre région",
                border: OutlineInputBorder(),
              ),
              value: selectedRegion,
              items: regions.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRegion = value;
                  selectedQuarter = null;
                });
              },
            ),
            if (selectedRegion == 'Dakar') ...[
              SizedBox(height: 20),
              Text("🗺️ De quel quartier venez-vous ?", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Choisissez un quartier",
                  border: OutlineInputBorder(),
                ),
                value: selectedQuarter,
                items: dakarQuarters.map((q) {
                  return DropdownMenuItem(value: q, child: Text(q));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedQuarter = value;
                  });
                },
              ),
            ],
            SizedBox(height: 30),
            Text("📍 Quelle est votre destination ?", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Sélectionnez la région d'arrivée",
                border: OutlineInputBorder(),
              ),
              value: selectedDestination,
              items: regions.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDestination = value;
                });
              },
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DateTimePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1877F2),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
