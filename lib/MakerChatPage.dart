import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/AuthService.dart';
import 'package:econoomaccess/BottomNavigationWidget.dart';
import 'package:econoomaccess/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


DateFormat dateFormat = DateFormat.Hm();

class MakerChatPage extends StatelessWidget {
  var uid,name;

  MakerChatPage({Key key, @required this.uid,@required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Chats",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black54,
            fontFamily: "Gilroy",
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(0xfff9f9f9),
        elevation: 0.0,
      ),
      drawer: DrawerWidget(uid:uid),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("homemakers")
              .document(uid)
              .collection("messages")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            else {
              List<DocumentSnapshot> docs = snapshot.data.documents;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Map lastMessage = docs[index].data["message"].last;
                  List<String> names = docs[index].documentID.split("-");
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage("https://i.imgur.com/df95t5x.png"),
                          backgroundColor: Colors.black,
                          radius: 30,
                        ),
                        title: Text(
                          name==lastMessage["reciever"]?lastMessage["sender"]:lastMessage["reciever"],
                          style: TextStyle(
                            fontFamily: "Gilroy",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage["content"],
                          style: TextStyle(
                            fontFamily: "Gilroy",
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                            dateFormat.format(lastMessage["time"].toDate())),
                        onTap: () {
                          Navigator.pushNamed(context, "/MakerChatPage",
                              arguments: [names[0], names[1]]);
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
