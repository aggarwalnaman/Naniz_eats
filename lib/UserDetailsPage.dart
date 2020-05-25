import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geocoder/geocoder.dart';
import 'dart:async';
import 'localization/language.dart';
import 'localization/language_constants.dart';
import 'main.dart';

class UserDetailsPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String lang = "Please Select Your Language";
  Language language;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint point;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;

  String _cname = 'Enter City', _sname = 'Enter State', _dob = "";
  bool _pushNotifications = false, _newActivity = false, _newsLetter = false;
  var _phoneno;

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      point =
          geo.point(latitude: position.latitude, longitude: position.longitude);
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      print(place.locality +
          ' ' +
          place.administrativeArea +
          ' ' +
          place.subLocality +
          ' ' +
          place.subAdministrativeArea);

      setState(() {
        _cname = place.locality;
        _sname = place.administrativeArea;
      });
    } catch (e) {
      print(e);
    }
  }

  nextPage() {
    var tempc = _cname;
    var temps = _sname;
    var cart=[];
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _getAddressFromLatLng();
      print(_cname + ' ' + _sname);
      _auth.onAuthStateChanged.listen((user) async {
        firestore.collection('users').document(user.uid).setData({
          'name': _phoneno,
          'dob': _dob,
          'city': tempc,
          'state': temps,
          'language': lang,
          'position': point.data,
          'pn': _pushNotifications,
          'na': _newActivity,
          'nl': _newsLetter,
          'current_cart': cart,
          'userType': "user",
          'mobileno' : user.phoneNumber,
        }).whenComplete(() {
          Navigator.pushReplacementNamed(context, "/FoodPrefPage");
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50),
              Text(
                getTranslated(context, "details"),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gilroy",
                  fontSize: 30.0,
                ),
              ),
              SizedBox(height: 20),
              Text(
                getTranslated(context, "personal"),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gilroy",
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        style:
                            TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                        validator: (input) {
                          if (input.isEmpty) {
                            return getTranslated(context, "enterMob");
                          }
                        },
                        onSaved: (input) => _phoneno = input,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enterMob"),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        style:
                            TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                        // validator: (input) {
                        //   if (input.isEmpty) {
                        //     return "Enter Your Date of Birth";
                        //   }
                        // },
                        onSaved: (input) => _dob = input,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enterDOB"),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Text(
                        getTranslated(context, "geographical"),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gilroy",
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        enabled: false,
                        style:
                            TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                        // validator: (input) {
                        //   if (input.isEmpty) {
                        //     return "Enter Your City";
                        //   }
                        // },
                        // obscureText: this.hidePassword,
                        onSaved: (input) => _cname = input,
                        decoration: InputDecoration(
                          hintText: "${_cname}",
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        enabled: false,
                        style:
                            TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                        // validator: (input) {
                        //   if (input.isEmpty) {
                        //     return "Please Enter Your State";
                        //   }
                        // },
                        onSaved: (input) => _sname = input,
                        decoration: InputDecoration(
                          hintText: '${_sname}',
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _getCurrentLocation();
                        },
                        child: Text(
                          "Auto-Fetch (GPS)",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy",
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Center(
                          child: DropdownButton<Language>(
                            hint: Text(lang),
                            style: TextStyle(
                              color: Color.fromRGBO(38, 50, 56, 0.30),
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
                                .map<DropdownMenuItem<Language>>(
                                  (e) => DropdownMenuItem<Language>(
                                    value: e,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          e.name,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
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
                        height: 25.0,
                      ),
                      Text(
                        getTranslated(context, "notify"),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gilroy",
                          fontSize: 20.0,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            activeColor: Color(0xffFE4E74),
                            value: _pushNotifications,
                            onChanged: (bool value) {
                              setState(() {
                                _pushNotifications = value;
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          Text(
                            getTranslated(context, "pushNoti"),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Gilroy",
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            activeColor: Color(0xffFE4E74),
                            value: _newActivity,
                            onChanged: (bool value) {
                              setState(() {
                                _newActivity = value;
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          Text(
                            getTranslated(context, "newActivity"),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Gilroy",
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            activeColor: Color(0xffFE4E74),
                            value: _newsLetter,
                            onChanged: (bool value) {
                              setState(() {
                                _newsLetter = value;
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          Text(
                            getTranslated(context, "newsLetter"),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Gilroy",
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: EdgeInsets.fromLTRB(120, 20, 120, 0),
                      //   child: MaterialButton(
                      //     onPressed: () {
                      //       nextPage();
                      //     },
                      //     color: Color(0xffFE4E74),
                      //     textColor: Colors.white,
                      //     child: Icon(
                      //       Icons.arrow_forward_ios,
                      //       size: 24,
                      //     ),
                      //     padding: EdgeInsets.all(16),
                      //     shape: CircleBorder(),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(120, 20, 120, 0),
                        child: GestureDetector(
                          onTap: () {
                            nextPage();
                          },
                          child: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF6530),
                                      Color(0xFFFE4E74)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 30.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, "/ExplorePage");
                            },
                            child: Text(
                              getTranslated(context, "skipStep"),
                              style: TextStyle(
                                  fontFamily: "Gilroy",
                                  fontSize: 13.0,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
