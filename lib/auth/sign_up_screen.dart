import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // Contrôleurs pour les champs de formulaire
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _permisConduireController = TextEditingController();
  final TextEditingController _marqueVoitureController = TextEditingController();
  final TextEditingController _numMatriculationController = TextEditingController();

  // Configuration des rôles disponibles
  final List<String> _roles = ['client', 'chauffeur', 'mixte'];
  final storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  // États de l'interface
  bool _obscurePassword = true;
  bool _isLoading = false;
  File? _permisFile;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // Palette de couleurs
  static const Color _topColor = Color(0xFF2196F3);
  static const Color _middleColor = Color(0xFF1976D2);
  static const Color _bottomColor = Color(0xFF0D47A1);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.decelerate),
    );

    _animationController.forward();
  }

  String _formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_topColor, _middleColor, _bottomColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildAnimatedHeader(),
                _buildSignupCard(),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Column(
          children: [
            RotationTransition(
              turns: _animationController,
              child: SvgPicture.asset(
                'assets/images/signup.svg',
                height: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Créez votre compte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              _buildNomField(),
              const SizedBox(height: 20),
              _buildPrenomField(),
              const SizedBox(height: 20),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildTelephoneField(),
              const SizedBox(height: 20),
              _buildRoleField(),
              const SizedBox(height: 20),
              _buildChauffeurFields(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 20),
              _buildConfirmPasswordField(),
              const SizedBox(height: 30),
              _buildSignupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNomField() {
    return TextField(
      controller: _nomController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person, color: _topColor),
        labelText: 'Nom',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPrenomField() {
    return TextField(
      controller: _prenomController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person_outline, color: _topColor),
        labelText: 'Prénom',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: _topColor),
        labelText: 'Adresse email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTelephoneField() {
    return TextField(
      controller: _telephoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[+0-9]+')),
      ],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone, color: _topColor),
        labelText: 'Téléphone',
        hintText: '+221777777777',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRoleField() {
    return DropdownButtonFormField<String>(
      value: _roleController.text.isEmpty ? null : _roleController.text,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person_outline, color: _topColor),
        labelText: 'Rôle',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _roles.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value[0].toUpperCase() + value.substring(1)),
        );
      }).toList(),
      onChanged: (value) => setState(() => _roleController.text = value!),
    );
  }

  Widget _buildChauffeurFields() {
    if (!['chauffeur', 'mixte'].contains(_roleController.text)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TextField(
          controller: _permisConduireController,
          decoration: InputDecoration(
            labelText: 'Numéro de permis',
            prefixIcon: const Icon(Icons.card_membership, color: _topColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        _buildPermisUpload(),
        const SizedBox(height: 20),
        TextField(
          controller: _marqueVoitureController,
          decoration: InputDecoration(
            labelText: 'Marque de la voiture',
            prefixIcon: const Icon(Icons.directions_car, color: _topColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _numMatriculationController,
          decoration: InputDecoration(
            labelText: 'Immatriculation',
            prefixIcon: const Icon(Icons.confirmation_number, color: _topColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildPermisUpload() {
    return Column(
      children: [
        OutlinedButton(
          onPressed: _pickPermisImage,
          style: OutlinedButton.styleFrom(
            foregroundColor: _topColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload),
              const SizedBox(width: 10),
              Text(_permisFile == null
                  ? 'Télécharger le permis'
                  : 'Fichier sélectionné'),
            ],
          ),
        ),
        if (_permisFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Fichier: ${_permisFile!.path.split('/').last}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Future<void> _pickPermisImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _permisFile = File(pickedFile.path));
      }
    } on PlatformException catch (e) {
      _showErrorDialog('Erreur d\'accès à la galerie: ${e.message}');
    }
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: _topColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: _topColor,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        labelText: 'Mot de passe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_reset, color: _topColor),
        labelText: 'Confirmez le mot de passe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSignupButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [_topColor, _accentColor]),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: _handleRegistration,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'S\'INSCRIRE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_isLoading) return;

    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final telephone = _formatPhoneNumber(_telephoneController.text.trim());
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final role = _roleController.text;

    if (!_validateInputs(nom, prenom, email, telephone, password, confirmPassword, role)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('http://10.0.2.2:8000/api/register');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({'Accept': 'application/json'});

      // Modification principale ici
      if (['chauffeur', 'mixte'].contains(role) && _permisFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photoPermis',
            _permisFile!.path,
          ),
        );
      }

      request.fields.addAll({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'password': password,
        'password_confirmation': confirmPassword,
        'role': role,
        'permisConduire': _permisConduireController.text,
        'marqueVoiture': _marqueVoitureController.text,
        'numMatriculation': _numMatriculationController.text,
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final token = jsonResponse['token'] ?? jsonResponse['access_token'];

        if (token == null) {
          _showErrorDialog('Token non reçu');
          return;
        }

        await storage.write(key: 'auth_token', value: token);
        if (mounted) _showSuccessDialog();
      } else {
        _handleApiError(responseBody);
      }
    } on SocketException catch (e) {
      _showErrorDialog('Erreur réseau: ${e.message}');
    } on TimeoutException {
      _showErrorDialog('Le serveur ne répond pas');
    } catch (e) {
      _showErrorDialog('Erreur inattendue: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateInputs(
      String nom,
      String prenom,
      String email,
      String telephone,
      String password,
      String confirmPassword,
      String role,
      ) {
    if (nom.isEmpty) return _showErrorAndReturn('Veuillez entrer votre nom');
    if (prenom.isEmpty) return _showErrorAndReturn('Veuillez entrer votre prénom');
    if (!RegExp(r"^[a-zA-Z0-9.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,6}$").hasMatch(email))
      return _showErrorAndReturn('Format d\'email invalide');
    if (telephone.isEmpty) return _showErrorAndReturn('Veuillez entrer votre numéro de téléphone');
    if (password.length < 8) return _showErrorAndReturn('Le mot de passe doit contenir au moins 8 caractères');
    if (password.contains(' ')) return _showErrorAndReturn('Le mot de passe ne doit pas contenir d\'espaces');
    if (password != confirmPassword) return _showErrorAndReturn('Les mots de passe ne correspondent pas');

    if (['chauffeur', 'mixte'].contains(role)) {
      if (_permisConduireController.text.isEmpty ||
          _marqueVoitureController.text.isEmpty ||
          _numMatriculationController.text.isEmpty) {
        return _showErrorAndReturn('Tous les champs véhicule sont obligatoires');
      }
      if (_permisFile == null) return _showErrorAndReturn('Veuillez télécharger le permis de conduire');
    }

    return true;
  }

  bool _showErrorAndReturn(String message) {
    _showErrorDialog(message);
    return false;
  }

  void _handleApiError(String responseBody) {
    try {
      final errors = jsonDecode(responseBody)['errors'] as Map<String, dynamic>;
      if (errors.containsKey('email')) {
        _showErrorDialog('Cet email est déjà utilisé par un autre compte');
      } else if (errors.containsKey('telephone')) {
        _showErrorDialog('Ce numéro de téléphone est déjà enregistré');
      } else if (errors.containsKey('numMatriculation')) {
        _showErrorDialog('Cette immatriculation existe déjà');
      } else {
        final errorMessages = errors.values
            .map<String>((e) => e.join(', '))
            .join('\n');
        _showErrorDialog('Erreurs de validation :\n$errorMessages');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'inscription');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Inscription réussie !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ),
      child: const Text(
        'Déjà un compte ? Connectez-vous',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    _permisConduireController.dispose();
    _marqueVoitureController.dispose();
    _numMatriculationController.dispose();
    super.dispose();
  }
}