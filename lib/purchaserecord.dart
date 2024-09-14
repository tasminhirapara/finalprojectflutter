import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalprojectflutter/purchaseinvoice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class purchaserecored extends StatefulWidget {
  final String businessname;
  final String email;
  final String selectedMonth;
  final String selectedYear;
   purchaserecored({
    required this.businessname,
    required this.email,
    required this.selectedMonth,
    required this.selectedYear,});

  @override
  State<purchaserecored> createState() => _purchaserecoredState();
}

class _purchaserecoredState extends State<purchaserecored> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.selectedMonth} ${widget.selectedYear}"),
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
                    .collection('purchaseinvoice')
                    .where('businessname', isEqualTo: widget.businessname)
                    .where('email', isEqualTo: widget.email)
                    .where('month',
                    isEqualTo:
                    widget.selectedMonth)
                    .where('year',
                    isEqualTo:
                    widget.selectedYear)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot invoice = snapshot.data!.docs[index];
                      return Card(
                        elevation: 10.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => purchseinvoice(
                                      invoicenumber:
                                      invoice['invoicenumber'],
                                    )));
                          },
                          leading: Icon(Icons.receipt),
                          title: Text("Invoice :${invoice['invoicenumber']}"),
                          subtitle: Text(
                              "Client: ${invoice['clientname']} - Total: ${invoice['total']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteInvoice(invoice.id);
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
          showAddInvoiceDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showAddInvoiceDialog(BuildContext context) {
    String selectedClient = '';
    String selectedStock = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Purchase Invoice'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('clienttable')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<DropdownMenuItem<String>> clientItems = [];
                      for (var doc in snapshot.data!.docs) {
                        clientItems.add(
                          DropdownMenuItem(
                            value: doc['clientnumber'],
                            child: Text(doc['clientname']),
                          ),
                        );
                      }
                      return DropdownButtonFormField(
                        hint: Text('Select Client'),
                        items: clientItems,
                        onChanged: (value) {
                          selectedClient = value!;
                        },
                      );
                    },
                  ),
                  // Stock Dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('stockbook')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<DropdownMenuItem<String>> stockItems = [];
                      for (var doc in snapshot.data!.docs) {
                        stockItems.add(
                          DropdownMenuItem(
                            value: doc['stockname'],
                            child: Text(
                                '${doc['stockname']} (${doc['quantity']})'),
                          ),
                        );
                      }
                      return DropdownButtonFormField(
                        hint: Text('Select Stock'),
                        items: stockItems,
                        onChanged: (value) {
                          selectedStock = value!;
                        },
                      );
                    },
                  ),
                  // Quantity TextField
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: rateController,
                    decoration: InputDecoration(labelText: 'Unit Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: taxController,
                    decoration: InputDecoration(labelText: 'Interest %'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
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
                if (selectedClient.isNotEmpty &&
                    selectedStock.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    rateController.text.isNotEmpty &&
                    taxController.text.isNotEmpty) {
                  calculateTotal(
                    quantityController.text,
                    rateController.text,
                    taxController.text,
                  );
                  addInvoice(
                    selectedClient,
                    selectedStock,
                    quantityController.text,
                    rateController.text,
                    taxController.text,
                    totalController.text,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
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

  void calculateTotal(
      String quantity,
      String rate,
      String tax,
      ) {
    double qty = double.parse(quantity);
    double rateValue = double.parse(rate);
    double taxValue = double.parse(tax);

    double subtotal = qty * rateValue;
    double total = subtotal + (subtotal * taxValue / 100);

    setState(() {
      totalController.text = total.toStringAsFixed(2);
    });
  }

  Future<void> addInvoice(
      String clientName,
      String stockName,
      String quantity,
      String rate,
      String tax,
      String total,
      ) async {
    int newInvoiceNumber = await getNewInvoiceNumber();
    await FirebaseFirestore.instance.collection('purchaseinvoice').add({
      'invoicenumber': newInvoiceNumber,
      'businessname': widget.businessname,
      'email': widget.email,
      'clientname': clientName,
      'stockname': stockName,
      'quantity': int.parse(quantity),
      'rate': double.parse(rate),
      'tax': double.parse(tax),
      'total': double.parse(total),
      'month': widget.selectedMonth,
      'year': widget.selectedYear,
      'date': DateTime.now().toString().split(' ')[0],
      'time': TimeOfDay.now().format(context),
    });
  }

  Future<int> getNewInvoiceNumber() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('purchaseinvoice')
        .orderBy('invoicenumber', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 1;
    } else {
      return querySnapshot.docs.first['invoicenumber'] + 1;
    }
  }
  Future<void> deleteInvoice(String invoiceId) async {
    await FirebaseFirestore.instance
        .collection('purchaseinvoice')
        .doc(invoiceId)
        .delete();
  }
}
