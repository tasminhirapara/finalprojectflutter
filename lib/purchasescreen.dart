import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojectflutter/purchaserecord.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class purchasescreen extends StatefulWidget {
  final String businessname;
  final String email;
  purchasescreen({required this.businessname, required this.email});

  @override
  State<purchasescreen> createState() => _purchasescreenState();
}

class _purchasescreenState extends State<purchasescreen> {
  void initState() {
    super.initState();
  }

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
                  addPurchaseMonth(monthController.text, currentYear);
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

  Future<void> addPurchaseMonth(String month, String year) async {
    await FirebaseFirestore.instance.collection('purchasemonth').add({
      'businessname': widget.businessname,
      'email': widget.email,
      'month': month,
      'year': year,
    });
  }

  Future<void> deletePurchaseMonth(String monthId) async {
    await FirebaseFirestore.instance
        .collection('purchasemonth')
        .doc(monthId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase'),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('purchasemonth')
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
                      DocumentSnapshot purchaseMonth =
                          snapshot.data!.docs[index];
                      return Card(
                        elevation: 10,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => purchaserecored(
                                          businessname: widget.businessname,
                                          email: widget.email,
                                          selectedMonth: purchaseMonth['month'],
                                          selectedYear: purchaseMonth['year'],
                                        )));
                          },
                          leading:
                              Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(
                              "${purchaseMonth['month']} ${purchaseMonth['year']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deletePurchaseMonth(purchaseMonth.id);
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
