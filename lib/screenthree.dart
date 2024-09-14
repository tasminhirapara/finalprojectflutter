import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Model.dart';

class screenthree extends StatefulWidget {
  var email;
  screenthree({required this.email});

  @override
  State<screenthree> createState() => _screenthreeState();
}

class _screenthreeState extends State<screenthree> {
  final TextEditingController businessname = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Image.asset(
              "images/oip.png",
              height: 300,
              width: 500,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: businessname,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(width: 2, color: Colors.black)),
                      labelText: 'Add Business',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      if (businessname.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter name of business'),
                          ),
                        );
                      } else {
                        _registerBusiness();
                        _clearText();
                        setState(() {
                          getdata();
                        });
                      }
                    },
                    child: Text("ADD",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      side: BorderSide(width: 2, color: Colors.black),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.all(20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Existing Businesses",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: FutureBuilder<List>(
              future: getdata(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return Model(list: snapshot.data!!);
                }
                if (snapshot.hasError) {
                  print('Network Not Found');
                }
                return Center(child: CircularProgressIndicator());
              },
            ))
          ],
        ),
      ),
    );
  }

  _clearText() {
    businessname.clear();
  }

  CollectionReference addUser =
      FirebaseFirestore.instance.collection('Businesstable');
  Future<void> _registerBusiness() {
    return addUser
        .add({
          'businessname': businessname.text.toString(),
          'Email': widget.email,
        })
        .then((value) => () {
              setState(() {
                getdata();
              });
            })
        .catchError((_) => print('Something Error In registering User'));
  }

  Future<List> getdata() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Businesstable')
        .where('Email', isEqualTo: widget.email)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
