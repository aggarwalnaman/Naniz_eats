import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'localization/language_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'exchange.dart';
import 'ProfilePageOptions.dart';

const PdfColor green = PdfColor.fromInt(0xffFF6530);
const PdfColor lightGreen = PdfColor.fromInt(0xffFE4E74);

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var temp;
  var documentName;
  fcm.FirebaseMessaging firebaseMessaging = new fcm.FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;
    documentName = s;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 25.0,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/ExplorePage');
            }),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
          child: StreamBuilder<DocumentSnapshot>(
              stream:
                  firestore.collection("homemakers").document(s).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  print(snapshot.data.data);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(80, 0.0, 80, 0),
                        child: Column(
                          children: <Widget>[
                            Container(
                                width: 91,
                                height: 91,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: new NetworkImage(
                                            "${snapshot.data.data['image']}")))),
                            SizedBox(height: 5),
                            Text(
                              "${snapshot.data.data['name']}\'s Kitchen",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  '${snapshot.data.data['mealtype'][0]} |',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '${snapshot.data.data['rating']}',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xffFE506D),
                                      size: 13.0,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              '${snapshot.data.data['city']}, ${snapshot.data.data['state']}',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(color: Colors.pink),
                              ),
                              onPressed: null,
                              child: Text(
                                'Operating ${snapshot.data.data['ohours']}',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Gilroy",
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            snapshot.data.data['delivery']
                                ? FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.pink),
                                    ),
                                    onPressed: null,
                                    child: Text(
                                      'Delivery Available',
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gilroy",
                                          fontSize: 10),
                                    ),
                                  )
                                : FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.pink),
                                    ),
                                    onPressed: null,
                                    child: Text(
                                      'Self-Pickup only',
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gilroy",
                                          fontSize: 10),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      
                      ProfilePageOptions(data: snapshot.data.data,docId: snapshot.data.documentID,),
                      Text(
                        getTranslated(context, "menu"),
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "${snapshot.data.data['ohours']}",
                        style: TextStyle(
                          color: Color(0xffFE506D),
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 500,
                        child: ListView.builder(
                          // controller: _controller,
                          itemCount: snapshot.data.data['menu'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                    '/RecipePage',
                                    arguments: ScreenArguments(snapshot.data.documentID, snapshot.data.data['menu'][index]['name'],index));
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
                                    SizedBox(width: 10),
                                    Container(
                                      width: 100,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  snapshot.data.data['menu']
                                                      [index]['image']),
                                              fit: BoxFit.fitWidth),
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          snapshot.data.data['menu'][index]
                                              ['name'],
                                          style: TextStyle(
                                              fontFamily: "Gilroy",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.0,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          "${snapshot.data.data['name']}\'s Kitchen",
                                          style: TextStyle(
                                              fontFamily: "Gilroy",
                                              fontSize: 13.0,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          "₹${snapshot.data.data['menu'][index]['price'].toString()}/plate",
                                          style: TextStyle(
                                              fontFamily: "Gilroy",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.0,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                    Expanded(child: SizedBox()),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, bottom: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: snapshot.data.data[
                                                                        'menu']
                                                                    [index]
                                                                ['veg'] ==
                                                            true
                                                        ? Colors.green
                                                        : Colors.red,
                                                    width: 1.0)),
                                            child: Center(
                                              child: Container(
                                                width: 10.0,
                                                height: 10.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: snapshot.data.data[
                                                                        'menu']
                                                                    [index]
                                                                ['veg'] ==
                                                            true
                                                        ? Colors.green
                                                        : Colors.red),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(snapshot.data
                                                  .data['menu'][index]['rating']
                                                  .toString()),
                                              Icon(
                                                Icons.star,
                                                color: Color(0xffFE506D),
                                                size: 15.0,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
        )),
      ),
    );
  }
}
