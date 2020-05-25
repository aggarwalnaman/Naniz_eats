import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geocoder/geocoder.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Firestore firestore = Firestore.instance;
  StreamSubscription subscription;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();

  String _name, _emailid, _password, _cpassword;

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user.displayName.contains('User')) {
        Navigator.pushReplacementNamed(context, "/UserDetailsPage");
      }else{
        Navigator.pushReplacementNamed(context, "/ExplorePage");
      }
    });
  }

  signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_cpassword == _password) {
        try {
          FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
                  email: _emailid, password: _password))
              .user;

          if (user != null) {
            // subscription = location
            //     .onLocationChanged()
            //     .listen((LocationData currentLocation) {
            //   GeoFirePoint point = geo.point(
            //       latitude: currentLocation.latitude,
            //       longitude: currentLocation.longitude);

            UserUpdateInfo updateInfo = UserUpdateInfo();
            updateInfo.displayName = _name+'_User';
            user.updateProfile(updateInfo);

            firestore.collection('users').document(_name+'_User').setData({
              'name': _name,
              'email': _emailid,
              // 'position': point.data,
            }).then((doc)=>{
              Navigator.pushReplacementNamed(context, "/OnBoardPage")
            });
            // });
          }
        } catch (e) {
          this.showError(e.message);
        }
      } else {
        this.showError("Password Doesn't Match !!!");
      }
    }
  }

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
    this.checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
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
                key: _formKey,
                child: Column(children: <Widget>[
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                    validator: (input) {
                      if (input.isEmpty) {
                        return "Enter Your Full Name";
                      }
                    },
                    onSaved: (input) => _name = input,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
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
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                    validator: (input) {
                      if (input.isEmpty) {
                        return "Enter Your E-mail Id";
                      }
                    },
                    onSaved: (input) => _emailid = input,
                    decoration: InputDecoration(
                      hintText: 'E-Mail ID',
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
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                    validator: (input) {
                      if (input.isEmpty) {
                        return "Enter Your Password";
                      }
                    },
                    // obscureText: this.hidePassword,
                    onSaved: (input) => _password = input,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                    validator: (input) {
                      if (input.isEmpty) {
                        return "Confirm your Password";
                      }
                    },
                    // obscureText: this.hidePassword,
                    onSaved: (input) => _cpassword = input,
                    decoration: InputDecoration(
                      hintText: 'Re-Enter your Password',
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
                          //Implement login functionality.
                          signUp();
                        },
                        minWidth: 220.0,
                        height: 50.0,
                        child: Text(
                          'SIGN UP',
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
                    onTap: () {},
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
