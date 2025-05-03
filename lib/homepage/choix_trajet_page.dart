import 'package:flutter/material.dart';

class ChoixTrajet extends StatefulWidget {
  @override
  _ChoixTrajetState createState() => _ChoixTrajetState();
}

class _ChoixTrajetState extends State<ChoixTrajet> {
  String? selectedType;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController pricePerPersonController = TextEditingController();
  final TextEditingController soloPriceController = TextEditingController();
  int _passengerCount = 1;

  void _scrollToForm() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildDynamicFields() {
    switch (selectedType) {
      case 'covoiturage':
        return _buildInputCard(
          title: "💬 Prix par personne",
          controller: pricePerPersonController,
          hint: "Exemple : 2500 FCFA / passager",
        );
      case 'solo':
        return _buildInputCard(
          title: "💬 Prix total du trajet",
          controller: soloPriceController,
          hint: "Exemple : 10 000 FCFA pour tout le trajet",
        );
      case 'les deux':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard("🚀 Booster vos chances !",
                "Proposez un tarif solo et un tarif par personne. Vos clients auront plus de choix !"),
            _buildInputCard(
              title: "💬 Prix par personne",
              controller: pricePerPersonController,
              hint: "Exemple : 2500 FCFA / passager",
            ),
            SizedBox(height: 16),
            _buildInputCard(
              title: "💬 Prix total du trajet",
              controller: soloPriceController,
              hint: "Exemple : 10 000 FCFA pour privatiser le trajet",
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildInfoCard(String title, String message) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 6),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildInputCard({required String title, required TextEditingController controller, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildRadioTile({required String value, required String title, required IconData icon}) {
    final bool isSelected = selectedType == value;
    final Color lightBlue = Color(0xFF00B4D8); // Bleu Blablacar
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: isSelected ? 3 : 1,
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: lightBlue),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: lightBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        value: value,
        groupValue: selectedType,
        onChanged: (val) {
          setState(() {
            selectedType = val;
            _scrollToForm();
          });
        },
        activeColor: lightBlue,
      ),
    );
  }

  Widget _buildPassengerSelector() {
    final Color lightBlue = Color(0xFF00B4D8); // Bleu Blablacar

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          "Combien de passagers pouvez-vous accepter ?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_passengerCount > 1) _passengerCount--;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: lightBlue.withOpacity(0.8),
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
              child: Icon(Icons.remove, color: Colors.white),
            ),
            SizedBox(width: 30),
            Text(
              '$_passengerCount',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_passengerCount < 6) _passengerCount++;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: lightBlue.withOpacity(0.8),
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publier un trajet", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quel type de trajet souhaitez-vous proposer ?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildRadioTile(value: 'covoiturage', title: "Covoiturage", icon: Icons.people),
            _buildRadioTile(value: 'solo', title: "Voyage solo", icon: Icons.person),
            _buildRadioTile(value: 'les deux', title: "Les deux", icon: Icons.all_inclusive),
            SizedBox(height: 24),
            _buildDynamicFields(),
            _buildPassengerSelector(),
          ],
        ),
      ),
    );
  }
}
