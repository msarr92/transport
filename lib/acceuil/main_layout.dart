import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transport/acceuil/home_screen.dart';
import 'package:transport/acceuil/trajets_screen.dart';
//import 'package:transport/acceuil/history_screen.dart';
import 'package:transport/auth/login_screen.dart';

import 'mes_trajets_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late String? _userRole;
  bool _isLoading = true;

  int _currentNavIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadUserRole();
    _setupNavigation();
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserRole() async {
    _userRole = await _storage.read(key: 'user_role');
  }

  void _setupNavigation() {
    _pages = [];
    _navItems = [];

    // Page Accueil - Accessible seulement pour client et mixte
    if (_userRole == 'client' || _userRole == 'mixte') {
      _navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
      );
      _pages.add(HomeScreen(userRole: _userRole));
    }

    // Page Trajet - Accessible seulement pour chauffeur et mixte
    if (_userRole == 'chauffeur' || _userRole == 'mixte') {
      _navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.directions_car_outlined),
          activeIcon: Icon(Icons.directions_car),
          label: 'Trajet',
        ),
      );
      _pages.add(const TrajetsScreen());
    }

    // Page Mes Trajets - Accessible seulement pour chauffeur et mixte
    if (_userRole == 'chauffeur' || _userRole == 'mixte') {
      _navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'Mes Trajets',
        ),
      );
      _pages.add(const MesTrajetsScreen());
    }

    // Page Historique - Accessible à tous
    _navItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history),
        label: 'Historique',
      ),
    );
    // _pages.add(const HistoryScreen());

    // Page Profil - Accessible à tous
    _navItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    );
    _pages.add(const Scaffold(body: Center(child: Text('Profil'))));

    // Déconnexion - Toujours accessible
    _navItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.logout),
        label: 'Déconnexion',
      ),
    );

    // Ajuster l'index courant si nécessaire
    if (_currentNavIndex >= _pages.length) {
      _currentNavIndex = 0;
    }
  }

  void _handleNavigation(int index) {
    // Gestion de la déconnexion (dernier élément)
    if (index == _navItems.length - 1) {
      _confirmLogout();
    }
    // Navigation normale
    else if (index < _pages.length) {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_currentNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        items: _navItems,
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user_role');

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        _showErrorDialog('Erreur lors de la déconnexion: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}