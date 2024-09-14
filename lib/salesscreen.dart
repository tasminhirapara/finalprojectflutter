import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojectflutter/salesrecored.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SaleScreen extends StatefulWidget {
  final String businessname;
  final String email;

  SaleScreen({required this.businessname, required this.email});

  @override
  _SaleScreenState createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  @override
  void showAddMonthDialog(BuildContext context) {
    TextEditingController monthController = TextEditingController();
    String currentYear = DateFormat('yyyy').format(DateTime.now());
    String currentMonth = DateFormat('MMMM').format(DateTime.now());

    monthController.text = currentMonth;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Sales Month'),
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
                  addSalesMonth(monthController.text, currentYear);
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

  Future<void> addSalesMonth(String month, String year) async {
    await FirebaseFirestore.instance.collection('salesmonth').add({
      'businessname': widget.businessname,
      'email': widget.email,
      'month': month,
      'year': year,
    });
  }

  Future<void> deleteSalesMonth(String monthId) async {
    await FirebaseFirestore.instance
        .collection('salesmonth')
        .doc(monthId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
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
                    .collection('salesmonth')
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
                      DocumentSnapshot salesMonth = snapshot.data!.docs[index];
                      return Card(
                        elevation: 10,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SalesRecored(
                                          businessname: widget.businessname,
                                          email: widget.email,
                                          selectedMonth: salesMonth['month'],
                                          selectedYear: salesMonth['year'],
                                        )));
                          },
                          leading:
                              Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(
                              "${salesMonth['month']} ${salesMonth['year']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteSalesMonth(salesMonth.id);
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
