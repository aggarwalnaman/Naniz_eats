import 'package:econoomaccess/search_screen.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'ExplorePage.dart';
import 'search_screen.dart';
import 'recepie_screen.dart';

List<Widget> _widgetOptions = <Widget>[
  ExplorePage(),
  SearchScreen(),
  RecipeScreen(),
  ExplorePage(),
];
int index = 0;

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(index),
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        backgroundColor: Colors.white70,
        selectedBackgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (int val) {
          setState(() {
            index = val;
          });
          return val;
        },
        currentIndex: index,
        items: [
          FloatingNavbarItem(icon: Icons.home, title: 'Home'),
          FloatingNavbarItem(icon: Icons.explore, title: 'Explore'),
          FloatingNavbarItem(icon: Icons.restaurant_menu, title: 'Recipe'),
          FloatingNavbarItem(icon: Icons.person, title: 'Profile'),
        ],
      ),
    );
  }
}
