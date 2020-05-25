import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/ChatPage.dart';
import 'package:flutter/material.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class DrawerWidget extends StatelessWidget {
  final String uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DrawerWidget({Key key, @required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(uid);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
      child: Drawer(
          elevation: 10,
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(uid)
                  .snapshots(),
              builder: (context, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                // final documents = streamSnapshot.data.documents;

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              streamSnapshot.data['image'],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 15),
                          child: Text(
                            streamSnapshot.data['name'],
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed("/ExplorePage");
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Favourites',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                              "/FavoriteScreenPage",
                              arguments: uid);
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Chats',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ChatPage(
                                        uid: uid,name:streamSnapshot.data['name']
                                      )),
                              (route) => false);
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Offer Section',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Your Offers',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Your Orders',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).pushReplacementNamed(
                              "/ExistingOrders",
                              arguments: uid);
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          _auth.signOut().whenComplete(() {
                            Navigator.of(context)
                                .pushReplacementNamed("/AuthChoosePage");
                          });
                        },
                      ),
                      Center(
                          child: IconButton(
                              icon: Icon(
                                Typicons.delete_outline,
                                size: 60,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }))
                    ],
                  ),
                );
              })),
    );
  }
}
