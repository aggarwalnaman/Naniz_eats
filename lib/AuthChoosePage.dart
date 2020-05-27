import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/MakerOnBoardPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ExplorePage.dart';
import 'MenuPage.dart';
import 'OnBoardPage.dart';
import 'SignUpUserPage.dart';
import 'bottomBar.dart';
import 'SignUpMakerPage.dart' as maker;

class AuthChoosePage extends StatefulWidget {
  @override
  _AuthChoosePageState createState() => _AuthChoosePageState();
}

class _AuthChoosePageState extends State<AuthChoosePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  checkAuthentication() async {
    _auth.currentUser().then((value) {
      if (value.uid != null || value.uid != "") {
        Firestore.instance
            .collection("users")
            .document(value.uid)
            .get()
            .then((document) {
          if (document.data["userType"] == "users") { 
            Firestore.instance
                .collection("users")
                .document(value.uid)
                .get()
                .then((value) {
              if (value.data == null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => OnBoardPage()),
                    (route) => false);
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => ExplorePage()),
                    (route) => false);
              }
            });
          }
          else {
            Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => MenuPage()),
                (route) => false);
            Firestore.instance
                .collection("homemakers")
                .document(value.uid)
                .get()
                .then((value) {
              if (value.data == null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => MakerOnBoardPage()),
                    (route) => false);
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => MenuPage()),
                    (route) => false);
              }
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffFF6530), Color(0xffFE4E74)])),
      ),
      Positioned(
          top: 86,
          left: 120,
          right: 120,
          child: Image(
            image: AssetImage('images/Image1.png'),
          )),
      Positioned(
        top: 350,
        left: 100,
        right: 100,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          elevation: 0.0,
          child: MaterialButton(
            onPressed: () {
              //Implement login functionality.
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => SignUpPage()));
            },
            minWidth: 250.0,
            height: 50.0,
            child: Text(
              'LOG IN AS USER',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 415,
        left: 100,
        right: 100,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          elevation: 0.0,
          child: MaterialButton(
            onPressed: () {
              //Implement login functionality.
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => maker.SignUpPage()));
            },
            minWidth: 250.0,
            height: 50.0,
            child: Text(
              'LOGIN AS HOMEMAKER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ),
      Positioned(
          top: 485,
          left: 95,
          right: 95,
          child: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => ExplorePage()),
                  (route) => false);
            },
            child: Text(
              "Skip for Now",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 15.0,
              ),
            ),
          )),
      // Container(
      //   height: MediaQuery.of(context).size.height - 82.0,
      //   width: MediaQuery.of(context).size.width,
      //   color: Colors.transparent,
      // ),

      Positioned(
          top: 600,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45.0),
                  topRight: Radius.circular(45.0),
                )),
            height: MediaQuery.of(context).size.height - 82.0,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 60.0, 8.0, 0.0),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        onPressed: () {
                          //Implement login functionality.
                        },
                        height: 50,
                        child: Text(
                          'Sign In with Google',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy",
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                      MaterialButton(
                        color: Colors.black,
                        onPressed: () {
                          //Implement login functionality.
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        height: 50,
                        child: Text(
                          'Sign In with Apple',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy",
                            fontSize: 10.0,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          )),
      Positioned(
        top: 580,
        left: 120,
        right: 120,
        child: Material(
          shape: CircleBorder(),
          elevation: 10.0,
          child: CircleAvatar(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            radius: 25,
            child: Text(
              "OR",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ),
    ]));
  }
}
