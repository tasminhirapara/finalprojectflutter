import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  final int invoicenumber;

  InvoiceScreen({required this.invoicenumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('salesinvoice')
            .where('invoicenumber', isEqualTo: invoicenumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var invoiceDocs = snapshot.data!.docs;
          if (invoiceDocs.isEmpty) {
            return Center(
              child: Text("No invoices available"),
            );
          }
          return ListView.builder(
            itemCount: invoiceDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot invoice = invoiceDocs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Invoice :${invoice['invoicenumber']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Date: ${invoice['date']}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        Text(
                          "Client: ${invoice['clientname']}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),

                        // Stock Details
                        Text(
                          "Stock: ${invoice['stockname']}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Quantity: ${invoice['quantity']}",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Rate: ₹${invoice['rate']}",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Tax: ${invoice['tax']}%",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        Text(
                          "Total: ₹${invoice['total']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),

                        Text(
                          "Time: ${invoice['time']}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
