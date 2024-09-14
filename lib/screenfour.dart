import 'package:finalprojectflutter/clientbook.dart';
import 'package:finalprojectflutter/screenone.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Clicked on ${items[index]['title']}'),
      ),
    );
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
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => addclient()));
    }
    if (index == 2) {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => clientdetails()));
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
          // backgroundColor: primarycolor,
          elevation: 10.00,
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 30.0,
            mainAxisSpacing: 30.0,
            childAspectRatio: 0.8, // Adjust the aspect ratio as needed
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
                  backgroundColor: Colors.orange, child: Image.network(photo)),
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
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                logindata.setBool('tops', true);
                await _googleSignIn.signOut(); // for signout
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
