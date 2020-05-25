import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthChoosePage.dart';
import 'package:provider/provider.dart';
import 'exchange.dart';
import 'ExistingOrder.dart';

class RecipeScreen extends StatelessWidget {
  String dishName;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  Future<bool> callback(ScreenArguments args, int quantity) async {
    FirebaseUser user = await _auth.currentUser();
    Map snap;
    await firestore
        .collection('homemakers')
        .document(args.homemaker)
        .get()
        .then((DocumentSnapshot snapshot) {
      List.from(Map.from(snapshot.data)['menu']).every((element) {
        if (Map.from(element)['name'] == args.item) snap = Map.from(element);
        return true;
      });
    });

    firestore
        .collection('users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              if (snapshot.exists)
                {
                  if (snapshot.data['current_cart'] == null)
                    {
                      firestore
                          .collection('users')
                          .document(user.uid)
                          .updateData({
                        'current_cart': [
                          {
                            'homemaker': args.homemaker,
                            'item': snap,
                            'quantity': quantity
                          }
                        ]
                      })
                    }
                  else
                    {
                      firestore
                          .collection('users')
                          .document(user.uid)
                          .updateData({
                        'current_cart': FieldValue.arrayUnion([
                          {
                            'homemaker': args.homemaker,
                            'item': snap,
                            'quantity': quantity
                          }
                        ])
                      })
                    }
                }
            });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    ScreenArguments args = ModalRoute.of(context).settings.arguments;
    dishName = args.item;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, "/ExplorePage");
            },
            child: Icon(Icons.arrow_back_ios)),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          dishName,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Gilroy",
              fontSize: 25),
        ),
        backgroundColor: Color(0xFFFF9F9F9),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ChangeNotifierProvider(
        create: (context) => QuantityModel(),
        child: firestoreRecipe(args.item, args.homemaker, callback, args.index),
      ),
    );
  }
}

class RecipeQuantityWidget extends StatefulWidget {
  @override
  _RecipeQuantityWidgetState createState() => _RecipeQuantityWidgetState();
}

class _RecipeQuantityWidgetState extends State<RecipeQuantityWidget> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            Provider.of<QuantityModel>(context).subtract();
          },
        ),
        Text("${Provider.of<QuantityModel>(context).quantity}"),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            FirebaseAuth.instance.currentUser().then((value) {
              if (value != null) {
                Provider.of<QuantityModel>(context).add();
              } else {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => AuthChoosePage()));
                Fluttertoast.showToast(msg: "Please Login to continue");
              }
            });
          },
        )
      ],
    );
  }
}


class DishDetail extends StatefulWidget {
  final List<dynamic> ingredients;
  final String instructions;
  final List<dynamic> analyzedInstructions;
  final List<dynamic> nutrients;
  final String homemaker;
  final int index;
  const DishDetail(
      {this.ingredients,
      this.instructions,
      this.analyzedInstructions,
      this.nutrients,
      this.homemaker,
      this.index});
  @override
  _DishDetailState createState() => _DishDetailState();
}

