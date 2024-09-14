import 'dart:async';

import 'package:finalprojectflutter/screenone.dart';
import 'package:finalprojectflutter/screenthree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  late SharedPreferences logindata;
  late bool newuser;
  late String email;
  @override
  void initState() {
    super.initState();
    checkdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          "images/Animation.json",
        ),
      ),
    );
  }

  void checkdata() async {
    logindata =
        await SharedPreferences.getInstance(); // Initialize SharedPreferences
    newuser = logindata.getBool('tops') ?? true;

    if (newuser == false) {
      email = logindata.getString('email')!;
      Timer(Duration(seconds: 4), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => screenthree(email: email)));
      });
    } else {
      Timer(Duration(seconds: 4), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => screenone()));
      });
    }
  }
}
