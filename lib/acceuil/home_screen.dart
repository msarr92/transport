import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String? userRole;
  final Function(int)? onNavigate;

  const HomeScreen({
    super.key,
    required this.userRole,
    this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  bool get _isAuthorized =>
      widget.userRole == 'client' || widget.userRole == 'mixte';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return _buildUnauthorizedView();
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          _buildHeaderImage(screenHeight),
          _buildMainContent(screenHeight),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(double screenHeight) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.4,
      child: Image.asset(
        'assets/images/map_header.jpg',
        fit: BoxFit.cover,
        color: Colors.white.withOpacity(0.9),
        colorBlendMode: BlendMode.modulate,
      ),
    );
  }

  Widget _buildMainContent(double screenHeight) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _controller.value)),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedCard(),
                        _buildProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Planifiez votre trajet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _departController,
                icon: Icons.location_on,
                label: 'Départ',
                hint: 'Lieu de départ',
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _destinationController,
                icon: Icons.location_searching,
                label: 'Destination',
                hint: 'Destination finale',
              ),
              const SizedBox(height: 15),
              _buildDateSelector(),
              const SizedBox(height: 25),
              _AnimatedSearchButton(
                controller: _controller,
                onPressed: _handleSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 15),
            Text(
              DateFormat('dd MMM yyyy').format(selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          'Étape 1/3',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthorizedView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Accès restreint',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Cette fonctionnalité est réservée aux clients et ceux qui sont client/chauffeurs(mixte)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => widget.onNavigate?.call(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Voir les trajets disponibles',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  void _handleSearch() {
    // Implémentez votre logique de recherche ici
    if (_departController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Exemple de navigation
    widget.onNavigate?.call(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    _departController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}

class _AnimatedSearchButton extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onPressed;

  const _AnimatedSearchButton({
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + (controller.value * 0.05),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'CHERCHER UN TRAJET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed,
            ),
          ),
        );
      },
    );
  }
}