import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'clientrecordscreen.dart';

class ClientModel extends StatelessWidget {
  final List list;
  final VoidCallback onRefresh;
  ClientModel({required this.list, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, i) {
        return Container(
          height: 80,
          child: Card(
            elevation: 2.0,
            borderOnForeground: true,
            child: Center(
              child: ListTile(
                leading: Icon(Icons.event_note_outlined),
                title: Text(list[i]['clientname']),
                subtitle: Text(list[i]['clientnumber']),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    _showOptionsDialog(
                      context,
                      list[i]['clientnumber'],
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecordScreen(
                                businessname: list[i]['businessname'],
                                email: list[i]['Email'],
                                clientnumber: list[i]['clientnumber'],
                              )));
                  // Handle onTap if needed
                },
              ),
            ),
          ),
        );
      },
      itemCount: list.length,
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    String phoneNumber,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What would you like to do?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _makeCall(phoneNumber);
                Navigator.of(context).pop();
              },
              child: Text('Call'),
            ),
            TextButton(
              onPressed: () {
                _deleteClient(phoneNumber);

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _deleteClient(String phoneNumber) async {
    try {
      // Query to find the document with the matching phone number
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('clienttable')
          .where('clientnumber', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        print('Client deleted successfully');
        onRefresh();
      } else {
        print('No client found with the phone number');
      }
    } catch (e) {
      print('Failed to delete client: $e');
    }
  }
}
