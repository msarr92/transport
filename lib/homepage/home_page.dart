import 'package:flutter/material.dart';
import 'search_page.dart';      // Page de recherche des trajets
import 'publish_page.dart';     // Page de publication des trajets
import 'my_trips_page.dart';    // Page de Mes trajets
import 'account_page.dart';     // Page du compte utilisateur

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Liste des pages associées à chaque onglet
  final List<Widget> _pages = [
    SearchPage(),      // Onglet Rechercher
    PublishPage(),     // Onglet Publier
    MyTripsPage(),     // Onglet Mes trajets
    AccountPage(),     // Onglet Compte (dernier)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Affiche la page correspondant à l'onglet sélectionné
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF1877F2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Publier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Mes trajets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}
