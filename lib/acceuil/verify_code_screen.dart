import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:transport/acceuil/home_screen.dart';

import 'main_layout.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String telephone;
  final bool isFirstLogin;

  const VerifyCodeScreen({
    super.key,
    required this.telephone,
    required this.isFirstLogin,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  int _countdown = 60;
  late Timer _timer;
  bool _isLoading = false;

  static const Color _topColor = Color(0xFF2196F3);
  static const Color _middleColor = Color(0xFF1976D2);
  static const Color _bottomColor = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildCodeFields(),
                  const SizedBox(height: 30),
                  _buildVerifyButton(),
                  const SizedBox(height: 20),
                  _buildResendButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          widget.isFirstLogin ? 'Vérification initiale' : 'Vérification en deux étapes',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Code envoyé au ${widget.telephone}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
            (index) => SizedBox(
          width: 45,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white70),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? '' : null,
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : _verifyCode,
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
          'VÉRIFIER',
          style: TextStyle(
              color: _topColor,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _countdown == 0 ? _resendCode : null,
      child: Text(
        _countdown > 0
            ? 'Renvoyer le code (${_countdown}s)'
            : 'Renvoyer le code',
        style: TextStyle(
            color: _countdown == 0 ? Colors.white : Colors.white70),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    final code = _controllers.map((c) => c.text).join('');
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/verify-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'auth_token')}',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        _showError('Code invalide ou expiré');
      }
    } on SocketException {
      _showError('Pas de connexion internet');
    } catch (e) {
      _showError('Erreur de vérification');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendCode() async {
    setState(() => _countdown = 60);
    _startTimer();

    try {
      await http.post(
        Uri.parse('http://10.0.2.2:8000/api/resend-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'auth_token')}',
        },
        body: jsonEncode({'telephone': widget.telephone}),
      );
    } catch (e) {
      _showError('Erreur d\'envoi du code');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}