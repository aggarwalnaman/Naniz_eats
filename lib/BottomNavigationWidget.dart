import 'package:econoomaccess/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatefulWidget {
  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  void _onItemTapped(int index) {
    if(index==0){
      Navigator.pushReplacementNamed(context, "/ExplorePage");
    }
    else if (index == 1) {
      Navigator.pushReplacementNamed(context, "/SearchPage");
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, "/FavoriteScreenPage",
          arguments: AuthService.currentUser);
    } else if (index == 3) {
      FirebaseAuth.instance.signOut().whenComplete(() {
        Navigator.pushReplacementNamed(context, "/ChatsPage");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 54,
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,

            backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore, color: Colors.black),
                title: Text("Explore"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.black),
                title: Text("Search"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border, color: Colors.black),
                title: Text("Shop"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.perm_identity, color: Colors.black),
                title: Text("Shop"),
              )
            ],
          ),
        ));
  }
}
