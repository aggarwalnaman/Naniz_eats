import 'package:econoomaccess/exchange.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool restaurantSelected = true;
  final String defaultImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/defaultImage.jpg?alt=media&token=8fa0d735-4c1b-4ef4-bb3f-a9f45bd31d83";

  List<String> recentSearches;
  SharedPreferences pref;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
    pref = await SharedPreferences.getInstance();
    recentSearches = pref.getStringList("searches") ?? [];
  }

  @override
  void initState() {
    super.initState();
    getUser();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => searchValue = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );
    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
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
      Navigator.pushReplacementNamed(context, "/FavoriteScreenPage",
          arguments: uid);
    } else if (_selectedIndex == 3) {
      Navigator.pushReplacementNamed(context, "/UserProfilePage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.only(left: 15),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: Colors.black,
                    size: 25,
                  ),
                  onPressed: () async {
                    // searchController.clear();
                    // setState(() {
                    //   searchValue = "";
                    // });
                    if (await Permission.microphone.isGranted) {
                      if (_isAvailable || !_isListening)
                        showDialog(
                            context: context,
                            builder: (context) {
                              // Future.delayed(Duration(seconds: 5), () {
                              //   Navigator.of(context).pop(true);
                              // });

                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  // width: MediaQuery.of(context).size.width * 0.8,

                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    color: Color(0xFFFE4E74),
                                  ),
                                  width: MediaQuery.of(context).size.width,

                                  duration: Duration(seconds: 10),
                                  child: Column(children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(20),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              width: 2, color: Colors.white)),
                                      child: Icon(
                                        Icons.mic,
                                        size: 90,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "${this.searchValue}",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ]),
                                ),
                              );
                            });

                      _speechRecognition.listen(locale: "en_US").then((result) {
                        setState(() {
                          searchValue = result;
                        });
                        print(result);
                      });
                    } else {
                      openAppSettings();
                    }
                  },
                ),
                labelText: getTranslated(context, "searchLabel"),
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Gilroy',
                  fontSize: 15.0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchValue = value;
                });
              },
              onFieldSubmitted: (String val) {
                recentSearches.add(val);
                pref.setStringList("searches", recentSearches);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                    child: FlatButton(
                  shape: (restaurantSelected)
                      ? Border(
                          bottom: BorderSide(width: 2, color: Colors.redAccent),
                        )
                      : Border(),
                  child: Text("Restaurant"),
                  onPressed: (restaurantSelected)
                      ? null
                      : () {
                          setState(() {
                            restaurantSelected = true;
                          });
                        },
                )),
                Expanded(
                    child: FlatButton(
                  shape: (!restaurantSelected)
                      ? Border(
                          bottom: BorderSide(width: 2, color: Colors.redAccent),
                        )
                      : Border(),
                  child: Text("Dishes"),
                  onPressed: (!restaurantSelected)
                      ? null
                      : () {
                          setState(() {
                            restaurantSelected = false;
                          });
                        },
                )),
              ],
            ),
            const SizedBox(height: 10),
            ...getFilter(),
            (searchValue.isEmpty)
                ? Text(
                    "Recent Searches",
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy"),
                  )
                : Container(),
            getRecentSearches(),
            Expanded(
              child: (restaurantSelected) ? restaurantList() : dishList(),
            )
          ]),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> restaurantSearch() {
    CollectionReference colRef = Firestore.instance.collection("homemakers");
    //search is case sensitive - make name of restaurant be all lowercase
    if (searchValue.isNotEmpty) {
      return colRef
          .where("name", isGreaterThanOrEqualTo: searchValue)
          .where("name", isLessThan: searchValue + 'z')
          .snapshots();
    } else if (mealTypes.isNotEmpty) {
      return colRef.where("mealtype", arrayContainsAny: mealTypes).snapshots();
    }
    return colRef.limit(15).snapshots();
  }

  Widget createMealFilterChip(String filterValue) {
    List<String> filterList = mealTypes;
    return FilterChip(
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1),
        borderRadius: BorderRadius.circular(11.5),
      ),
      label: Text(
        filterValue,
        style: TextStyle(
          color:
              (filterList.contains(filterValue)) ? Colors.white : Colors.black,
        ),
      ),
      checkmarkColor: Colors.white,
      selectedColor: Color(0xffFE506D),
      backgroundColor: Colors.white,
      selected: filterList.contains(filterValue),
      padding: const EdgeInsets.all(10),
      onSelected: (value) {
        if (value) {
          setState(() {
            filterList.add(filterValue);
          });
        } else {
          setState(() {
            filterList.remove(filterValue);
          });
        }
      },
    );
  }

  Widget createFilterChip(String filterValue, List<String> filterList,
      Color bgColor, Color textColor) {
    return FilterChip(
      label: Text(
        filterValue,
        style: TextStyle(
          color: (filterList.contains(filterValue)) ? Colors.white : textColor,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          width: 0,
          color: (filterValue == "Non Veg") ? Colors.black : bgColor,
        ),
      ),
      checkmarkColor: Colors.white,
      selectedColor: Color(0xffFE506D),
      backgroundColor: bgColor,
      selected: filterList.contains(filterValue),
      padding: const EdgeInsets.all(10),
      onSelected: (value) {
        if (value) {
          setState(() {
            filterList.add(filterValue);
          });
        } else {
          setState(() {
            filterList.remove(filterValue);
          });
        }
      },
    );
  }

  List<Widget> getFilter() {
    if (searchController.text.isEmpty) {
      if (restaurantSelected) {
        return <Widget>[
          Wrap(
            spacing: 10,
            children: <Widget>[
              createMealFilterChip("Burgers"),
              createMealFilterChip("Coffee"),
              createMealFilterChip("Sandwiches"),
              createMealFilterChip("Rice"),
              createMealFilterChip("Paratha"),
              createMealFilterChip("Maggi"),
              createMealFilterChip("Rolls"),
              createMealFilterChip("Sweets"),
            ],
          ),
          const SizedBox(height: 10),
        ];
      } else
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              createFilterChip("Top dishes", tags, Colors.black, Colors.white),
              createFilterChip("Veg", tags, Color(0xff15D0A1), Colors.black),
              createFilterChip("Non Veg", tags, Colors.white, Colors.black),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            getTranslated(context, "popular"),
            style: TextStyle(
                fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ];
    } else
      return <Widget>[Container()];
  }

  StreamBuilder restaurantList() {
    return StreamBuilder<QuerySnapshot>(
      stream: restaurantSearch(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Text("${snapshot.error}");
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xffFE506D),
            ),
          );
        } else {
          List<DocumentSnapshot> restaurants = snapshot.data.documents;
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/ProfilePage",
                      arguments: restaurants[index].documentID);
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  width: MediaQuery.of(context).size.width,
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Container(
                        width: 100,
                        height: 70,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  restaurants[index].data["image"] ??
                                      defaultImageUrl),
                              fit: BoxFit.fitWidth,
                            ),
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            restaurants[index].data['name'],
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 15),
                        child: Row(
                          children: <Widget>[
                            Text(restaurants[index]['rating'].toString()),
                            const Icon(
                              Icons.star,
                              color: Color(0xffFE506D),
                              size: 15.0,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5.0)
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  StreamBuilder dishList() {
    return StreamBuilder(
      stream: Firestore.instance.collection("homemakers").limit(15).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          QuerySnapshot querySnapshot = snapshot.data;
          List<DocumentSnapshot> docs = querySnapshot.documents;
          List meals = [];
          docs.forEach((doc) {
            List menu = doc.data["menu"];
            for (int i = 0; i < menu.length; i++) {
              menu[i]["homemaker"] = doc.data["name"];
              menu[i]["docId"] = doc.documentID;
              menu[i]["index"] = i;
              meals.add(menu[i]);
            }
          });

          if (searchController.text.isNotEmpty) {
            meals = meals.where((meal) {
              if (meal["name"]
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase())) return true;
              return false;
            }).toList();
          }
          meals = meals.where((meal) {
            if (tags.contains("Veg") && tags.contains("Non Veg")) return true;
            if (tags.contains("Veg")) {
              if (meal["veg"] == true)
                return true;
              else
                return false;
            }
            if (tags.contains("Non Veg")) {
              if (meal["veg"] == false)
                return true;
              else
                return false;
            }
            return true;
          }).toList();

          if (tags.contains("Top dishes")) {
            meals.sort((a, b) {
              a["rating"] ??= 0;
              b["rating"] ??= 0;
              return b["rating"].compareTo(a["rating"]);
            });
          }
          return ListView.builder(
            // controller: _controller,
            itemCount: meals.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  var args = ScreenArguments(
                      meals[index]["docId"],
                      meals[index]['name'],
                      meals[index]['veg'],
                      meals[index]['rating'],
                      meals[index]['price'],
                      meals[index]['image'],
                      meals[index]["index"]);
                  Navigator.of(context)
                      .pushNamed("/RecipePage", arguments: args);
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  width: MediaQuery.of(context).size.width,
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Container(
                        width: 100,
                        height: 70,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(meals[index]['image']),
                              fit: BoxFit.fitWidth,
                            ),
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            meals[index]['name'],
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "${meals[index]["homemaker"]}\'s Kitchen",
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontSize: 13.0,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "₹${meals[index]['price'].toString()}/plate",
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0,
                                color: Colors.black),
                          )
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: meals[index]['veg'] == true
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1.0)),
                              child: Center(
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: meals[index]['veg'] == true
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: <Widget>[
                                Text(meals[index]['rating'].toString()),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xffFE506D),
                                  size: 15.0,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5.0)
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget getRecentSearches() {
    if (searchValue.isNotEmpty) return Container();
    return Wrap(
      spacing: 10,
      children: recentSearches.map((value) {
        return FlatButton(
          child: Text(value),
          onPressed: () {
            searchController.text = value;
            setState(() {
              searchValue = value;
            });
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }).toList(),
    );
  }
}
