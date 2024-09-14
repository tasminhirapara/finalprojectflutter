import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockBook extends StatefulWidget {
  final String businessname;
  final String email;

  StockBook({required this.businessname, required this.email});

  @override
  _StockBookScreenState createState() => _StockBookScreenState();
}

class _StockBookScreenState extends State<StockBook> {
  @override
  void initState() {
    super.initState();
  }

  void showStockDialog(BuildContext context,
      {String? stockId, String? initialStockName, String? initialQuantity}) {
    TextEditingController stockNameController =
        TextEditingController(text: initialStockName ?? '');
    TextEditingController quantityController =
        TextEditingController(text: initialQuantity ?? '');
    bool isEditMode = stockId != null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditMode ? 'Edit Stock' : 'Add Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockNameController,
                decoration: InputDecoration(labelText: 'Stock Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
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
                if (stockNameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  if (isEditMode) {
                    updateStock(stockId!, stockNameController.text,
                        quantityController.text);
                  } else {
                    addStock(stockNameController.text, quantityController.text);
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                }
              },
              child: Text(isEditMode ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addStock(String stockName, String quantity) async {
    await FirebaseFirestore.instance.collection('stockbook').add({
      'businessname': widget.businessname,
      'email': widget.email,
      'stockname': stockName,
      'quantity': int.parse(quantity),
    });
  }

  Future<void> updateStock(
      String stockId, String stockName, String quantity) async {
    await FirebaseFirestore.instance
        .collection('stockbook')
        .doc(stockId)
        .update({
      'stockname': stockName,
      'quantity': int.parse(quantity),
    });
  }

  Future<void> deleteStock(String stockId) async {
    await FirebaseFirestore.instance
        .collection('stockbook')
        .doc(stockId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Book"),
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
                    .collection('stockbook')
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
                      DocumentSnapshot stock = snapshot.data!.docs[index];
                      return Card(
                        elevation: 20.0,
                        child: ListTile(
                          title: Text(stock['stockname']),
                          subtitle: Text('Quantity: ${stock['quantity']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showStockDialog(context,
                                      stockId: stock.id,
                                      initialStockName: stock['stockname'],
                                      initialQuantity:
                                          stock['quantity'].toString());
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteStock(stock.id);
                                },
                              ),
                            ],
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
          showStockDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
