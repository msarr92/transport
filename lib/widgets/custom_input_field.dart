import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? icon;  // Icône facultative

  const CustomInputField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.icon,  // Paramètre icon facultatif
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null, // Si une icône est donnée, elle sera affichée
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
