import 'package:flutter/material.dart';

class MakerInstructions extends StatelessWidget {
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
              top: 100,
              left: 30,
              child: Text(
                "You're all set!",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
              )),
          Positioned(
              top: 200,
              left: 30,
              child: Text(
                "We are generating your digital menu.All\nyour prices will be marked up by 5% which\nwill be Naaniz's cut. You will be payed all\nthe earned amount upon the completion of\nyour order directly to your wallet. You can\ntransfer your wallet content to your bank\naccount anytime you want.\nYou can also promote your products by\nadvertising on our platform.",
                style: TextStyle(fontSize: 15,color: Colors.white),
              )),
          Positioned(
              top: 500,
              left: 105,
              right: 105,
              child: Text(
                "Happy Cooking!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
              )),
          Positioned(
            top: 550,
            left: 100,
            right: 100,
            child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                elevation: 0.0,
                child: MaterialButton(
                  onPressed: () {
                    //Implement login functionality.
                    Navigator.pushReplacementNamed(context, "/MenuPage");
                  },
                  minWidth: 200.0,
                  height: 40.0,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
}
