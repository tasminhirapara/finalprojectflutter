import 'package:finalprojectflutter/screenfour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Model extends StatelessWidget {
  late List list;

  Model({required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, i) {
        return Container(
          height: 60,
          child: Card(
            elevation: 2.0,
            borderOnForeground: true,
            child: Center(
              child: ListTile(
                  leading: Icon(Icons.event_note_outlined),
                  title: Text(list[i]['businessname']),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => screenfour(
                                businessname: list[i]['businessname'])));
                  }),
            ),
          ),
        );
      },
      itemCount: list.length,
    );
  }
}