class _DishDetailState extends State<DishDetail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double rating = 0;
  @override
  Widget build(BuildContext context) {
    TextEditingController review = new TextEditingController();
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      maxChildSize: 0.9,
      minChildSize: 0.25,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                )
              ]),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              Center(
                child: Text(
                  "Dish Details",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 15),
              Table(
                border: TableBorder.all(),
                children: getNutrients(),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Recipe",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Card(
                elevation: 15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...getIngredients(),
                      const SizedBox(height: 10),
                      Text(
                        "Steps",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      getInstructions(context),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: Text(
                  "Rate & Review",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Gilroy"),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Center(
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width - 100,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext contex, int index) {
                      return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: rating > index ? Colors.yellow : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index.toDouble() + 1.0;
                            });
                          });
                    },
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Color(0xFFF6F6F6)),
                child: TextField(
                  controller: review,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Feedback",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () async {
                  if (review.text != "" && rating != 0) {

                    await _auth.currentUser().then((val) {
                      Firestore.instance
                          .collection("users")
                          .document(val.uid)
                          .get()
                          .then((value) {
                            Firestore.instance
                        .collection("homemakers")
                        .document(widget.homemaker)
                        .collection("reviews")
                        .add({"text": review.text,
                          "username":value.data['name']
                        });
                          });
                      
                    });
                    
                    Firestore.instance
                        .collection("homemakers")
                        .document(widget.homemaker)
                        .get()
                        .then((value) {
                      rating = (rating +
                              value.data["menu"][widget.index]["rating"]) /
                          2;
                      value.data["menu"][widget.index]["rating"] = rating;
                      Firestore.instance
                          .collection("homemakers")
                          .document(widget.homemaker)
                          .updateData({
                        "menu": value.data["menu"]
                      }).whenComplete(() => rating = 0);
                    });

                    await _auth.currentUser().then((val) {
                      Firestore.instance
                          .collection("homemakers")
                          .document(widget.homemaker)
                          .get()
                          .then((value) {
                        Firestore.instance
                            .collection("users")
                            .document(val.uid)
                            .collection("reviews")
                            .add({
                          "text": review.text,
                          "rating": rating,
                          "homemaker": value.data['name'],
                          "dishname": value.data["menu"][widget.index]["name"],
                        });
                      });
                    });
                  }
                },
                child: Container(
                  width: 200,
                  height: 50.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xffFF6530), Color(0xffFE4E74)])),
                  child: Center(
                    child: Text("Submit"),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<TableRow> getNutrients() {
    List<TableRow> list = [];
    for (int i = 0; i < 5; i++) {
      list.add(TableRow(children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(widget.nutrients[i]["title"]),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
                "${widget.nutrients[i]["amount"]} ${widget.nutrients[i]["unit"]}"),
          ),
        ),
      ]));
    }
    return list;
  }

  List<Widget> getIngredients() {
    List<Widget> list = [];
    widget.ingredients.forEach((ingredient) {
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("${ingredient["name"]}"),
          Text("${ingredient["amount"]} ${ingredient["unit"]}"),
        ],
      ));
    });
    return list;
  }

  Widget getInstructions(BuildContext context) {
    if (widget.analyzedInstructions == null ||
        widget.analyzedInstructions.isEmpty)
      return Text(widget.instructions);
    else {
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.analyzedInstructions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                      color: Colors.white, fontFamily: "Gilroy", fontSize: 13),
                ),
                backgroundColor: Color(0xffFE4E74),
                radius: 15,
              ),
              title: Text(
                "${widget.analyzedInstructions[index]["step"]}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy",
                    fontSize: 15),
              ),
            );
          });
    }
  }
}

Widget firestoreRecipe(
    String recipeText, String homemaker, Function callback, int itemIndex) {
  bool recipeAvailable = false;
  int index;
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection("recipe").snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      dynamic recipe;
      Firestore.instance
          .collection("homemakers")
          .document(homemaker)
          .get()
          .then((value) {
        for (int i = 0; i < value.data["menu"].length; i++) {
          if (value.data["menu"][i]["name"] == recipeText &&
              value.data["menu"][i]["recipe"] != null) {
            recipeAvailable = true;
            recipe = value.data["menu"][i]["recipe"];
          }
        }
      });
      if (snapshot.hasData) {
        if (recipeAvailable == false) {
          snapshot.data.documents.every((element) {
            if (element.data["name"] == recipeText) {
              dynamic temp = element.data["recipe"];
              recipe = temp;
            }
            return true;
          });
        }
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Image.network(recipe["image"])),
                  const SizedBox(height: 20),
                  Text("Madhu's Kitchen | " + recipeText,
                      style: TextStyle(
                        fontSize: 22,
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Quantity"),
                      RecipeQuantityWidget(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Buy now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gilroy",
                              fontSize: 15),
                        ),
                        color: Colors.deepOrange,
                        textColor: Colors.white,
                        onPressed: () {
                          callback(
                              ScreenArguments(homemaker, recipeText, itemIndex),
                              1);
                        },
                      ),
                      MaterialButton(
                        textColor: Colors.redAccent,
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gilroy",
                              fontSize: 15),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.redAccent,
                          ),
                        ),
                        onPressed: () async {
                          FirebaseAuth.instance
                                    .currentUser()
                                    .then((value) async{
                                  if (value != null) {
                                    bool val = await callback(
                                        ScreenArguments(homemaker, recipeText,itemIndex),
                                        Provider.of<QuantityModel>(context)
                                            .quantity);
                                    if (val == true) {
                                      Navigator.pushReplacementNamed(
                                          context, '/ExplorePage');
                                    } else {
                                      print("Waiting");
                                    }
                                  } else {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                AuthChoosePage()));
                                    Fluttertoast.showToast(
                                        msg: "Please Login to continue");
                                  }
                                });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DishDetail(
              ingredients: (recipe["extendedIngredients"]),
              instructions: recipe["instructions"],
              analyzedInstructions: (recipe["analyzedInstructions"][0]
                  ["steps"]),
              nutrients: recipe["nutrition"]["nutrients"],
              homemaker: homemaker,
              index: itemIndex,
            ),
          ]),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}

class QuantityModel extends ChangeNotifier {
  int _quantity = 1;
  int get quantity => _quantity;

  void add() {
    _quantity += 1;
    notifyListeners();
  }

  void subtract() {
    if (_quantity > 1) {
      _quantity -= 1;
    }
    notifyListeners();
  }
}
