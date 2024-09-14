import 'package:finalprojectflutter/screenthree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class screenone extends StatefulWidget {
  const screenone({super.key});

  @override
  State<screenone> createState() => _screenoneState();
}

class _screenoneState extends State<screenone> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  late SharedPreferences logindata;
  late bool newuser;

  @override
  void initState() {
    super.initState();
    checkdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              "images/preview.jpg",
              height: 400,
              width: 500,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Welcome !",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Manage your businesses in simple way",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              height: 70,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  _handleSignIn(context); // for signin
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/google.png",
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Sign in With Google",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  side: BorderSide(width: 3, color: Colors.black),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.all(20),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleaccount = await _googleSignIn.signIn();

      if (googleaccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleaccount.authentication;

        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        print('Access Token: $accessToken');
        print('ID Token: $idToken');

        if (accessToken != null) {
          print("Name is :" + googleaccount.displayName.toString());
          print("Name is :" + googleaccount.email.toString());
          print("Name is :" + googleaccount.photoUrl.toString());

          print("Logged in succesfully");
          String photo = googleaccount.photoUrl ??
              "https://static.vecteezy.com/system/resources/previews/000/593/472/original/vector-business-men-icon.jpg";
          logindata.setBool('tops', false);
          logindata.setString('username', googleaccount.displayName.toString());
          logindata.setString('email', googleaccount.email.toString());
          logindata.setString('photo', photo.toString());

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => screenthree(
                        email: googleaccount.email.toString(),
                      )));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void checkdata() async {
    logindata = await SharedPreferences.getInstance();
  }
}
