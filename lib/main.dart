import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Baby Names",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baby Name Votes"),
      ),
      body: _buildBody(context),
    );
  }

  // for load data from firebase firestore and build recycler view
  Widget _buildBody(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("baby").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator(); // show loading progress indicator

        return _buildList(context, snapshot.data.documents); // show data to list view
      },
    );
  }

  // setup recycler view item
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  // build item recycler view
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final Record record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0)),
        child: ListTile(
          title: Text(record.name),
          trailing: Text("${record.votes}"),
          onTap: () => record.reference.updateData({"votes": FieldValue.increment(1)}),
        ),
      ),
    );
  }
}

// data class
class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>"; 
}
