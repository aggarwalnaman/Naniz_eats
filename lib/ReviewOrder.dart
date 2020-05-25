import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

Future<String> getUser() async {
  FirebaseUser user = await _auth.currentUser();
  return user.uid;
}

class ReviewOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    pop() => Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: ReviewOrderBody(
          map: ModalRoute.of(context).settings.arguments, pop: pop),
    );
  }
}

class ReviewOrderBody extends StatefulWidget {
  final Map map;
  final Function pop;
  ReviewOrderBody({this.map, this.pop});
  @override
  _ReviewOrderBodyState createState() => _ReviewOrderBodyState();
}

class _ReviewOrderBodyState extends State<ReviewOrderBody> {
  var _uid;

  void getData() async {
    _auth.onAuthStateChanged.listen((user) async {
      setState(() {
        _uid = user.uid;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  static const String serverKey =
      "AAAAgNeqQUU:APA91bGf97wJkAGes42Tr8LeUexfwQT5YlkgnjYrVo0ZlYRyEpHonanba-qcL-SHv5vBpCZmfpJaKIEjEnnBGTDLBLxP1YAfUTTUpQsTmjpi2foUEledKs8zPklBCv_nj2_YnhkYBAKV";

  List orders = [];
  void cancelItem(int index) async {
    firestore
        .collection('homemakers')
        .document(_uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == widget.map['orderId']) {
          List newItems = List.from(item['items']);
          newItems.removeAt(index);
          if (newItems.length != 0) {
            item['items'] = newItems;
            newOrders.add(item);
          }
        } else {
          newOrders.add(item);
        }
      }
      firestore
          .collection('homemakers')
          .document(_uid)
          .updateData({'orders': newOrders});
    });
    firestore
        .collection('users')
        .document(widget.map['user'])
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == widget.map['orderId']) {
          if (item['homemaker'] == _uid) {
            List newItems = List.from(item['items']);
            newItems.removeAt(index);
            if (newItems.length != 0) {
              item['items'] = newItems;
              newOrders.add(item);
            }
          }
          else{
            newOrders.add(item);
          }
        } else {
          newOrders.add(item);
        }
      }
      firestore
          .collection('users')
          .document(widget.map['user'])
          .updateData({'orders': newOrders});
    });
      await http
      .post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': '${orders[index]["item"]} has been cancelled',
          'title': '${orders[index]["item"]} has been cancelled'
        },
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': orders[index]["token"],
      },
    ),
  )
      .then((value) {
    print(value.body);
  });
  orders.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    String username;
    getUser().then((value) => username = value);
    return StreamBuilder(
      stream: firestore
          .collection('homemakers')
          .document(_uid)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> toShow = [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Text(
                "Review order,",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          )
        ];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          List orders = List.from(snapshot.data['orders']);
          for (int i = 0; i < orders.length; i++) {
            if (Map.from(orders[i])['orderId'] == widget.map['orderId']) {
              List items = List.from(Map.from(orders[i])['items']);
              for (int j = 0; j < items.length; j++) {
                toShow.add(
                  CustomReviewCard(
                      item: Map.from(items[j])['item'],
                      quantity: Map.from(items[j])['quantity'],
                      index: j,
                      callback: cancelItem),
                );
              }
            }
          }
        }

        if (toShow.length > 1) {
          return ListView(shrinkWrap: true, children: toShow);
        } else {
          return Center(
            child: Text(
              "Order Cancelled",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }
}

class CustomReviewCard extends StatelessWidget {
  final Function callback;
  final String item;
  final int quantity;
  final int index;
  final int mapNumber;
  final DocumentReference order;
  CustomReviewCard(
      {this.item,
      this.quantity,
      this.index,
      this.callback,
      this.order,
      this.mapNumber});
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 5.0),
              blurRadius: 6.0,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "$item",
                        style: TextStyle(fontSize: 15),
                      )),
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "x$quantity",
                        style: TextStyle(fontSize: 18),
                      )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ButtonTheme(
                minWidth: 5.0,
                height: 20.0,
                child: OutlineButton(
                  color: Color(0xffFE506D),
                  textColor: Color(0xffFE506D),
                  borderSide: BorderSide(
                    color: Color(0xffFE506D),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.close)),
                  onPressed: () {
                    callback(this.index);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
