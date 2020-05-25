import 'package:cloud_firestore/cloud_firestore.dart';
import 'AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  static const routeName = "/favorites";

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, "/ExplorePage");
    }
    else if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, "/SearchPage");
    }
    else if(_selectedIndex == 3){
      Navigator.pushReplacementNamed(context, "/UserProfilePage");
    }
  }

  @override
  Widget build(BuildContext context) {
    var s=ModalRoute.of(context).settings.arguments;
    return Scaffold(
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            height: 54,
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xffFE506D),
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.explore,
                    color: Colors.black,
                  ),
                  title: Text("Explore"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, color: Colors.black),
                  title: Text("Search"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border, color: Color(0xffFE506D)),
                  title: Text("Faavorites"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.perm_identity, color: Colors.black),
                  title: Text("Shop"),
                )
              ],
            ),
          )),
      appBar: AppBar(
        backgroundColor: Color(0xfff9f9f9),
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .document(s)
            .collection("favorites")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            List<DocumentSnapshot> restaurants = snapshot.data.documents;
            print(restaurants);
            return Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(20.0),
                  child: Text(
                    "Favorites",
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy"),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      Map<String, dynamic> restaurant = restaurants[index].data;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: ClipOval(
                                  child: Image.network(
                                    restaurant["image"],
                                    height: 65,
                                    width: 60,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                title: Center(
                                    child: Text(restaurant["name"],
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Gilroy"))),
                                trailing: MaterialButton(
                                  child: Text("Full Menu",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          // color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gilroy")),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        width: 1, color: Color(0xffFF526B)),
                                  ),
                                  textColor: Color(0xffFF526B),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        '/ProfilePage',
                                        arguments:
                                            restaurants[index].documentID);
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:
                                    restaurant["menu"].map<Widget>((meal) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.network(
                                            meal["image"],
                                            width: 100,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text("${meal["name"]}"),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: restaurants.length,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
