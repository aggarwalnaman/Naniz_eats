import 'package:econoomaccess/UpdateMapPage.dart';
import 'package:econoomaccess/drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'localization/language_constants.dart';
import 'main.dart';
import 'localization/language.dart';
import 'package:flutter/cupertino.dart';

bool load = false;

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var _name, _uid, _phone, _language, _location, _image, menuType = "profile";
  Language language;
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  void getData() async {
    var temp;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('users').document(user.uid).get();
      setState(() {
        _uid = user.uid;
        _name = temp.data['name'];
        _phone = temp.data['mobileno'];
        _image = temp.data['image'];
        _language = temp.data['language'];
        _location = temp.data['city'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getData();
  }

  Widget ProfileItems() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(getTranslated(context, "phone"), style: TextStyle(fontSize: 15)),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                    "$_phone",
                    style: TextStyle(fontSize: 15),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Icon(Icons.edit),
                      onTap: () {
                        TextEditingController mobileController =
                            TextEditingController();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                //this right here
                                child: Container(
                                  height: 230,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 220),
                                            GestureDetector(
                                                onTap: () =>
                                                    Navigator.of(context).pop(),
                                                child:
                                                    Icon(Icons.highlight_off))
                                          ],
                                        ),
                                        Text(
                                          "Enter your new mobile number :",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'SF Pro Text',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                            letterSpacing: -0.8,
                                            height: 1.15,
                                          ),
                                        ),
                                        TextFormField(
                                          controller: mobileController,
                                          keyboardType: TextInputType.number,
                                          // inputFormatters: [
                                          //   WhitelistingTextInputFormatter
                                          //       .digitsOnly
                                          // ],
                                          autovalidate: true,
                                          validator: (value) {
                                            if (value.isNotEmpty) {
                                              if (value.length > 10 ||
                                                  value.length < 10)
                                                return "Enter valid no";
                                              else
                                                return null;
                                            }
                                            return "Enter valid no";
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: 300.0,
                                          child: RaisedButton(
                                            onPressed: () {
                                              firestore
                                                  .collection("users")
                                                  .document(_uid)
                                                  .updateData({
                                                "mobileno":
                                                    mobileController.text
                                              }).whenComplete(() {
                                                getData();
                                                print("Done");
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            child: Text(
                                              "Change Number",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'SF Pro Text',
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                height: 1.15,
                                              ),
                                            ),
                                            color: Color(0xffFE4E74),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(getTranslated(context, "language"),
              style: TextStyle(fontSize: 15)),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                    "$_language",
                    style: TextStyle(fontSize: 15),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Icon(Icons.edit),
                      onTap: () {
                        var lang;
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                //this right here
                                child: Container(
                                  height: 230,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 220),
                                            GestureDetector(
                                                onTap: () =>
                                                    Navigator.of(context).pop(),
                                                child:
                                                    Icon(Icons.highlight_off))
                                          ],
                                        ),
                                        Text(
                                          "Select Language :",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'SF Pro Text',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                            letterSpacing: -0.8,
                                            height: 1.15,
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12.0)),
                                          child: Center(
                                            child: DropdownButton<Language>(
                                              hint: Text("Select Language"),
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    38, 50, 56, 0.30),
                                                fontSize: 15.0,
                                                fontFamily: "Gilroy",
                                              ),
                                              underline: SizedBox(),
                                              onChanged: (Language language) {
                                                _changeLanguage(language);
                                                setState(() {
                                                  lang = language.name;
                                                });
                                              },
                                              items: Language.languageList()
                                                  .map<
                                                      DropdownMenuItem<
                                                          Language>>(
                                                    (e) => DropdownMenuItem<
                                                        Language>(
                                                      value: e,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            e.name,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: 300.0,
                                          child: RaisedButton(
                                            onPressed: () {
                                              firestore
                                                  .collection("users")
                                                  .document(_uid)
                                                  .updateData({
                                                "language": lang
                                              }).whenComplete(() {
                                                getData();
                                                print("Done");
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            child: Text(
                                              "Change Language",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'SF Pro Text',
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                height: 1.15,
                                              ),
                                            ),
                                            color: Color(0xffFE4E74),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(getTranslated(context, "location"),
              style: TextStyle(fontSize: 15)),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                    "$_location",
                    style: TextStyle(fontSize: 15),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Icon(Icons.edit),
                      onTap: () {
                        setState(() {
                          load = true;
                        });
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => UpdateMapPage()));
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ReviewItems() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(uid)
              .collection("reviews")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              print(snapshot.data.documents[0].data);
              return Container(
                height: 400,
                child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width,
                        height: 85,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(child: Text("${snapshot.data.documents[index].data["dishname"]}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)),
                                  Text("${snapshot.data.documents[index].data["rating"]}",style: TextStyle(fontSize: 15)),
                                  Icon(Icons.star,color:Color(0xffFE516E),size: 20,)
                                ],
                              ),
                              // SizedBox(height:5),
                              Text("${snapshot.data.documents[index].data["homemaker"]}",style: TextStyle(fontSize: 10)),
                              SizedBox(height:5),
                              Text("${snapshot.data.documents[index].data["text"]}",style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }),
              );
            }
          }),
    );
  }

  int _selectedIndex = 3;

  var uid;

  Future<String> getUser() async {
    final FirebaseUser user = await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      load = true;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, "/ExplorePage");
    } else if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, "/SearchPage");
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacementNamed(context, "/FavoriteScreenPage",
          arguments: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(Icons.bookmark_border, color: Colors.black),
                  title: Text("Faavorites"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.perm_identity, color: Color(0xffFE506D)),
                  title: Text("Shop"),
                )
              ],
            ),
          )),
      drawer: DrawerWidget(uid: this.uid),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Color(0xffE5E5E5),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
              child: Container(
                height: 230,
                width: MediaQuery.of(context).size.width,
                decoration: new BoxDecoration(
                  // border: new Border.all(width: 1.0, color: Colors.black),
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(20.0, 30.0),
                      blurRadius: 40.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 155,
                        height: 155,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: new NetworkImage("$_image")))),
                    SizedBox(height: 10),
                    Text("$_name",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                // margin: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "profile";
                          load = true;
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "profile"),
                            style: TextStyle(
                                fontSize: menuType == "profile" ? 20.0 : 17.0,
                                color: menuType == "profile"
                                    ? Colors.black
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "reviews";
                          load = true;
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "reviews"),
                            style: TextStyle(
                                fontSize: menuType == "reviews" ? 20.0 : 17.0,
                                color: menuType == "reviews"
                                    ? Colors.black
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            menuType == "profile" ? this.ProfileItems() : this.ReviewItems(),
          ],
        ),
      ),
    );
  }
}
