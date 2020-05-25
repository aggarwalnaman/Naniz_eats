import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () => Navigator.pushNamed(context, '/AuthChoosePage'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(200),        
              bottomLeft: Radius.circular(700),
              topLeft: Radius.circular(250),
              topRight: Radius.circular(670),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffFF6530), Color(0xffFE4E74)])),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(image: AssetImage('images/cropped-naaniz-logo.png'),width: 203,height: 203,),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'C L O U D   K I T C H E N',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SF Pro Text',
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      )),
    );
  }
}
