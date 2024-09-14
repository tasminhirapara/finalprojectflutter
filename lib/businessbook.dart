import 'package:finalprojectflutter/purchasescreen.dart';
import 'package:finalprojectflutter/salesscreen.dart';
import 'package:finalprojectflutter/screenfour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class businessbook extends StatefulWidget {
  final String businessname;
  final String email;
  businessbook({required this.businessname, required this.email});

  @override
  State<businessbook> createState() => _businessbookState();
}

class _businessbookState extends State<businessbook> {
  final List<Map<String, String>> items = [
    {"title": "Sales", "image": "images/sales.png"},
    {"title": "Purchase", "image": "images/purchase.png"},
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
              builder: (context) => SaleScreen(
                    businessname: widget.businessname,
                    email: widget.email,
                  )));
    }
    if (index == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  purchasescreen(businessname: widget.businessname, email: widget.email)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Book'),
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
    );
  }
}
