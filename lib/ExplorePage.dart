import 'package:geolocator/geolocator.dart';
import 'drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'AuthChoosePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'localization/language_constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'dart:developer';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _database = Firestore.instance;
  FirebaseUser user;
  var uid;
  Geoflutterfire geo;
  Position position;

  // Location location;

  Future<String> getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        user = val;
        uid = val.uid;
      });
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    orderSuccessful(response.orderId);
    print("The order was successfull");
    //Add success popup
    Navigator.pushReplacementNamed(context, "/ExplorePage");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("There was an error");
    //Add Failure popup
    Navigator.pushReplacementNamed(context, "/ExplorePage");
  }

  String menuType = "special";
  Map<String, dynamic> pref;
  Razorpay _razorpay;
  @override
  void initState() {
    super.initState();
    Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position value) => setState(() {
          position = value;
        }));
    initDynamicLink();
    geo = Geoflutterfire();
    getUser();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Widget TopRated() {
    if (position == null) {
      return Center(child: Text("OOPS, Looks like no one is serving!"));
    }
    return StreamBuilder(
      stream: geo
          .collection(collectionRef: _database.collection('homemakers'))
          .within(
              center: geo.point(
                  latitude: position.latitude, longitude: position.longitude),
              radius: 10,
              field: 'position'),
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            print(position);
        List<DocumentSnapshot> topRated = [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          snapshot.data.every((element) {
            if (topRated.length < 5) {
              topRated.add(element);
            }
            return true;
          });
          if (snapshot.data.isEmpty) {
            return Center(child: Text("OOPS, Looks like no one is serving!"));
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 220.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topRated.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/ProfilePage',
                        arguments: snapshot.data[index].documentID);
                  },
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.all(10.0),
                    width: 160.0,
                    height: 220.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                snapshot.data[index].data['image']),
                            fit: BoxFit.fill)),
                    child: Container(
                      padding: EdgeInsets.only(left: 5.0),
                      width: 160,
                      height: 60.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${snapshot.data[index].data["name"]}\'s Kitchen",
                            style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                snapshot.data[index].data['mealtype'][0] +
                                    " | " +
                                    snapshot.data[index].data["rating"]
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontFamily: "Gilroy",
                                    color: Colors.black),
                              ),
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
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  void orderSuccessful(String orderId) async {
    List cart;
    String fcmToken = await fcm.FirebaseMessaging().getToken();
    // FirebaseUser user = await _auth.currentUser();
    List<Map> orders = [];
    await _database.collection('users').document(this.uid).get().then(
      (DocumentSnapshot userSnapshot) {
        cart = List.from(Map.from(userSnapshot.data)['current_cart']);
        for (int i = 0; i < cart.length; i++) {
          Map item = Map.from(cart[i]);
          bool found = false;
          for (int i = 0; i < orders.length; i++) {
            if (orders[i]['homemaker'] == item['homemaker']) {
              found = true;
              orders[i]['items'].add({
                'quantity': item['quantity'],
                'item': Map.from(item['item'])['name'],
              });
            }
          }
          if (!found) {
            orders.add({
              'token': fcmToken,
              'orderId': orderId,
              'user': this.uid.toString(),
              'homemaker': item['homemaker'],
              'items': [
                {
                  'quantity': item['quantity'],
                  'item': Map.from(item['item'])['name'],
                }
              ],
              'Home_Delivery': Provider.of<PriceModel>(context).delivery,
              'order_placed_at': Timestamp.now(),
              'accepted': false,
              'order_accepted_at': Timestamp.now(),
              'out_for_delivery': false,
              'order_out_for_delivery_at': Timestamp.now(),
              'delivered': false,
              'order_delivered_at': Timestamp.now(),
            });
          }
        }
      },
    );
    _database.collection('users').document(this.uid).updateData(
        {'orders': FieldValue.arrayUnion(orders), 'current_cart': []});
    for (int i = 0; i < orders.length; i++) {
      _database
          .collection('homemakers')
          .document(orders[i]['homemaker'])
          .updateData({
        'orders': FieldValue.arrayUnion([orders[i]])
      });
    }
  }

  void _settingModalBottomSheet(context, String user) async {
    List cart = [];
    getData() async {
      await _database
          .collection('users')
          .document(user)
          .get()
          .then((DocumentSnapshot value) {
        print(List.from(Map.from(value.data)['current_cart']));
        Provider.of<PriceModel>(context).cart =
            List.from(Map.from(value.data)['current_cart']);
        Provider.of<PriceModel>(context).convert();
        Provider.of<PriceModel>(context).calcPrice();
      });
    }

    await getData();
    cart = Provider.of<PriceModel>(context).cart;
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        elevation: 250,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40.0),
            topLeft: Radius.circular(40.0),
          ),
        ),
        context: context,
        builder: (BuildContext bc) {
          return Consumer<PriceModel>(
            builder: (BuildContext context, value, Widget child) {
              return SafeArea(
                child: cart.length == 0
                    ? Container(
                        height: 150,
                        child: Center(
                            child: Text(
                          "Cart Empty!",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 40),
                        )),
                      )
                    : Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Divider(
                              color: Colors.grey,
                              height: 20,
                              thickness: 5,
                              indent: 120,
                              endIndent: 120,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Cart",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: cart.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            cart[index]['item']['image'],
                                            height: 70.0,
                                            width: 90.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      cart[index]['item']
                                                          ['name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Image.network(
                                                    cart[index]['item']['veg']
                                                        ? 'https://s21425.pcdn.co/wp-content/uploads/2013/05/veg-300x259.jpg'
                                                        : 'https://www.iec.edu.in/app/webroot/img/Icons/84246.png',
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      value.reduceQuantity(
                                                          index,
                                                          _database
                                                              .collection(
                                                                  'users')
                                                              .document(user));
                                                    },
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 3.0,
                                                        horizontal: 15.0),
                                                    child: Text(
                                                        "${value.getQuantity(index)}"),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              Colors.black38),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      value.addQuantity(
                                                          index,
                                                          _database
                                                              .collection(
                                                                  'users')
                                                              .document(user));
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ]),
                                        Text(
                                          "₹${value.getQuantity(index) * value.getPrice(index)}",
                                          style: TextStyle(
                                              color: Color(0xffFE506D),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Total",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("(Inc. All Taxes)")
                                  ],
                                ),
                                Text(
                                  "₹${value.price}",
                                  style: TextStyle(
                                      color: Color(0xffFE506D),
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 150.0,
                                  child: RaisedButton(
                                    color: value.delivery
                                        ? Color(0xffFE506D)
                                        : Colors.white,
                                    textColor: value.delivery
                                        ? Colors.black
                                        : Colors.grey,
                                    elevation: null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Text(
                                      "Home Delivery",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontFamily: "Gilroy",
                                      ),
                                    ),
                                    onPressed: () => value.deliveryPressed(),
                                  ),
                                ),
                                Container(
                                  width: 150.0,
                                  child: RaisedButton(
                                    color: value.selfPU
                                        ? Color(0xffFE506D)
                                        : Colors.white,
                                    textColor: value.selfPU
                                        ? Colors.black
                                        : Colors.grey,
                                    elevation: null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Text(
                                      "Pick Up",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontFamily: "Gilroy",
                                      ),
                                    ),
                                    onPressed: () => value.puPressed(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              width: 250.0,
                              child: OutlineButton(
                                  color: Color(0xffFE506D),
                                  textColor: Color(0xffFE506D),
                                  borderSide: BorderSide(
                                    color: Color(0xffFE506D),
                                    style: BorderStyle.solid,
                                    width: 1.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Proceed to Pay",
                                      style: TextStyle(
                                        color: Color(0xffFE506D),
                                        fontSize: 15.0,
                                        fontFamily: "Gilroy",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    var options = {
                                      'key': 'rzp_test_0RVqU3HILYRp5O',
                                      'amount': value.price * 100,
                                      'name': 'Naniz',
                                      'description': 'Food Delivery',
                                      'prefill': {
                                        'contact':
                                            '8945529381',
                                        'email': 'mashutoshrao@gmail.com',
                                      },
                                    };
                                    try {
                                      _razorpay.open(options);
                                    } catch (e) {
                                      debugPrint(e);
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
              );
            },
          );
        });
  }

  ScrollController _controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;
    var temp;
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
      if (_selectedIndex == 1) {
        Navigator.pushReplacementNamed(context, "/SearchPage");
      } else if (_selectedIndex == 2) {
        Navigator.pushReplacementNamed(context, "/FavoriteScreenPage",
            arguments: this.uid);
      } else if (_selectedIndex == 3) {
        Navigator.pushReplacementNamed(context, "/UserProfilePage");
      }
    }

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
                  ),
                  title: Text("Explore"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, color: Colors.black),
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
      drawer: DrawerWidget(uid: this.uid),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.shopping_cart,
                size: 25.0,
                color: Colors.black,
              ),
              onPressed: () async {
                FirebaseAuth.instance.currentUser().then((value) async {
                  if (value != null) {
                    _settingModalBottomSheet(context, uid);
                  } else {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => AuthChoosePage()));
                    Fluttertoast.showToast(msg: "Please Login to continue");
                  }
                });
              })
        ],
        backgroundColor: Color(0xfff9f9f9),
        elevation: 0.0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFF9F9F9),
        child: ListView(
          physics: BouncingScrollPhysics(),
          controller: _controller,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                getTranslated(context, "discover"),
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15.0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        menuType = "special";
                      });
                    },
                    child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: Text(
                          getTranslated(context, "specials"),
                          style: TextStyle(
                              fontSize: menuType == "special" ? 18.0 : 15.0,
                              color: menuType == "special"
                                  ? Colors.black
                                  : Colors.black26,
                              fontFamily: "Gilroy"),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        menuType = "top";
                      });
                    },
                    child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: Text(
                          getTranslated(context, "top"),
                          style: TextStyle(
                              fontSize: menuType == "top" ? 18.0 : 15.0,
                              color: menuType == "top"
                                  ? Colors.black
                                  : Colors.black26,
                              fontFamily: "Gilroy"),
                        )),
                  ),
                ],
              ),
            ),
            menuType == "top" ? TopRated() : TopRated(),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                getTranslated(context, "topPicks"),
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Gilroy"),
              ),
            ),
            position != null
                ? StreamBuilder(
                    stream: geo
                        .collection(
                            collectionRef: _database.collection('homemakers'))
                        .within(
                            center: geo.point(
                                latitude: position.latitude,
                                longitude: position.longitude),
                            radius: 10,
                            field: 'position'),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData) {
                        List<DocumentSnapshot> temp = [];
                        List<Map<String, dynamic>> menu = [];
                        snapshot.data.every((element) {
                          temp.add(element);
                          return true;
                        });
                        if (snapshot.data.isEmpty) {
                          return Center(
                              child:
                                  Text("OOPS, Looks like no one is serving!"));
                        }

                        temp.every((element) {
                          for (int i = 0;
                              i < element.data["menu"].length;
                              i++) {
                            menu.add({
                              "name": element.data["name"],
                              "item": element.data["menu"][i]
                            });
                          }
                          return true;
                        });

                        return Container(
                          // width: MediaQuery.of(context).size.width,
                          height: 500,
                          child: ListView.builder(
                            controller: _controller,
                            itemCount: menu.length,
                            itemBuilder: (BuildContext context, int index) {
                              print(menu[index]);
                              return Dismissible(
                                key: Key(menu[index]["item"]["name"]),
                                onDismissed: (direction) {
                                  print(snapshot.data[index].documentID);
                                  _database
                                      .collection('users')
                                      .document(user.uid)
                                      .get()
                                      .then((DocumentSnapshot usersnapshot) => {
                                            if (usersnapshot.exists)
                                              {
                                                if (usersnapshot
                                                        .data['current_cart'] ==
                                                    null)
                                                  {
                                                    _database
                                                        .collection('users')
                                                        .document(uid)
                                                        .updateData({
                                                      'current_cart': [
                                                        {
                                                          'homemaker': snapshot
                                                              .data[index]
                                                              .documentID,
                                                          'item': menu[index]["item"],
                                                          'quantity': 1
                                                        }
                                                      ]
                                                    })
                                                  }
                                                else
                                                  {
                                                    _database
                                                        .collection('users')
                                                        .document(uid)
                                                        .updateData({
                                                      'current_cart': FieldValue
                                                          .arrayUnion([
                                                        {
                                                          'homemaker': snapshot
                                                              .data[index]
                                                              .documentID,
                                                          'item': menu[index]["item"],
                                                          'quantity': 1
                                                        }
                                                      ])
                                                    })
                                                  }
                                              }
                                          });
                                },
                                background: Container(
                                    color: Color(0xffFE516E),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text("BUY",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25)),
                                        ],
                                      ),
                                    )),
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width,
                                  height: 85,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Container(
                                        width: 100,
                                        height: 70,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(menu[index]
                                                    ["item"]["image"]),
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
                                            menu[index]["item"]["name"],
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
                                            "${menu[index]["name"]}\'s Kitchen",
                                            style: TextStyle(
                                                fontFamily: "Gilroy",
                                                fontSize: 13.0,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            "₹${menu[index]["item"]["price"].toString()}/plate",
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
                                                      color: menu[index]["item"]
                                                                  ["veg"] ==
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
                                                      color: menu[index]["item"]
                                                                  ["veg"] ==
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
                                                Text(menu[index]["item"]
                                                        ["rating"]
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
                        );
                      }
                    },
                  )
                : Center(
                    child:
                        Text("Oops, Looks like no one is delivering near you!"),
                  ),
          ],
        ),
      ),
    );
  }
  void initDynamicLink() async {
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      Navigator.of(context).pushReplacementNamed("/ExplorePage",
          arguments: deepLink.pathSegments);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData link) async {
          final Uri deepLink = link?.link;
          if (deepLink != null) {
            log("${deepLink.pathSegments}");
            Navigator.of(context).pushReplacementNamed("/ExplorePage",
                arguments: deepLink.pathSegments);
          }
        }, onError: (OnLinkErrorException e) async {
      log("error");
      log(e.message);
    });
  }
}

