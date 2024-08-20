import 'package:flutter/material.dart';
import 'package:movie_search_app/screens/home/home_screen.dart';
import 'package:movie_search_app/screens/search/search_screen.dart';
import 'package:movie_search_app/theme/app_theme.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Permite apenas a orientação do dispositivo no modo retrato.
    // Referência: https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return MaterialApp(
      title: 'Movie Search App',
      theme: AppTheme.darkTheme,
      home: MainScreen(),
    );
  }
}

/// Tela principal do aplicativo com navegação inferior.
///
/// O [MainScreen] gerencia a navegação entre as telas [HomeScreen] e [SearchScreen]
/// usando um [BottomNavigationBar] para selecionar a tela ativa.
class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  // Índice da tela atualmente selecionada.
  int _selectedIndex = 0;

  // Lista de telas disponíveis para navegação.
  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
  ];

  // Altera a tela ativa ao selecionar um item no BottomNavigationBar.
  void _screenChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth * 0.05;
    final selectedFontSize = screenWidth * 0.04;
    final unselectedFontSize = screenWidth * 0.037;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize),
            label: 'Ínicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: iconSize),
            label: 'Buscar',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _screenChange,
        selectedFontSize: selectedFontSize,
        unselectedFontSize: unselectedFontSize,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
