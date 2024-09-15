import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojectflutter/clientbook.dart';
import 'package:finalprojectflutter/screenone.dart';
import 'package:finalprojectflutter/screenthree.dart';
import 'package:finalprojectflutter/stockbook.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'businessbook.dart';
import 'expensebook.dart';

class screenfour extends StatefulWidget {
  var businessname;
  screenfour({required this.businessname});

  @override
  State<screenfour> createState() => _screenfourState();
}

class _screenfourState extends State<screenfour> {
  late SharedPreferences logindata;
  late String username;
  late String email;
  late String photo;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  final List<Map<String, String>> items = [
    {"title": "Client Book", "image": "images/client.png"},
    {"title": "Business Book", "image": "images/business.png"},
    {"title": "Stock Book", "image": "images/stock.png"},
    {"title": "Expense Book", "image": "images/expense.png"}
  ];

  void _onItemTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => clientbook(
                    businessname: widget.businessname,
                    email: email,
                  )));
    }
    if (index == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => businessbook(
                  businessname: widget.businessname, email: email)));
    }
    if (index == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StockBook(businessname: widget.businessname, email: email)));
    }
    if (index == 3) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => expensebook(
                  businessname: widget.businessname, email: email)));
    }
  }

  @override
  void initState() {
    initial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.businessname),
          titleSpacing: 00.0,
          centerTitle: true,
          bottomOpacity: 1.0,
          toolbarHeight: 60.2,
          shadowColor: Colors.black,
          toolbarOpacity: 1.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20))),
          elevation: 10.00,
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 30.0,
            mainAxisSpacing: 30.0,
            childAspectRatio: 0.8,
          ),
          padding: EdgeInsets.all(20.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => _onItemTap(context, index),
              child: GridItem(
                title: items[index]['title']!,
                imageUrl: items[index]['image']!,
              ),
            );
          },
        ),
        drawer: Drawer(
            child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
                // image: DecorationImage(
                //   image: AssetImage("assets/drawer_bg.jpg"),
                //   fit: BoxFit.cover,
                // ),
              ),
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.black, child: Image.network(photo)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("About"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.business_center),
              title: Text("Change Business"),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => screenthree(
                              email: email,
                            )));
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("Share App"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Rate Us"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.policy),
              title: Text("Privacy Policy"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.remove_circle),
              title: Text("Remove Business"),
              onTap: () async {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Deletion'),
                      content: Text(
                          'Are you sure you want to delete this Business?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  try {
                    QuerySnapshot querySnapshot = await FirebaseFirestore
                        .instance
                        .collection('Businesstable')
                        .where('businessname', isEqualTo: widget.businessname)
                        .where('Email', isEqualTo: email)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      await querySnapshot.docs.first.reference.delete();
                      print('Business deleted successfully');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => screenthree(
                            email: email,
                          ),
                        ),
                      );
                    } else {
                      print('No businessname found with the email');
                    }
                  } catch (e) {
                    print('Failed to delete Business: $e');
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                logindata.setBool('tops', true);
                await _googleSignIn.signOut();
                Navigator.pushReplacement(context,
                    new MaterialPageRoute(builder: (context) => screenone()));
              },
            ),
          ],
        )));
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();

    setState(() {
      username = logindata.getString('username')!;
      email = logindata.getString('email')!;
      photo = logindata.getString('photo')!;
    });
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final String imageUrl;

  GridItem({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