class PriceModel extends ChangeNotifier {
  bool _selfPU = false;
  bool _delivery = false;
  int _price = 0;
  List _cart = [];

  bool get selfPU => _selfPU;
  bool get delivery => _delivery;

  void convert() {
    for (int i = 0; i < _cart.length; i++) {
      _cart[i] = Map.from(_cart[i]);
      _cart[i]['item'] = Map.from(_cart[i]['item']);
    }
  }

  void calcPrice() {
    _price = 0;
    for (int i = 0; i < _cart.length; i++) {
      _price += _cart[i]['quantity'] * _cart[i]['item']['price'];
    }
  }

  set cart(item) => _cart = item;
  List get cart => _cart;

  int getQuantity(int index) {
    return _cart[index]['quantity'];
  }

  void addQuantity(index, user) {
    _cart[index]['quantity'] += 1;
    _price += _cart[index]['item']['price'];
    user.updateData({'current_cart': _cart});
    notifyListeners();
  }

  void reduceQuantity(index, user) {
    _cart[index]['quantity'] -= 1;
    _price -= _cart[index]['item']['price'];
    if (_cart[index]['quantity'] == 0) {
      _cart.removeAt(index);
    }
    user.updateData({'current_cart': _cart});
    notifyListeners();
  }

  int getPrice(index) {
    return _cart[index]['item']['price'];
  }

  void puPressed() {
    _selfPU = true;
    if (_delivery) {
      _delivery = false;
    }
    notifyListeners();
  }

  void deliveryPressed() {
    _delivery = true;
    if (_selfPU) {
      _selfPU = false;
    }
    notifyListeners();
  }

  int get price => _price;
  set price(amount) => _price = amount;
  void add(int amount) {
    _price += amount;
    notifyListeners();
  }

  void subtract(int amount) {
    _price -= amount;
    notifyListeners();
  }

  void printSummary() {
    print(
        "Cart items with quantity : $_cart\nSelf Pick Up : $_selfPU\nDelivery : $_delivery\nTotal cost : $_price");
  }
}
