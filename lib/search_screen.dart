import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'localization/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<String> tags = [];
  List<String> mealTypes = [];
  var uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUser() async {
    final FirebaseUser user = await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  String searchValue = "";
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, "/ExplorePage");
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacementNamed(context, "/FavoriteScreenPage",arguments: uid);
    } else if (_selectedIndex == 3) {
      Navigator.pushReplacementNamed(context, "/UserProfilePage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20),
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
                  icon: Icon(Icons.search),
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
          )),
      backgroundColor: Color(0xffE5E5E5),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.only(left: 15),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => searchController.clear()),
                      labelText: getTranslated(context, "searchLabel"),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Gilroy',
                        fontSize: 15.0,
                      )),
                  onChanged: (value) {
                    setState(() {
                      searchValue = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    createFilterChip("Top dishes", tags),
                    createFilterChip("Veg", tags),
                    createFilterChip("Non Veg", tags),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  getTranslated(context, "popular"),
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    createFilterChip("Rice", mealTypes),
                    createFilterChip("Rolls", mealTypes),
                    createFilterChip("Burgers", mealTypes),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: search(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text("${snapshot.error}");
                      else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Color(0xffFE506D),
                          ),
                        );
                      } else {
                        List<DocumentSnapshot> restaurants =
                            snapshot.data.documents;
                        return ListView.builder(
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 80,
                                width: 354,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(14.0),
                                    )),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Image.network(
                                      'https://s3-alpha-sig.figma.com/img/5085/4058/6aeed100f90a133ffcbd7384be8ccaef?Expires=1590364800&Signature=CYv8Yew9-jZTItGgTLznK4Jrd9tznqPJnFj4ErKF9RffyNKPxlsCAFG8pLeBSTMKloQiqU3l1MXut4l4nUROFvJFfbxfKio00FC2ywmG32xPwAOgzcqMZeXxR0DiTuUNAnRYRpZfvyV2Mtj7J1M1CWE6qeA0727BJpWC8JU6zW~Nso~sXM7mGJw6o-uQOoplf-Qbh1zNbW~xV8EpC6R71zzR2wJmWZlwzsnTOURliN2cmlDP0mlVR8wdGSkhXaKfrsKTSIM2tcGv7RZR6Oz5YS7g3~2JpEqT7UYaVMGns9psgAO96W3t37zjpfxdgUEBX5zZvRCYVh7HkJXQGj9SwQ__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA',
                                      height: 61,
                                      width: 102,
                                    ),
                                    Text(restaurants[index]['name'])
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                )
              ]),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> search() {
    //search is case sensitive - make name of restaurant be all lowercase
    Query searchQuery = Firestore.instance
        .collection("homemakers")
        .where("name", isGreaterThanOrEqualTo: searchValue)
        .where("name", isLessThan: searchValue + 'z');

    tags.forEach((tag) {
      if (tag == "non veg")
        searchQuery = searchQuery.where("tags.veg", isEqualTo: false);
      else
        searchQuery = searchQuery.where("tags.$tag", isEqualTo: true);
    });
    if (mealTypes.isNotEmpty) {
      searchQuery = searchQuery.where("mealTypes", arrayContainsAny: mealTypes);
    }
    return searchQuery.limit(15).snapshots();
  }

  Widget createFilterChip(String filterValue, List<String> filterList) {
    return FilterChip(
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1),
        borderRadius: BorderRadius.circular(11.5),
      ),
      label: Text(
        filterValue,
        style: TextStyle(
          color: (filterList.contains(filterValue.toLowerCase()))
              ? Colors.white
              : Colors.black,
        ),
      ),
      checkmarkColor: Colors.white,
      selectedColor: Color(0xffFE506D),
      backgroundColor: Colors.white,
      selected: filterList.contains(filterValue.toLowerCase()),
      padding: const EdgeInsets.all(10),
      onSelected: (value) {
        if (value) {
          setState(() {
            filterList.add(filterValue.toLowerCase());
          });
        } else {
          setState(() {
            filterList.remove(filterValue.toLowerCase());
          });
        }
      },
    );
  }
}
