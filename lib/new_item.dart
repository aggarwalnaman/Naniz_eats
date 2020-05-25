import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

class NewItem extends StatefulWidget {
  @override
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  File imageFile = null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _uid, timeslot, _value;

  void getData() async {
    var temp;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('homemakers').document(user.uid).get();
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

  createDialogue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetAnimationCurve: Curves.easeInOut,
            insetAnimationDuration: Duration(seconds: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.black54,
                    ),
                    onPressed: () async {
                      var image = await ImagePicker.pickImage(
                              source: ImageSource.camera)
                          .then((image) {
                        setState(() {
                          imageFile = image;
                        });
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.photo_library,
                      size: 30,
                      color: Colors.black54,
                    ),
                    onPressed: () async {
                      await ImagePicker.pickImage(source: ImageSource.gallery)
                          .then((image) {
                        setState(() {
                          imageFile = image;
                        });
                      });

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  int _selectedIndex = 0;

  //TextEditingController _textEditingController = TextEditingController();
  String dropdownValue;
  Color _dropDownColor = Colors.black45;
  Color _dropDownVegColor = Colors.green;
  Color _dropDownNonVegColor = Colors.brown;
  bool _dropDownUpload;

  String name;
  var price;
  List nameCheck;

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, "/MerchantOrderPage");
    } else if (_selectedIndex == 2) {
    } else if (_selectedIndex == 3) {
      // Navigator.pushReplacementNamed(context, "/ProfilePage");
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            height: 54,
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xffFE506D),
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.assignment,
                    color: Color(0xffFE506D),
                  ),
                  title: Text("Home"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_books, color: Colors.black),
                  title: Text("Shop"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border, color: Colors.black),
                  title: Text("Shop"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.perm_identity, color: Colors.black),
                  title: Text("Profile"),
                )
              ],
            ),
          )),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 40,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/EditPage");
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('New Item',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontFamily: "Gilroy",
                      fontSize: 28.0,
                    )),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            RaisedButton(
              color: Colors.grey[400],
              elevation: 0,
              padding: EdgeInsets.only(
                  top: height * 0.06,
                  bottom: height * 0.06,
                  left: (width / 2) - 70,
                  right: (width / 2) - 70),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () {
                createDialogue(context);
              },
              child: this.imageFile == null
                  ? Column(children: <Widget>[
                      Icon(
                        Icons.add,
                        size: 100,
                        color: Colors.white,
                      ),
                      Text(
                        'Add Image',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w600),
                      )
                      //SizedBox(height:height*0.06),
                    ])
                  : Image(
                      height: 100,
                      width: 100,
                      image: FileImage(this.imageFile)),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, right: 8.0, left: 17),
              child: Card(
                elevation: 3,
                color: Colors.white,
                child: TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  // controller: _textEditingController,
                  cursorColor: Colors.black54,

                  //enableInteractiveSelection: true,
                  //enableSuggestions: true,
                  textAlign: TextAlign.center,
                  showCursor: true,
                  cursorRadius: Radius.circular(5),
                  cursorWidth: 2,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    labelStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                    ),
                    labelText: "Add Name",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.black12),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.black12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: Colors.grey[500],
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            //SizedBox(height: height*0.01,),
            ListTile(
              trailing: Text(
                'INR',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy",
                    fontSize: 30),
              ),
              title: Card(
                elevation: 3,
                color: Colors.white,
                child: TextField(
                  onChanged: (value) {
                    price = int.parse(value);
                  },
                  // controller: _textEditingController,
                  cursorColor: Colors.black54,
                  //enableInteractiveSelection: true,
                  //enableSuggestions: true,
                  textAlign: TextAlign.center,
                  showCursor: true,
                  cursorRadius: Radius.circular(5),
                  cursorWidth: 2,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    labelStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                    ),
                    labelText: "Enter Price",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.black12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: Colors.grey[500],
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      hint:Text("Veg/Non-Veg"),
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.black45,
                        fontFamily: 'Gilroy',
                      ),
                      underline: Container(
                        height: 2,
                        color: _dropDownColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          nameCheck = name.split(' ');
                          if (nameCheck.contains('Chicken'))
                            dropdownValue = 'Non-Veg';
                          (nameCheck.contains('Egg'))
                              ? dropdownValue = 'Non-Veg'
                              : dropdownValue = 'Veg';
                          (nameCheck.contains('Prawn'))
                              ? dropdownValue = 'Non-Veg'
                              : dropdownValue = 'Veg';
                          (nameCheck.contains('Fish'))
                              ? dropdownValue = 'Non-Veg'
                              : dropdownValue = 'Veg';
                          (nameCheck.contains('Veg'))
                              ? dropdownValue = 'Veg'
                              : dropdownValue = 'Non-Veg';

                          dropdownValue = newValue;
                          (dropdownValue == 'Veg')
                              ? _dropDownColor = _dropDownVegColor
                              : _dropDownColor = _dropDownNonVegColor;
                          (dropdownValue == 'Veg')
                              ? _dropDownUpload = true
                              : _dropDownUpload = false;
                        });
                      },
                      items: <String>['Non-Veg', 'Veg']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    // width: MediaQuery.of(context).size.width,
                    // height: 50.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Center(
                      child: DropdownButton<String>(
                        value: this.timeslot,
                        hint: Text("Choose a time slot"),
                        style: TextStyle(
                          color: Color.fromRGBO(38, 50, 56, 0.30),
                          fontSize: 15.0,
                          fontFamily: "Gilroy",
                        ),
                        underline: Container(
                        height: 2,
                        color: Colors.black45,
                      ),
                        onChanged: (value) {
                          setState(() {
                            this.timeslot = value;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: "10AM - 12PM",
                            child: Text(
                              "10AM - 12PM",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "01PM - 04PM",
                            child: Text(
                              "01PM - 04PM",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "06PM - 09PM",
                            child: Text(
                              "06PM - 09PM",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width:0
                )
              ],
            ),

            SizedBox(height: height * 0.05),
            GestureDetector(
              child: Card(
                  shape: CircleBorder(
                      side: BorderSide(width: 2, color: Color(0xffFE4E74))),
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    size: 60,
                    color: Color(0xffFE4E74),
                  )),
              onTap: () {
                List<Map> list = [
                  {
                    "name": name,
                    'price': price,
                    'rating': 0,
                    'veg': _dropDownUpload,
                    'image':
                        'https://s3-alpha-sig.figma.com/img/5837/593d/c638f78470faaa0a91c5a4d70b04b070?Expires=1590364800&Signature=guzKQIVT18y7jptJRssz6pYB0kcW01q4Vg1B27ZRMxMzJ2hAed9bKf81IJDPW4Ig7F8iw5Kwtt0KBRDJFK4VDFzLKzVGfE9pi1XGhjkZk30PRVM4hTCxrvrqGdNEVCxbhOp5LuLg5ujgF5NNMn-6fOaBadacsvEJjJj1asu-jgkgb2TrDrk9hVunAK74RbZw6FMCd7wgrJk1ufHJvWjj2t29FnvvapfRH2n8alj4fBCnDLgG0mehcGs-ZDqg6j-v8bvyUPnI4XtqqrwUuPBty8F6o9dMcsxgyx-jJ4pPJVqarlyAoyv22Eb6qpgFCb-~ar7013F1yyGY4fxCTEbnDA__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA',
                    'timeslot': timeslot
                  }
                ];
                //TODO
                addMeal(list);
              },
            ),
          ],
        ),
      ),
    );
  }

  void addMeal(List<Map> list) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(Path.basename(imageFile.path));
    await storageReference.putFile(imageFile).onComplete;
    String url = await storageReference.getDownloadURL();
    list[0]["image"] = url;
    firestore.collection('homemakers').document(this._uid).updateData({
      "menu": FieldValue.arrayUnion(list),
    }).whenComplete(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Added ${name} Successfully",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          letterSpacing: -0.8,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: 320.0,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "CONTINUE >",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SF Pro Text',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                          color: Color(0xffFE4E74),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }
}
