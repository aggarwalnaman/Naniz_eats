import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'recipeVariables.dart' as variable;

class AddRecipe extends StatefulWidget {
  String name;
  String uid;
  AddRecipe({Key key, @required this.name, @required this.uid})
      : super(key: key);
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  int ingredients = 1;
  @override
  Widget build(BuildContext context) {
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFFF9F9F9),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                "Add Ingredients",
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 60.0,
                ),
                Text(
                  "Ingredient",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Gilroy"),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Text(
                  "Quantity",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Gilroy"),
                ),
                SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            Flexible(
              child: ListView.builder(
                itemCount: ingredients,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            gradient: LinearGradient(
                                colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        child: Center(
                            child: Text(
                          (index + 1).toString(),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        )),
                      ),
                      Container(
                        width: 200,
                        height: 50,
                        padding: EdgeInsets.only(left: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: variable.ingredients[index],
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Container(
                        width: 70,
                        padding: EdgeInsets.only(left: 5.0),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: variable.quantity[index],
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    ingredients++;
                  });
                },
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Icon(
                    Icons.add,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Recipe(
                                name: widget.name,
                                ingredients: ingredients,
                              )));
                },
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }
}

class Recipe extends StatefulWidget {
  String name;
  int ingredients;
  Recipe({Key key, @required this.name, @required this.ingredients})
      : super(key: key);
  @override
  _RecipeState createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  static List<dynamic> ingredient = [];

  Map<String, dynamic> temp = {
    "extendedIngredients": ingredient,
    "instructions": variable.recipe.text,
    "analyzedInstructions": [
      {"step": variable.recipe.text}
    ],
    "nutrition": {
      "nutrients": [
        {"title": "No Data", "amount": "No Data", "unit": "No Data"},
        {"title": "No Data", "amount": "No Data", "unit": "No Data"},
        {"title": "No Data", "amount": "No Data", "unit": "No Data"},
        {"title": "No Data", "amount": "No Data", "unit": "No Data"},
        {"title": "No Data", "amount": "No Data", "unit": "No Data"}
      ]
    },
  };

  @override
  Widget build(BuildContext context) {
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
              child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFFF9F9F9),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(20.0),
                child: Text(
                  "Add Steps",
                  style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy"),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height - 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey,
                ),
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  controller: variable.recipe,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    for (int i = 0; i < widget.ingredients; i++) {
                      ingredient.add({
                        "name": variable.ingredients[i].text,
                        "amount": variable.quantity[i].text,
                        "unit": ""
                      });
                    }
                    FirebaseUser user = await FirebaseAuth.instance.currentUser();
                    temp["extendedIngredients"] = ingredient;
                    temp["instructions"] = variable.recipe.text;
                    temp["analyzedInstructions"] = [
                      {"step": variable.recipe.text}
                    ];
                    Firestore.instance.collection("recipe").add(
                        {"name": widget.name, "recipe": temp, "user": user.uid}).whenComplete(
                          (){
                            Navigator.of(context)
                              .pushReplacementNamed("/MenuPage");
                          }
                        );
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                            colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
