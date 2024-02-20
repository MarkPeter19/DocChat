import 'package:flutter/material.dart';
import 'DoctorHomeScreen.dart';
import 'DoctorProfileScreen.dart';

class DoctorMainScreen extends StatefulWidget {
  @override
  _DoctorMainScreenState createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    DoctorHomeScreen(),
    DoctorProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconTheme(
              data: IconThemeData(
                size: 25.0,
                color: _selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
              ),
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: IconTheme(
              data: IconThemeData(
                size: 30.0,
                color: Colors.deepPurple,
              ),
              child: Icon(Icons.home),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconTheme(
              data: IconThemeData(
                size: 25.0,
                color: _selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
              ),
              child: Icon(Icons.person_outline),
            ),
            activeIcon: IconTheme(
              data: IconThemeData(
                size: 30.0,
                color: Colors.deepPurple,
              ),
              child: Icon(Icons.person),
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
