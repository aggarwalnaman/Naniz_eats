import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/MakerDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Analytics extends StatefulWidget {
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

var user;
TextEditingController promoteDays = new TextEditingController();
TextEditingController promoteAmount = new TextEditingController();
TextEditingController promoters = new TextEditingController();
TextEditingController promoteCut = new TextEditingController();
TextEditingController promoteMessage = new TextEditingController();

class _AnalyticsState extends State<Analytics> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((value) {
      user = value.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      drawer: MakerDrawerWidget(uid: s),
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.black),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                "Analytics",
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 160),
              child: StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance
                      .collection("homemakers")
                      .document(s)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      final Map<String, dynamic> data = snapshot.data.data;
                      return ListView.builder(
                        // controller: _controller,
                        itemCount: snapshot.data.data['menu'].length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.all(5.0),
                            width: MediaQuery.of(context).size.width,
                            height: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Column(
                              children: <Widget>[
                                Row(
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    )
                                  ],
                                ),
                                data['menu'][index]['promoted'] == true
                                    ? OutlineButton(
                                        onPressed: () {},
                                        color: Colors.grey,
                                        child: Text(
                                          "Already Promoted",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: "Gilroy"),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          style: BorderStyle.solid,
                                          width: 1.8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      )
                                    : OutlineButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              elevation: 250,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(40.0),
                                                  topLeft:
                                                      Radius.circular(40.0),
                                                ),
                                              ),
                                              context: context,
                                              builder: (BuildContext contetx) {
                                                return SafeArea(
                                                  child: Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Divider(
                                                          color: Colors.grey,
                                                          height: 20,
                                                          thickness: 5,
                                                          indent: 120,
                                                          endIndent: 120,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8.0),
                                                        child: Text(
                                                          "Promote Dish",
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            SizedBox(width: 10),
                                                            Container(
                                                              width: 100,
                                                              height: 70,
                                                              decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(snapshot
                                                                              .data
                                                                              .data['menu'][index]
                                                                          [
                                                                          'image']),
                                                                      fit: BoxFit
                                                                          .fitWidth),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0)),
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  snapshot.data.data[
                                                                              'menu']
                                                                          [
                                                                          index]
                                                                      ['name'],
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "Gilroy",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          15.0,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                SizedBox(
                                                                  height: 5.0,
                                                                ),
                                                                SizedBox(
                                                                  height: 5.0,
                                                                ),
                                                                Text(
                                                                  "₹${snapshot.data.data['menu'][index]['price'].toString()}/plate",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "Gilroy",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          15.0,
                                                                      color: Colors
                                                                          .black),
                                                                )
                                                              ],
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 10,
                                                                      bottom:
                                                                          15),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: snapshot.data.data['menu'][index]['veg'] == true
                                                                                ? Colors.green
                                                                                : Colors.red,
                                                                            width: 1.0)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            10.0,
                                                                        height:
                                                                            10.0,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                50.0),
                                                                            color: snapshot.data.data['menu'][index]['veg'] == true
                                                                                ? Colors.green
                                                                                : Colors.red),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10.0,
                                                                  ),
                                                                  Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(snapshot
                                                                          .data
                                                                          .data[
                                                                              'menu']
                                                                              [
                                                                              index]
                                                                              [
                                                                              'rating']
                                                                          .toString()),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Color(
                                                                            0xffFE506D),
                                                                        size:
                                                                            15.0,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5.0,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "Promote for",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      "Gilroy"),
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                            Text(
                                                              "Target Amount",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      15.0,
                                                                  fontFamily:
                                                                      "Gilroy"),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Color(
                                                                    0xFFE5E5E5),
                                                              ),
                                                              height: 40.0,
                                                              width: 150,
                                                              child: TextField(
                                                                controller:
                                                                    promoteDays,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        "0 Days"),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Color(
                                                                    0xFFE5E5E5),
                                                              ),
                                                              height: 40.0,
                                                              width: 150,
                                                              child: TextField(
                                                                controller:
                                                                    promoteAmount,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        '0 \$'),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "Promoters",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      "Gilroy"),
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                            Text(
                                                              "Pomoter Cut",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      15.0,
                                                                  fontFamily:
                                                                      "Gilroy"),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Color(
                                                                    0xFFE5E5E5),
                                                              ),
                                                              height: 40.0,
                                                              width: 150,
                                                              child: TextField(
                                                                controller:
                                                                    promoters,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        "0 People"),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Color(
                                                                    0xFFE5E5E5),
                                                              ),
                                                              height: 40.0,
                                                              width: 150,
                                                              child: TextField(
                                                                controller:
                                                                    promoteCut,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        '0\$/Sale'),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        "Message",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15.0,
                                                            fontFamily:
                                                                "Gilroy"),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          color:
                                                              Color(0xFFE5E5E5),
                                                        ),
                                                        height: 40.0,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            50,
                                                        child: TextField(
                                                          controller:
                                                              promoteMessage,
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  hintText:
                                                                      'Message'),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10.0),
                                                        child: Container(
                                                          width: 250,
                                                          child: OutlineButton(
                                                            onPressed:
                                                                () async {
                                                              DocumentSnapshot
                                                                  snap =
                                                                  await Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "promotion")
                                                                      .document(
                                                                          s)
                                                                      .get();
                                                              List<dynamic>
                                                                  promotion =
                                                                  [];
                                                              snap.data[
                                                                      "promotion"]
                                                                  .forEach(
                                                                      (value) {
                                                                promotion
                                                                    .add(value);
                                                              });
                                                              promotion.add({
                                                                "name": snapshot
                                                                            .data
                                                                            .data[
                                                                        'menu'][
                                                                    index]['name'],
                                                                "price": snapshot
                                                                            .data
                                                                            .data[
                                                                        'menu'][
                                                                    index]['price'],
                                                                "image": snapshot
                                                                            .data
                                                                            .data[
                                                                        'menu'][
                                                                    index]['image'],
                                                                "rating": snapshot
                                                                            .data
                                                                            .data[
                                                                        'menu'][
                                                                    index]['rating'],
                                                                "veg": snapshot
                                                                            .data
                                                                            .data[
                                                                        'menu'][
                                                                    index]['veg'],
                                                                "promoted":
                                                                    true,
                                                                "promotedDays":
                                                                    promoteDays
                                                                        .text,
                                                                "promotedAmount":
                                                                    promoteAmount
                                                                        .text,
                                                                "promotedCut":
                                                                    promoteCut
                                                                        .text,
                                                                "promoters":
                                                                    promoters
                                                                        .text,
                                                                "message":
                                                                    promoteMessage
                                                                        .text
                                                              });
                                                              Firestore.instance
                                                                  .collection(
                                                                      "promotion")
                                                                  .document(s)
                                                                  .updateData({
                                                                "promotion":
                                                                    promotion
                                                              });
                                                              data['menu'][
                                                                          index]
                                                                      [
                                                                      'promoted'] =
                                                                  true;
                                                              Firestore.instance
                                                                  .collection(
                                                                      "homemakers")
                                                                  .document(s)
                                                                  .updateData({
                                                                "menu":
                                                                    data["menu"]
                                                              }).whenComplete(() =>
                                                                      Navigator.pop(
                                                                          context));
                                                            },
                                                            splashColor: Color(
                                                                0xffFE506D),
                                                            focusColor: Color(
                                                                0xffFE506D),
                                                            textColor:
                                                                Colors.white,
                                                            disabledTextColor:
                                                                Color(
                                                                    0xffFE506D),
                                                            highlightedBorderColor:
                                                                Color(
                                                                    0xffFE506D),
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0xffFE506D),
                                                              style: BorderStyle
                                                                  .solid,
                                                              width: 1.8,
                                                            ),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: Text(
                                                                "Promote",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xffFE506D),
                                                                  fontSize:
                                                                      15.0,
                                                                  fontFamily:
                                                                      "Gilroy",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        splashColor: Color(0xffFE506D),
                                        focusColor: Color(0xffFE506D),
                                        textColor: Colors.white,
                                        disabledTextColor: Color(0xffFE506D),
                                        highlightedBorderColor:
                                            Color(0xffFE506D),
                                        borderSide: BorderSide(
                                          color: Color(0xffFE506D),
                                          style: BorderStyle.solid,
                                          width: 1.8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Promote",
                                            style: TextStyle(
                                              color: Color(0xffFE506D),
                                              fontSize: 12.0,
                                              fontFamily: "Gilroy",
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ))
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
