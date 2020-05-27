import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class PromotionItemCard extends StatefulWidget {
  var data;
  final String docId;
  final String uid;
  PromotionItemCard({this.data, this.docId, this.uid});

  @override
  _PromotionItemCardState createState() => _PromotionItemCardState();
}

class _PromotionItemCardState extends State<PromotionItemCard> {

  String link;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.data["name"],style: TextStyle(fontFamily: "Gilroy",fontWeight: FontWeight.bold),),
                  Text("Required Referrals : ${widget.data["promoters"]}",style: TextStyle(fontFamily: "Gilroy"),)
                ],
              ),
              leading: ClipRRect(
                child: Image.network(
                  widget.data["image"],
                  fit: BoxFit.cover,
                  height: 60,
                  width: 100,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text(widget.docId),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Price"),
                      Text("Min. Amount"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("₹ ${widget.data["price"]}"),
                      Text("${widget.data["promotedAmount"]}"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Cut"),
                      Text("Time Limit"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("₹ ${widget.data["promotedCut"]}"),
                      Text("${widget.data["promotedDays"]} days"),
                    ],
                  ),
                ],
              ),
            ),
            (link == null)?
            MaterialButton(
              child: Text("Accept referral",style: TextStyle(fontFamily: "Gilroy"),),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textColor: Colors.white,
              color: Colors.redAccent,
              onPressed: (){
                getLink();
              },
            ):
            SelectableText(link),
          ],
        ),
      ),
    );
  }

  void getLink() async {
    String linkData = "${widget.docId}/${widget.data["name"]}/${widget.uid}";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://naniz.page.link",
      link: Uri.parse("https://naaniz.com/$linkData"),
      androidParameters: AndroidParameters(
        packageName: "nl.blueavenue.econoomaccess",
        minimumVersion: 0,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Try this dish",
        description: "This dish is great",
        imageUrl: Uri.parse(widget.data["image"]),
      ),
    );
    final Uri link = await parameters.buildUrl();
    final ShortDynamicLink shortLink = await DynamicLinkParameters.shortenUrl(
      link,
    );
    setState(() {
      this.link = shortLink.shortUrl.toString();
    });
    DocumentReference docRef = Firestore.instance.collection("users").document(widget.uid);
    Firestore.instance.runTransaction((transaction) async {

      DocumentSnapshot docSnap = await docRef.get();

      var obj = docSnap.data["promotionItems"]??{};
      obj[widget.docId] ??= {};
      obj[widget.docId][widget.data["name"]] = {
        "name": widget.data["name"],
        "image": widget.data["image"],
        "cut" : widget.data["promotedCut"],
        "days": widget.data["promotedDays"],
        "earned" : 0,
        "link": this.link,
        "orders": 0,
        "requiredOrders": widget.data["promoters"],
      };
      transaction.update(docRef, {
        "promotionItems": obj,
      });
    });

  }
}
