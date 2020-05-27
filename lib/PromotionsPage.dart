import 'package:cloud_firestore/cloud_firestore.dart';
import 'ActivePromotionItemCard.dart';
import 'PromotionItemCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PromotionsPage extends StatefulWidget {
  @override
  _PromotionsPageState createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  String uid;
  var promotionItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() {
    FirebaseAuth.instance.currentUser().then((val) {
      Firestore.instance
          .collection("users")
          .document(val.uid)
          .get()
          .then((value) {
        setState(() {
          uid = val.uid;
          promotionItems = value.data["promotionItems"];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe5e5e5),
      appBar: AppBar(
        leading: GestureDetector(child: Icon(Icons.arrow_back_ios),onTap: (){
          Navigator.of(context)
                              .pushReplacementNamed("/ExplorePage");
        },),
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.black,fontFamily: "Gilroy",fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("promotion").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            QuerySnapshot data = snapshot.data;
            List<DocumentSnapshot> docs = data.documents;
            return ListView.builder(
                itemCount: docs?.length ?? 0,
                itemBuilder: (context, docsIndex) {
                  List<dynamic> promotions;
                  promotions = docs[docsIndex]["promotion"];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: promotions?.length ?? 0,
                          itemBuilder: (context, promotionIndex) {
                            if (promotions[promotionIndex]["promoted"] ==
                                    true ||
                                true) {
                              String docId = docs[docsIndex].documentID;
                              String mealName =
                                  promotions[promotionIndex]["name"];
                              if (promotionItems != null &&
                                  promotionItems[docId] != null &&
                                  promotionItems[docId][mealName] != null) {
                                return ActivePromotionItemCard(
                                  data: promotionItems[docId][mealName],
                                  docId: docId,
                                );
                              } else {
                                return PromotionItemCard(
                                  docId: docId,
                                  data: promotions[promotionIndex],
                                  uid: this.uid,
                                );
                              }
                            } else
                              return Container();
                          },
                        )
                      ],
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}
