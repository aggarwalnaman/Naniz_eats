import 'package:econoomaccess/MakerDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'model.dart';
import 'localization/language_constants.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  List<User> users;
  bool flag = false;
  var name, duration;
  var temp = [];
  var _uid;

  int _selectedIndex = 0;

  String menuType = "menu";
  String timeslot = "10AM - 12PM";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, "/MerchantOrderPage",
          arguments: _uid);
    } else if (_selectedIndex == 2) {
    } else if (_selectedIndex == 3) {
      // Navigator.pushReplacementNamed(context, "/ProfilePage");
    }
  }

  // Stream<QuerySnapshot> fetchProductsAsStream() {
  //   return firestore
  //       .collection('homemakers')
  //       .snapshots();
  // }

  getInventory() {
    firestore.collection('recipe').getDocuments().then((doc) {
      doc.documents.every((element) {
        // setState(() {
        print(element.data);
        temp.add({"name": element.data["name"]});
        // temp.add(element.data);
        return true;
        // });
      });
    });
  }

  void getData() async {
    var temp;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('homemakers').document(user.uid).get();
      setState(() {
        _uid = user.uid;
        name = temp.data['name'];
        duration = temp.data['ohours'];
        flag = !flag;
      });
    });
  }

  Widget addInventoryItem(Map<String, dynamic> meal) {
    TextEditingController priceController = TextEditingController();
    print(meal);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      //this right here
      child: Container(
        height: 230,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  SizedBox(width: 220),
                  GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.highlight_off))
                ],
              ),
              Text(
                "Enter Price for ${meal["name"]}",
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
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                autovalidate: true,
                validator: (value) {
                  if (value.isNotEmpty) {
                    if (int.parse(value) > 0) return null;
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
                    var obj = [
                      {
                        "name": meal["name"],
                        "price": int.parse(priceController.text),
                        "image": meal["image"],
                      }
                    ];
                    firestore
                        .collection("homemakers")
                        .document(_uid)
                        .updateData({
                      "menu": FieldValue.arrayUnion(obj),
                    }).whenComplete(() {
                      print("Done");
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text(
                    "Add ${meal["name"]}",
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
  }

  Widget InventoryItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 400,
          child: StreamBuilder(
              stream:
                  firestore.collection("homemakers").document(_uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  var menu = temp.where((meal) {
                    for (int i = 0;
                        i < snapshot.data.data["menu"].length;
                        i++) {
                      if (snapshot.data.data["menu"][i]["name"] == meal["name"])
                        return false;
                    }
                    return true;
                  }).toList();
                  return ListView.builder(
                      itemCount: menu.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 15.0, left: 10, right: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "${menu[index]["name"]}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Gilroy",
                                        fontSize: 21.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.8,
                                        height: 1.15,
                                      ),
                                    ),
                                    // Text(
                                    //   "₹50/plate",
                                    //   style: TextStyle(
                                    //     color: Colors.black54,
                                    //     fontFamily: "Gilroy",
                                    //     fontSize: 13.0,
                                    //     fontWeight: FontWeight.bold,
                                    //     letterSpacing: -0.8,
                                    //     height: 1.15,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 25,
                                width: 50,
                                child: OutlineButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return addInventoryItem(menu[index]);
                                        });
                                  },
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: Color(0xffFE4E74),
                                  ),
                                  child: Center(
                                      child: Icon(
                                    Icons.add,
                                    color: Color(0xffFE4E74),
                                    size: 20,
                                  )),
                                ),
                              )
                            ],
                          ),
                        );
                      });
                } else
                  return Text("Text");
              }),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getInventory();
  }

  Widget MenuItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 26),
        // Text(
        //   "${duration}",
        //   style: TextStyle(
        //     color: Color(0xffFE506D),
        //     fontFamily: "Gilroy",
        //     fontWeight: FontWeight.bold,
        //     fontSize: 20.0,
        //   ),
        // ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            // margin: EdgeInsets.only(left: 15.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      timeslot = "10AM - 12PM";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(
                        "10AM - 12PM",
                        style: TextStyle(
                            fontSize: timeslot == "10AM - 12PM" ? 18.0 : 15.0,
                            color: timeslot == "10AM - 12PM"
                                ? Color(0xffFE506D)
                                : Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      )),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      timeslot = "01PM - 04PM";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(
                        "01PM - 04PM",
                        style: TextStyle(
                            fontSize: timeslot == "01PM - 04PM" ? 18.0 : 15.0,
                            color: timeslot == "01PM - 04PM"
                                ? Color(0xffFE506D)
                                : Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      )),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      timeslot = "06PM - 09PM";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(
                        "06PM - 09PM",
                        style: TextStyle(
                            fontSize: timeslot == "06PM - 09PM" ? 18.0 : 15.0,
                            color: timeslot == "06PM - 09PM"
                                ? Color(0xffFE506D)
                                : Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      )),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: StreamBuilder(
                stream: firestore
                    .collection("homemakers")
                    .document(_uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.data.data == null) {
                    return Center(
                        child: Text(
                      "Your Menu is Empty!!",
                      style: TextStyle(fontSize: 30),
                    ));
                  } else if (snapshot.hasData) {
                    return Container(
                      height: 250,
                      child: ListView.builder(
                          itemCount: snapshot.data.data["menu"].length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            if ((snapshot.data.data["menu"][index]["timeslot"]).toString() ==
                                timeslot) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "${snapshot.data.data["menu"][index]["name"]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Gilroy",
                                          fontSize: 21.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.8,
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${snapshot.data.data["menu"][index]["price"]}/plate",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: "Gilroy",
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.8,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }else{
                              return Container();
                            }
                          }),
                    );
                    // users = snapshot.data.documents
                    //     .map((doc) => User.fromMap(doc.data, doc.documentID))
                    //     .toList();
                    // print(snapshot.data.data["menu"]);
                    // return SingleChildScrollView(
                    //   child: DataTable(
                    //     columnSpacing: 90,
                    //     headingRowHeight: 0,
                    //     columns: [
                    //       DataColumn(
                    //         label: Text(
                    //           "",
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontFamily: "Gilroy",
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 15.0,
                    //             letterSpacing: -0.8,
                    //             height: 1.15,
                    //           ),
                    //         ),
                    //       ),
                    //       DataColumn(
                    //         label: Text(
                    //           "",
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontFamily: "Gilroy",
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 15.0,
                    //             letterSpacing: -0.8,
                    //             height: 1.15,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //     rows: users
                    //         .map((user) => DataRow(cells: [
                    //               DataCell(Text(
                    //                 "${snapshot.data.data["menu"]["name"]}",
                    //                 style: TextStyle(
                    //                   color: Colors.black,
                    //                   fontFamily: "Gilroy",
                    //                   fontSize: 15.0,
                    //                   fontWeight: FontWeight.bold,
                    //                   letterSpacing: -0.8,
                    //                   height: 1.15,
                    //                 ),
                    //               )),
                    //               DataCell(Text(
                    //                 "₹${snapshot.data.data["menu"]["price"]}/plate",
                    //                 style: TextStyle(
                    //                   color: Colors.black45,
                    //                   fontFamily: "Gilroy",
                    //                   fontSize: 15.0,
                    //                   letterSpacing: -0.8,
                    //                   height: 1.15,
                    //                 ),
                    //               )),
                    //             ]))
                    //         .toList(),
                    //   ),
                    // );
                  }
                }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MakerDrawerWidget(uid: _uid),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
                    Icons.assignment,
                    color: Color(0xffFE506D),
                  ),
                  title: Text("Home"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_books, color: Colors.black),
                  title: Text("Shop"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border, color: Colors.black),
                  title: Text("Shop"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.perm_identity, color: Colors.black),
                  title: Text("Profile"),
                )
              ],
            ),
          )),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 20, 25, 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // SizedBox(height: 20),
              Text(
                "Hi ${name},",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gilroy",
                  fontSize: 25.0,
                ),
              ),
              Text(
                "What are you cooking today?",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Gilroy",
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 41,
              ),
              Container(
                // margin: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "menu";
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "menu"),
                            style: TextStyle(
                                fontSize: menuType == "menu" ? 25.0 : 20.0,
                                color: menuType == "menu"
                                    ? Color(0xffFE4E74)
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "inventory";
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "inventory"),
                            style: TextStyle(
                                fontSize: menuType == "inventory" ? 25.0 : 20.0,
                                color: menuType == "inventory"
                                    ? Color(0xffFE4E74)
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 7),
              menuType == "menu"
                  ? Row(
                      children: <Widget>[
                        Text(
                          getTranslated(context, "currmenu"),
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Gilroy",
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        OutlineButton(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.edit,
                                  color: Color(0xffFE506D),
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                new Text(
                                  getTranslated(context, "edit"),
                                  style: TextStyle(
                                    color: Color(0xffFE506D),
                                    fontFamily: "Gilroy",
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                            borderSide: BorderSide(color: Color(0xffFE506D)),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, "/EditPage");
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(45.0))),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        getTranslated(context, "invmenu"),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Gilroy",
                          fontSize: 15.0,
                        ),
                      ),
                    ),
              SizedBox(height: 10),
              menuType == "menu" ? this.MenuItems() : this.InventoryItems(),
            ],
          ),
        ),
      ),
    );
  }
}
