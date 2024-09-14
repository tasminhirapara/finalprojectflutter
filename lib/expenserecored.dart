import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Expenserecored extends StatefulWidget {
  final String businessname;
  final String email;
  final String selectedMonth;
  final String selectedYear;

  Expenserecored({
    required this.businessname,
    required this.email,
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<Expenserecored> {
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalExpense();
  }

  void calculateTotalExpense() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('expenserecored')
        .where('businessname', isEqualTo: widget.businessname)
        .where('email', isEqualTo: widget.email)
        .where('month', isEqualTo: widget.selectedMonth)
        .where('year', isEqualTo: widget.selectedYear)
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += doc['amount'];
    }

    setState(() {
      totalExpense = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedMonth} ${widget.selectedYear}'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Total Expense: ₹${totalExpense.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenserecored')
                  .where('businessname', isEqualTo: widget.businessname)
                  .where('email', isEqualTo: widget.email)
                  .where('month', isEqualTo: widget.selectedMonth)
                  .where('year', isEqualTo: widget.selectedYear)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var expenses = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text("Amount: ₹${expense['amount']}"),
                        subtitle:
                            Text("Description: ${expense['description']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteExpense(expense.id);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddExpenseDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  void showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Expense Amount'),
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
                  addExpense();
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

  Future<void> addExpense() async {
    DateTime now = DateTime.now();
    String month = DateFormat.MMMM().format(now);
    String year = DateFormat.y().format(now);
    String dateTime = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    await FirebaseFirestore.instance.collection('expenserecored').add({
      'businessname': widget.businessname,
      'email': widget.email,
      'amount': double.parse(amountController.text),
      'description': descriptionController.text,
      'month': month,
      'year': year,
      'dateTime': dateTime,
    });

    calculateTotalExpense();
  }

  Future<void> deleteExpense(String expenseId) async {
    await FirebaseFirestore.instance
        .collection('expenserecored')
        .doc(expenseId)
        .delete();

    calculateTotalExpense();
  }
}
