import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrajetsScreen extends StatefulWidget {
  const TrajetsScreen({super.key});

  @override
  State<TrajetsScreen> createState() => _TrajetsScreenState();
}

class _TrajetsScreenState extends State<TrajetsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRoundTrip = false;
  String? _tripType;

  // Nouveaux états pour gérer l'appel API
  bool _isLoading = false;
  List<dynamic> _trips = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    _controller.forward();

    // Charger les trajets au démarrage
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('http://localhost:8000/api/trajets'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _trips = data);
      } else {
        throw Exception('Échec du chargement des trajets: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submitTrip() async {
    // Validation des champs
    if (_departureController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _seatsController.text.isEmpty ||
        _tripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/trajets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'villeDepart': _departureController.text,
          'villeArrive': _destinationController.text,
          'dateDepart': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'heureDepart': _selectedTime.format(context),
          'typeTrajet': _tripType,
          'placesDisponibles': int.parse(_seatsController.text),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trajet créé avec succès')),
        );
        _loadTrips(); // Recharger la liste
        _resetForm(); // Réinitialiser le formulaire
      } else {
        throw Exception('Échec de la création: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _departureController.clear();
    _destinationController.clear();
    _seatsController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _isRoundTrip = false;
      _tripType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager un trajet'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _controller.value)),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'Détails du trajet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildLocationField(
                                icon: Icons.location_on,
                                label: 'Ville de départ',
                                controller: _departureController,
                              ),
                              const SizedBox(height: 15),
                              _buildLocationField(
                                icon: Icons.location_searching,
                                label: 'Ville d\'arrivée',
                                controller: _destinationController,
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateTimeSelector(
                                      icon: Icons.calendar_today,
                                      label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                                      onTap: () => _selectDate(context),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildDateTimeSelector(
                                      icon: Icons.access_time,
                                      label: _selectedTime.format(context),
                                      onTap: () => _selectTime(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildSeatsSelector(),
                              const SizedBox(height: 15),
                              _buildTripTypeSelector(),
                              const SizedBox(height: 15),
                              _buildRoundTripSwitch(),
                              const SizedBox(height: 25),
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Section Liste des trajets
            _buildTripsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _tripType,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.directions, color: Colors.blue[800]),
        labelText: 'Type de trajet',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: const [
        DropdownMenuItem(value: 'direct', child: Text('Direct')),
        DropdownMenuItem(value: 'avec_escale', child: Text('Avec escale')),
      ],
      onChanged: (value) => setState(() => _tripType = value),
      validator: (value) => value == null ? 'Sélectionnez un type' : null,
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsSelector() {
    return TextFormField(
      controller: _seatsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.people, color: Colors.blue[800]),
        labelText: 'Places disponibles',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildRoundTripSwitch() {
    return Row(
      children: [
        const Icon(Icons.autorenew, color: Colors.blue),
        const SizedBox(width: 10),
        const Text('Aller-retour', style: TextStyle(fontSize: 14)),
        const Spacer(),
        Switch(
          value: _isRoundTrip,
          activeColor: Colors.blue,
          onChanged: (value) => setState(() => _isRoundTrip = value),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _submitTrip,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'PUBLIER LE TRAJET',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trips.isEmpty) {
      return const Center(child: Text('Aucun trajet disponible'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trajets disponibles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _trips.length,
          itemBuilder: (context, index) {
            final trip = _trips[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: const Icon(Icons.directions_car, size: 40, color: Colors.blue),
                title: Text(
                  '${trip['villeDepart']} → ${trip['villeArrive']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(trip['dateDepart']))}'),
                    Text('Heure: ${trip['heureDepart']}'),
                    Text('Type: ${trip['typeTrajet'] == 'direct' ? 'Direct' : 'Avec escale'}'),
                    Text('Places: ${trip['placesDisponibles']}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigation vers les détails du trajet
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _departureController.dispose();
    _destinationController.dispose();
    _seatsController.dispose();
    super.dispose();
  }
}