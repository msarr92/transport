import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:transport/acceuil/home_screen.dart';
import 'package:transport/auth/sign_up_screen.dart';
import 'package:transport/acceuil/verify_code_screen.dart';

import '../acceuil/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color _topColor = Color(0xFF2196F3);
  static const Color _middleColor = Color(0xFF1976D2);
  static const Color _bottomColor = Color(0xFF0D47A1);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _telephoneController.text = '+221';
    _telephoneController.selection = TextSelection.collapsed(offset: 4);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_topColor, _middleColor, _bottomColor],
            )),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildAnimatedHeader(),
                _buildLoginCard(),
                _buildSignupLink(),
                const SizedBox(height: 20),
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
                'assets/images/login.svg',
                height: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connectez-vous à votre compte',
              textAlign: TextAlign.center,
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

  Widget _buildLoginCard() {
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
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              _buildTelephoneField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 30),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelephoneField() {
    return TextField(
      controller: _telephoneController,
      maxLength: 13,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        LengthLimitingTextInputFormatter(13),
        SenegalPhoneNumberFormatter(),
      ],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone, color: _topColor),
        labelText: 'Téléphone',
        hintText: '77 777 77 77',
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _topColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _middleColor, width: 2),
        ),
      ),
    );
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _topColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _middleColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [_topColor, _accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handleLogin,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'CONNEXION',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: 'Pas de compte ? ',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const TextSpan(
                text: 'Inscrivez-vous',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading || !mounted) return;

    final telephone = _telephoneController.text.trim();
    final password = _passwordController.text.trim();

    if (!_validateInputs(telephone, password)) return;

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
        Uri.parse('http://10.0.2.2:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'telephone': telephone, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Vérification et stockage des données d'authentification
        final token = responseBody['token'] ?? responseBody['access_token'];
        final role = responseBody['role']; // Récupération du rôle depuis l'API


        if (token == null || token.isEmpty) {
          throw FormatException('Aucun token reçu du serveur');
        }

        if (role == null) {
          throw FormatException('Aucun rôle utilisateur défini');
        }

        // Stockage sécurisé des informations
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);
        await storage.write(key: 'user_role', value: role.toString());

        if (!mounted) return;

        // Gestion du premier login
        final isFirstLogin = responseBody['is_first_login'] ?? false;
        if (isFirstLogin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodeScreen(
                telephone: telephone,
                isFirstLogin: true,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        _handleApiError(responseBody, response.statusCode);
      }
    } on SocketException {
      _showErrorDialog('Pas de connexion internet. Veuillez vérifier votre connexion.');
    } on TimeoutException {
      _showErrorDialog('Le serveur ne répond pas. Veuillez réessayer plus tard.');
    } on HttpException catch (e) {
      _showErrorDialog('Erreur serveur: ${e.message}');
    } on FormatException catch (e) {
      _showErrorDialog(e.message);
    } catch (e) {
      _showErrorDialog('Une erreur inattendue est survenue: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateInputs(String telephone, String password) {
    final phoneValid = telephone.startsWith('+221') && telephone.length == 13;
    final passwordValid = password.length >= 8;

    if (!phoneValid) {
      _showErrorDialog('Numéro invalide. Format attendu: +221XXXXXXXX');
      return false;
    }

    if (!passwordValid) {
      _showErrorDialog('Le mot de passe doit contenir au moins 8 caractères');
      return false;
    }

    return true;
  }

  void _handleApiError(dynamic responseBody, int statusCode) {
    String message = 'Erreur de connexion';

    if (responseBody is Map<String, dynamic>) {
      message = responseBody['message'] ?? message;

      if (responseBody.containsKey('errors')) {
        final errors = responseBody['errors'] as Map<String, dynamic>;
        if (errors.containsKey('telephone')) {
          message = errors['telephone'].join('\n');
        } else if (errors.containsKey('password')) {
          message = errors['password'].join('\n');
        }
      }
    }

    switch (statusCode) {
      case 401:
        message = 'Identifiants incorrects';
        break;
      case 404:
        message = 'Utilisateur non trouvé';
        break;
      case 422:
        message = 'Données invalides';
        break;
    }

    _showErrorDialog(message);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Erreur',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: _topColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class SenegalPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue,) {
    const prefix = '+221';
    const maxLength = 13;

    if (!newValue.text.startsWith(prefix)) {
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    final cleaned = newValue.text
        .substring(prefix.length)
        .replaceAll(RegExp(r'[^0-9]'), '');

    final trimmed = cleaned.length > 9 ? cleaned.substring(0, 9) : cleaned;

    return TextEditingValue(
      text: '$prefix$trimmed',
      selection: TextSelection.collapsed(
          offset: prefix.length + trimmed.length),
    );
  }
}