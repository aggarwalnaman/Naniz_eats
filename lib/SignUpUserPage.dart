import 'package:econoomaccess/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ExplorePage.dart';
import 'OnBoardPage.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geocoder/geocoder.dart';
import 'SignUpMakerPage.dart';

bool load = false;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

TextEditingController mobNo = new TextEditingController();
TextEditingController _name = new TextEditingController();

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Firestore firestore = Firestore.instance;
  StreamSubscription subscription;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user.displayName.contains('User')) {
        Navigator.pushReplacementNamed(context, "/UserDetailsPage");
      } else {
        Navigator.pushReplacementNamed(context, "/ExplorePage");
      }
    });
  }

  // signUp() async {
  //   if (_formKey.currentState.validate()) {
  //     _formKey.currentState.save();
  //     try {
  //       await
  //       var user;
  //       if (user != null) {
  //         // subscription = location
  //         //     .onLocationChanged()
  //         //     .listen((LocationData currentLocation) {
  //         //   GeoFirePoint point = geo.point(
  //         //       latitude: currentLocation.latitude,
  //         //       longitude: currentLocation.longitude);

  //         UserUpdateInfo updateInfo = UserUpdateInfo();
  //         updateInfo.displayName = _name + '_User';
  //         user.updateProfile(updateInfo);

  //         firestore.collection('users').document(_name + '_User').setData({
  //           'name': _name,
  //           'mobile': _mobNo,
  //           // 'position': point.data,
  //         }).then((doc) =>
  //             {Navigator.pushReplacementNamed(context, "/OnBoardPage")});
  //         // });
  //       }
  //     } catch (e) {
  //       this.showError(e.message);
  //     }
  //   }
  // }

  verificationCompleted(AuthCredential authCredential, BuildContext context) {
    _auth.signInWithCredential(authCredential).then((value) {
      Firestore.instance
          .collection("users")
          .document(value.user.uid)
          .get()
          .then((value) {
        if (value.data == null) {
          setState(() {
            load = true;
          });
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => OnBoardPage()),
              (route) => false);
        } else {
          setState(() {
            load = false;
          });
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => ExplorePage()),
              (route) => false);
        }
      });
      // UserUpdateInfo updateInfo = UserUpdateInfo();
      // updateInfo.displayName = _name;
      // firestore
      //     .collection("users")
      //     .document(value.user.uid + "_user")
      //     .setData({"name": _name, "mobile": mobNo.text});
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     CupertinoPageRoute(builder: (context) => ExplorePage()),
      //     (route) => false);
    });
  }

  verificationFailed(AuthException authException, BuildContext context) {
    Fluttertoast.showToast(msg: authException.message);
  }

  smsSent(String verificationId, List<int> code, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => otpPage(context, verificationId)));
  }

  codeAutoRetrieval() {}

  showError(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(errorMessage),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Loading() : Scaffold(
      body: Stack(
        children: <Widget>[
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
          Padding(
            padding: EdgeInsets.fromLTRB(30, 300, 30, 0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                    validator: (input) {
                      if (input.isEmpty) {
                        return "Enter Mobile No.";
                      }
                    },
                    controller: mobNo,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: 'Mobile no.',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(38, 50, 56, 0.30),
                        fontSize: 15.0,
                        fontFamily: "Gilroy",
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  SizedBox(
                    height: 49.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      elevation: 0.0,
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            load=true;
                          });
                          //Implement login functionality.
                          _auth.verifyPhoneNumber(
                              phoneNumber: "+91" + mobNo.text,
                              timeout: Duration(seconds: 10),
                              verificationCompleted: (authCredential) =>
                                  verificationCompleted(
                                      authCredential, context),
                              verificationFailed: (authException) =>
                                  verificationFailed(authException, context),
                              codeSent: (verificationId, [code]) =>
                                  smsSent(verificationId, [code], context),
                              codeAutoRetrievalTimeout: (verificationId) =>
                                  Fluttertoast.showToast(
                                      msg: "Enter OTP manually"));
                        },
                        minWidth: 220.0,
                        height: 50.0,
                        child: Text(
                          'LOGIN',
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
                  SizedBox(
                    height: 30.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SignUpPage()));
                    },
                    child: Text(
                      "Sign Up as Homemaker instead",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy",
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget otpPage(BuildContext context, String verificationId) {
  TextEditingController otp = new TextEditingController();
  return Scaffold(
    body: Stack(
      children: <Widget>[
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
        Padding(
          padding: EdgeInsets.fromLTRB(30, 300, 30, 0),
          child: SingleChildScrollView(
            child: Form(
              child: Column(children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                  validator: (input) {
                    if (input.isEmpty) {
                      return "Please Enter OTP";
                    }
                  },
                  controller: otp,
                  decoration: InputDecoration(
                    hintText: 'Enter OTP',
                    hintStyle: TextStyle(
                      color: Color.fromRGBO(38, 50, 56, 0.30),
                      fontSize: 15.0,
                      fontFamily: "Gilroy",
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                SizedBox(
                  height: 49.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    elevation: 0.0,
                    child: MaterialButton(
                      onPressed: () async {
                        //Implement login functionality.
                        Fluttertoast.showToast(
                            msg: "Please Wait", timeInSecForIosWeb: 3);
                        final AuthCredential credential =
                            PhoneAuthProvider.getCredential(
                                verificationId: verificationId,
                                smsCode: otp.text);
                        FirebaseAuth.instance
                            .signInWithCredential(credential)
                            .then((value) {
                          Firestore.instance
                              .collection("users")
                              .document(value.user.uid)
                              .get()
                              .then((value) {
                            if (value.data == null) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => OnBoardPage()),
                                  (route) => false);
                            } else {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => ExplorePage()),
                                  (route) => false);
                            }
                          });
                          // Firestore.instance
                          //     .collection("users")
                          //     .document(value.user.uid)
                          //     .setData(
                          //         {"name": _name.text, "mobile": mobNo.text});
                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     CupertinoPageRoute(
                          //         builder: (context) => ExplorePage()),
                          //     (route) => false);
                        });
                      },
                      minWidth: 220.0,
                      height: 50.0,
                      child: Text(
                        'SUBMIT',
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
                SizedBox(
                  height: 30.0,
                ),
              ]),
            ),
          ),
        ),
      ],
    ),
  );
}
