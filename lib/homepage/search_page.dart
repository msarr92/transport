
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_input_field.dart';
import 'result_page.dart';

class SearchPage extends StatelessWidget {
  final TextEditingController villeDepartController = TextEditingController();
  final TextEditingController villeArriveeController = TextEditingController();
  final TextEditingController nombrePlacesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rechercher un trajet"),
        backgroundColor: Color(0xFF1877F2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInputField(
              hintText: "Départ",
              controller: villeDepartController,
            ),
            SizedBox(height: 16),
            CustomInputField(
              hintText: "Destination",
              controller: villeArriveeController,
            ),
            SizedBox(height: 16),
            CustomInputField(
              hintText: "Nombre de places",
              controller: nombrePlacesController,
              icon: FontAwesomeIcons.users,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  dateController.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
              child: AbsorbPointer(
                child: CustomInputField(
                  hintText: "Choisir la date",
                  controller: dateController,
                  icon: FontAwesomeIcons.calendar,
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResultPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1877F2),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("Rechercher", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
