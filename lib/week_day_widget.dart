import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';

class Weekday extends StatefulWidget {
  final String desc, temp;
  final GeoPoint geopoint;
  final String user_uid,uid;
  const Weekday({Key key, this.desc, this.temp,this.geopoint,this.user_uid,this.uid}) : super(key: key);
  @override
  _WeekdayState createState() => _WeekdayState();
}

class _WeekdayState extends State<Weekday> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final _database = Firestore.instance;
  Geoflutterfire geo;
  List<dynamic> weekDates = [];
  var dateTime = DateTime.now();
  List<String> monthList = [];
  List<String> weekList = [];
  final List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  int currentDay = DateTime.now().weekday;
  TabController tabController;

  getWeekName() {
    weekList.add(weekDays[currentDay]);
    for (int k = 1; k <= 6; k++) {
      weekList.add(weekDays[(currentDay + k) % 7]);
    }
    return weekList;
  }

  @override
  void initState() {
    generateCurrentWeekDays();
    geo=Geoflutterfire();
    tabController = TabController(initialIndex: 0, length: 7, vsync: this);
    super.initState();
  }

  getIndex(String e) {
    var index = weekDays.indexOf(e);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 280,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TabBar(
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              indicatorColor: Color(0xffFE506D),
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              labelColor: Colors.pink,
              unselectedLabelColor: Colors.black26,
              labelStyle: TextStyle(
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(
                  fontSize: 15,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w300),
              controller: tabController,
              tabs: weekDays
                  .map((e) => Container(
                        child: Column(
                          children: <Widget>[
                            currentIndex == getIndex(e)
                                ? Text(weekDates[getIndex(e)][0].toString() +
                                    "" +
                                    weekDates[getIndex(e)][1].toString())
                                : Text(weekDates[getIndex(e)][0].toString()),
                            currentIndex == getIndex(e)
                                ? Text(
                                    getWeekName()[getIndex(e)],
                                    style: TextStyle(fontSize: 15),
                                  )
                                : Text(
                                    getWeekName()[getIndex(e)].substring(0, 1),
                                    style: TextStyle(fontSize: 15),
                                  ),
                          ],
                        ),
                      ))
                  .toList()),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 5.0,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 60,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Celebrating today",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w100,
                              fontFamily: "Gilroy"),
                        ),
                        Text(
                          "Eid-ul-Fitar",
                          style: TextStyle(
                              color: Color(0xffFE506D),
                              fontFamily: "Gilroy",
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(15, 20, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Expected Weather",
                          style: TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 14,
                              fontWeight: FontWeight.w200),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.desc ?? "CLOUDY",
                          style: TextStyle(
                              color: Color(0xffFE506D),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gilroy"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.temp ?? "34 ",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontFamily: "Gilroy",
                                  fontWeight: FontWeight.bold),
                            ),
                            Text("°C",
                                style: TextStyle(
                                    fontFamily: "Gilroy",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.black))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )),
                Text(
                  "Recommended",
                  style: TextStyle(
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: widget.geopoint != null
                      ? StreamBuilder(
                          stream: geo
                              .collection(
                                  collectionRef:
                                      _database.collection('homemakers'))
                              .within(
                                  center: geo.point(
                                      latitude: widget.geopoint.latitude,
                                      longitude: widget.geopoint.longitude),
                                  radius: 10,
                                  field: 'position'),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                    child: Text(
                                        "OOPS, Looks like no one is serving!"));
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
                                height: 500,
                                child: ListView.builder(
                                  itemCount: menu.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    print(menu[index]);
                                    return Dismissible(
                                      key: Key(menu[index]["item"]["name"]),
                                      onDismissed: (direction) {
                                        print(snapshot.data[index].documentID);
                                        _database
                                            .collection('users')
                                            .document(widget.user_uid)
                                            .get()
                                            .then((DocumentSnapshot
                                                    usersnapshot) =>
                                                {
                                                  if (usersnapshot.exists)
                                                    {
                                                      if (usersnapshot.data[
                                                              'current_cart'] ==
                                                          null)
                                                        {
                                                          _database
                                                              .collection(
                                                                  'users')
                                                              .document(widget.uid)
                                                              .updateData({
                                                            'current_cart': [
                                                              {
                                                                'homemaker': snapshot
                                                                    .data[index]
                                                                    .documentID,
                                                                'item': menu[
                                                                        index]
                                                                    ["item"],
                                                                'quantity': 1
                                                              }
                                                            ]
                                                          })
                                                        }
                                                      else
                                                        {
                                                          _database
                                                              .collection(
                                                                  'users')
                                                              .document(widget.uid)
                                                              .updateData({
                                                            'current_cart':
                                                                FieldValue
                                                                    .arrayUnion([
                                                              {
                                                                'homemaker': snapshot
                                                                    .data[index]
                                                                    .documentID,
                                                                'item': menu[
                                                                        index]
                                                                    ["item"],
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25)),
                                              ],
                                            ),
                                          )),
                                      child: Container(
                                        margin: EdgeInsets.all(10.0),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 85,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(width: 10),
                                            Container(
                                              width: 100,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          menu[index]["item"]
                                                              ["image"]),
                                                      fit: BoxFit.fitWidth),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                            color: menu[index][
                                                                            "item"]
                                                                        [
                                                                        "veg"] ==
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
                                                                BorderRadius
                                                                    .circular(
                                                                        50.0),
                                                            color: menu[index][
                                                                            "item"]
                                                                        [
                                                                        "veg"] ==
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
                                                        color:
                                                            Color(0xffFE506D),
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
                            return SizedBox();
                          },
                        )
                      : Center(
                          child: Text(
                              "Oops, Looks like no one is delivering near you!"),
                        ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  events(int currentIndexx) {
    return Container(
      child: Text(currentIndex.toString()),
    );
  }

  generateCurrentWeekDays() {
    for (int i = 0; i < 7; i++) {
      weekDates.add((DateFormat('d - MMMM - yyyy')
              .format(dateTime.add(new Duration(days: i))))
          .split("-"));
    }
  }
}
// SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           TabBar(
//               onTap: (index) {
//                 setState(() {
//                   currentIndex = index;
//                 });
//               },
//               indicatorColor: Color(0xffFE506D),
//               indicatorSize: TabBarIndicatorSize.label,
//               isScrollable: true,
//               labelColor: Colors.pink,
//               unselectedLabelColor: Colors.black26,
//               labelStyle: TextStyle(
//                   fontSize: 18,
//                   fontFamily: "Gilroy",
//                   fontWeight: FontWeight.bold),
//               unselectedLabelStyle: TextStyle(
//                   fontSize: 15,
//                   fontFamily: "Gilroy",
//                   fontWeight: FontWeight.w300),
//               controller: tabController,
//               tabs: weekDays
//                   .map((e) => Container(
//                         child: Column(
//                           children: <Widget>[
//                             currentIndex == getIndex(e)
//                                 ? Text(weekDates[getIndex(e)][0].toString() +
//                                     " " +
//                                     weekDates[getIndex(e)][1].toString())
//                                 : Text(weekDates[getIndex(e)][0].toString()),
//                             currentIndex == getIndex(e)
//                                 ? Text(
//                                     getWeekName()[getIndex(e)],
//                                     style: TextStyle(fontSize: 15),
//                                   )
//                                 : Text(
//                                     getWeekName()[getIndex(e)].substring(0, 1),
//                                     style: TextStyle(fontSize: 15),
//                                   ),
//                           ],
//                         ),
//                       ))
//                   .toList()),
//           SizedBox(
//             height: 15,
//           ),
//           Card(
//             elevation: 5.0,
//             child: Container(
//               width: MediaQuery.of(context).size.width - 60,
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     "Celebrating today",
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w100,
//                         fontFamily: "Gilroy"),
//                   ),
//                   Text(
//                     "Eid-ul-Fitar",
//                     style: TextStyle(
//                         color: Color(0xffFE506D),
//                         fontFamily: "Gilroy",
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Container(
//               padding: EdgeInsets.fromLTRB(15, 20, 0, 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     "Expected Weather",
//                     style: TextStyle(
//                         fontFamily: "Gilroy",
//                         fontSize: 14,
//                         fontWeight: FontWeight.w200),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     widget.desc ?? "CLOUDY",
//                     style: TextStyle(
//                         color: Color(0xffFE506D),
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Gilroy"),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         widget.temp ?? "34 ",
//                         style: TextStyle(
//                             fontSize: 30,
//                             color: Colors.black,
//                             fontFamily: "Gilroy",
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text("°C",
//                           style: TextStyle(
//                               fontFamily: "Gilroy",
//                               fontSize: 15,
//                               fontWeight: FontWeight.w200,
//                               color: Colors.black))
//                     ],
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                 ],
//               )),
//           Text(
//             "Recommended",
//             style: TextStyle(
//                 fontFamily: "Gilroy",
//                 fontWeight: FontWeight.bold,
//                 fontSize: 24),
//           ),
//           Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//           )
//         ],
//       ),
//     );
