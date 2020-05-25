import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'localization/language_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'exchange.dart';
import 'ProfilePageOptions.dart';

const PdfColor green = PdfColor.fromInt(0xffFF6530);
const PdfColor lightGreen = PdfColor.fromInt(0xffFE4E74);

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var temp;
  var documentName;
  fcm.FirebaseMessaging firebaseMessaging = new fcm.FirebaseMessaging();


  // getData() {
  //   firestore
  //       .collection('homemakers')
  //       .document(documentName)
  //       .get()
  //       .then((doc) => {
  //             temp = doc.data['menu'],
  //             _generatePDF(temp),
  //           });
  // }

  // _generatePDF(temp) async {
  //   final doc = pw.Document();
  //   const imageProvider = const AssetImage('images/cropped-naaniz-logo.png');
  //   final PdfImage image = await pdfImageFromImageProvider(
  //       pdf: doc.document, image: imageProvider);
  //   final font = await rootBundle.load("fonts/KaushanScript-Regular.ttf");
  //   final ttf = pw.Font.ttf(font);

  //   doc.addPage(pw.MultiPage(
  //       pageTheme: pw.PageTheme(
  //         buildBackground: (pw.Context context) {
  //           return pw.FullPage(
  //             ignoreMargins: true,
  //             child: pw.CustomPaint(
  //               size: PdfPoint(500, 600),
  //               painter: (PdfGraphics canvas, PdfPoint size) {
  //                 context.canvas
  //                   ..setColor(lightGreen)
  //                   ..moveTo(0, size.y)
  //                   ..lineTo(0, size.y - 230)
  //                   ..lineTo(60, size.y)
  //                   ..fillPath()
  //                   ..setColor(green)
  //                   ..moveTo(0, size.y)
  //                   ..lineTo(0, size.y - 100)
  //                   ..lineTo(100, size.y)
  //                   ..fillPath()
  //                   ..setColor(lightGreen)
  //                   ..moveTo(30, size.y)
  //                   ..lineTo(110, size.y - 50)
  //                   ..lineTo(150, size.y)
  //                   ..fillPath()
  //                   ..moveTo(size.x, 0)
  //                   ..lineTo(size.x, 230)
  //                   ..lineTo(size.x - 60, 0)
  //                   ..fillPath()
  //                   ..setColor(green)
  //                   ..moveTo(size.x, 0)
  //                   ..lineTo(size.x, 100)
  //                   ..lineTo(size.x - 100, 0)
  //                   ..fillPath()
  //                   ..setColor(lightGreen)
  //                   ..moveTo(size.x - 30, 0)
  //                   ..lineTo(size.x - 110, 50)
  //                   ..lineTo(size.x - 150, 0)
  //                   ..fillPath();
  //               },
  //             ),
  //           );
  //         },
  //       ),
  //       build: (context) => [
  //             pw.Row(children: [
  //               pw.Center(
  //                 child: pw.Image(image, height: 120, width: 120),
  //               ),
  //               pw.SizedBox(width: 20),
  //               pw.Center(
  //                   child: pw.Text("MENU",
  //                       style: pw.TextStyle(
  //                           font: ttf,
  //                           fontSize: 100,
  //                           fontWeight: pw.FontWeight.bold,
  //                           color: PdfColor.fromInt(0xffFE506D)))),
  //             ]),
  //             pw.SizedBox(height: 10),
  //             pw.Table.fromTextArray(
  //               border: null,
  //               cellAlignment: pw.Alignment.centerLeft,
  //               headerDecoration: pw.BoxDecoration(
  //                 borderRadius: 2,
  //                 color: PdfColor.fromInt(0xffFE506D),
  //               ),
  //               headerHeight: 25,
  //               cellHeight: 40,
  //               cellAlignments: {
  //                 0: pw.Alignment.center,
  //                 1: pw.Alignment.center,
  //               },
  //               headerStyle: pw.TextStyle(
  //                 color: PdfColor.fromInt(0xffFFFFFF),
  //                 fontSize: 10,
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //               rowDecoration: pw.BoxDecoration(
  //                 border: pw.BoxBorder(
  //                   bottom: true,
  //                   width: .5,
  //                 ),
  //               ),
  //               cellStyle: const pw.TextStyle(
  //                 fontSize: 10,
  //               ),
  //               context: context,
  //               data: <List<String>>[
  //                 <String>['Food Name', 'Cost'],
  //                 ...temp.map((item) =>
  //                     [item['name'].toString(), item['price'].toString()])
  //               ],
  //             ),
  //           ]));

  //   await Printing.sharePdf(bytes: doc.save(), filename: 'my-menu.pdf');
  // }

  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;
    documentName = s;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 25.0,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/ExplorePage');
            }),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
          child: StreamBuilder<DocumentSnapshot>(
              stream:
                  firestore.collection("homemakers").document(s).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  print(snapshot.data.data);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(80, 0.0, 80, 0),
                        child: Column(
                          children: <Widget>[
                            Container(
                                width: 91,
                                height: 91,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: new NetworkImage(
                                            "${snapshot.data.data['image']}")))),
                            SizedBox(height: 5),
                            Text(
                              "${snapshot.data.data['name']}\'s Kitchen",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  '${snapshot.data.data['mealtype'][0]} |',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '${snapshot.data.data['rating']}',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xffFE506D),
                                      size: 13.0,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              '${snapshot.data.data['city']}, ${snapshot.data.data['state']}',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(color: Colors.pink),
                              ),
                              onPressed: null,
                              child: Text(
                                'Operating ${snapshot.data.data['ohours']}',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Gilroy",
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            snapshot.data.data['delivery']
                                ? FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.pink),
                                    ),
                                    onPressed: null,
                                    child: Text(
                                      'Delivery Available',
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gilroy",
                                          fontSize: 10),
                                    ),
                                  )
                                : FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.pink),
                                    ),
                                    onPressed: null,
                                    child: Text(
                                      'Self-Pickup only',
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gilroy",
                                          fontSize: 10),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     IconButton(
                      //         icon: Icon(
                      //           Icons.bookmark_border,
                      //           size: 25.0,
                      //           color: Colors.black,
                      //         ),
                      //         onPressed: () {
                      //           fcm.FirebaseMessaging()
                      //               .subscribeToTopic(snapshot.data.documentID)
                      //               .then((value) {
                      //             print("value");
                      //           }).catchError((value) {
                      //             print(value);
                      //           });
                      //         }),
                      //     SizedBox(
                      //       width: 10.0,
                      //     ),
                      //     IconButton(
                      //         icon: Icon(
                      //           Icons.chat_bubble_outline,
                      //           size: 25.0,
                      //           color: Colors.black,
                      //         ),
                      //         onPressed: () {
                      //           var s;
                      //           _auth.onAuthStateChanged.listen((user) {
                      //             s = [
                      //               snapshot.data.documentID,
                      //               user.displayName
                      //             ];
                      //             Navigator.of(context).pushReplacementNamed(
                      //                 '/ChatPage',
                      //                 arguments: s);
                      //           });
                      //         }),
                      //     SizedBox(
                      //       width: 10.0,
                      //     ),
                      //     IconButton(
                      //         icon: Icon(
                      //           Icons.share,
                      //           size: 25.0,
                      //           color: Colors.black,
                      //         ),
                      //         onPressed: () {
                      //           getData();
                      //         }),
                      //   ],
                      // ),
                      ProfilePageOptions(data: snapshot.data.data,docId: snapshot.data.documentID,),
                      Text(
                        getTranslated(context, "menu"),
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "${snapshot.data.data['ohours']}",
                        style: TextStyle(
                          color: Color(0xffFE506D),
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 500,
                        child: ListView.builder(
                          // controller: _controller,
                          itemCount: snapshot.data.data['menu'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                    '/RecipePage',
                                    arguments: ScreenArguments(snapshot.data.documentID, snapshot.data.data['menu'][index]['name'],index));
                              },
                              child: Container(
                                margin: EdgeInsets.all(5.0),
                                width: MediaQuery.of(context).size.width,
                                height: 85,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(
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
                      ),
                    ],
                  );
                }
              }),
        )),
      ),
    );
  }
}
