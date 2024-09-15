import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecordScreen extends StatefulWidget {
  final String businessname;
  final String email;
  final String clientnumber;

  RecordScreen({
    required this.businessname,
    required this.email,
    required this.clientnumber,
  });

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  TextEditingController _totalReceivedController = TextEditingController();
  TextEditingController _totalPaidController = TextEditingController();
  TextEditingController _totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTotals();
  }

  void fetchTotals() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('clientrecord')
        .where('businessname', isEqualTo: widget.businessname)
        .where('email', isEqualTo: widget.email)
        .where('clientnumber', isEqualTo: widget.clientnumber)
        .get();

    double totalReceived = 0;
    double totalPaid = 0;

    querySnapshot.docs.forEach((doc) {
      totalReceived += doc['received'];
      totalPaid += doc['paid'];
    });

    setState(() {
      _totalReceivedController.text = totalReceived.toString();
      _totalPaidController.text = totalPaid.toString();
      _totalController.text = (totalReceived - totalPaid).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Record'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _totalReceivedController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Total Received',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _totalPaidController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Total Paid',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _totalController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Total',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clientrecord')
                    .where('businessname', isEqualTo: widget.businessname)
                    .where('email', isEqualTo: widget.email)
                    .where('clientnumber', isEqualTo: widget.clientnumber)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot record = snapshot.data!.docs[index];
                      return ListTile(
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteclientrecored(record.id);
                          },
                        ),
                        title: Text("${record['date']} - ${record['time']}"),
                        subtitle: Text(
                            "Received: ${record['received']} | Paid: ${record['paid']}"),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      showTransactionDialog(context, 'Paid');
                    },
                    child: Text('Paid',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      side: BorderSide(width: 2, color: Colors.black),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      showTransactionDialog(context, 'Received');
                    },
                    child: Text("Received",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      side: BorderSide(width: 2, color: Colors.black),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.all(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showTransactionDialog(BuildContext context, String type) {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$type Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: '$type Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
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
                if (amountController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  addTransaction(
                      type, amountController.text, descriptionController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addTransaction(
      String type, String amount, String description) async {
    double amountValue = double.parse(amount);

    await FirebaseFirestore.instance.collection('clientrecord').add({
      'businessname': widget.businessname,
      'email': widget.email,
      'clientnumber': widget.clientnumber,
      'paid': type == 'Paid' ? amountValue : 0,
      'received': type == 'Received' ? amountValue : 0,
      'date': DateTime.now().toString().split(' ')[0],
      'time': TimeOfDay.now().format(context),
      'description': description,
    });

    fetchTotals();
  }

  Future<void> deleteclientrecored(String expenseId) async {
    await FirebaseFirestore.instance
        .collection('clientrecord')
        .doc(expenseId)
        .delete();

    fetchTotals();
  }
}
