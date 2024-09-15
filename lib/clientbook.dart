import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'clientmodel.dart';

class clientbook extends StatefulWidget {
  final String businessname;
  final String email;

  clientbook({required this.businessname, required this.email});

  @override
  _clientbookState createState() => _clientbookState();
}

class _clientbookState extends State<clientbook> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientContactController = TextEditingController();
  late Future<List> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Client Book"),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List>(
          future: getdata(),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              var g = getdata();
              return ClientModel(
                list: snapshot.data!,
                onRefresh: _refreshData,
              );
            }
            if (snapshot.hasError) {
              print('Network Not Found');
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddClientDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List> getdata() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('clienttable')
        .where('Email', isEqualTo: widget.email)
        .where('businessname', isEqualTo: widget.businessname)
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void _showAddClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: clientNameController,
                decoration: InputDecoration(labelText: 'Client Name'),
              ),
              TextField(
                controller: clientContactController,
                decoration: InputDecoration(labelText: 'Client Contact'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (clientNameController.text.isEmpty ||
                    clientContactController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                } else {
                  _registerClient();
                  _clearText();
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _clearText() {
    clientNameController.clear();
    clientContactController.clear();
  }

  CollectionReference addUser =
      FirebaseFirestore.instance.collection('clienttable');

  Future<void> _registerClient() {
    return addUser
        .add({
          'businessname': widget.businessname,
          'Email': widget.email,
          'clientname': clientNameController.text,
          'clientnumber': clientContactController.text,
        })
        .then((value) => print('Client Added'))
        .catchError((error) => print('Failed to add client: $error'));
  }

  void _refreshData() {
    setState(() {
      _clientsFuture = getdata();
    });
  }
}
