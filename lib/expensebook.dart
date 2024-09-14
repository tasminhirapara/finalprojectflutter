import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expenserecored.dart';

class expensebook extends StatefulWidget {
  final String businessname;
  final String email;
  expensebook({required this.businessname, required this.email});

  @override
  State<expensebook> createState() => _expensebookState();
}

class _expensebookState extends State<expensebook> {
  void showAddMonthDialog(BuildContext context) {
    TextEditingController monthController = TextEditingController();
    String currentYear = DateFormat('yyyy').format(DateTime.now());
    String currentMonth = DateFormat('MMMM').format(DateTime.now());

    monthController.text = currentMonth;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Purchase Month'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: monthController,
                decoration: InputDecoration(labelText: 'Month'),
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Year',
                  hintText: currentYear,
                ),
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
                if (monthController.text.isNotEmpty) {
                  addexpanseMonth(monthController.text, currentYear);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a month')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addexpanseMonth(String month, String year) async {
    await FirebaseFirestore.instance.collection('expensemonth').add({
      'businessname': widget.businessname,
      'email': widget.email,
      'month': month,
      'year': year,
    });
  }

  Future<void> deleteexpanseMonth(String monthId) async {
    await FirebaseFirestore.instance
        .collection('expensemonth')
        .doc(monthId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Month'),
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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('expensemonth')
                    .where('businessname', isEqualTo: widget.businessname)
                    .where('email', isEqualTo: widget.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot expenceMonth =
                          snapshot.data!.docs[index];
                      return Card(
                        elevation: 10,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Expenserecored(
                                          businessname: widget.businessname,
                                          email: widget.email,
                                          selectedMonth: expenceMonth['month'],
                                          selectedYear: expenceMonth['year'],
                                        )));
                          },
                          leading:
                              Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(
                              "${expenceMonth['month']} ${expenceMonth['year']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteexpanseMonth(expenceMonth.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddMonthDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
