import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class peerInfo extends StatefulWidget {
  peerInfo({Key? key, required this.xpeerId}) : super(key: key);

  final String xpeerId;

  @override
  _peerInfoState createState() => _peerInfoState();
}

class _peerInfoState extends State<peerInfo> {
  double _avg_rating = 0;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.xpeerId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // get the data from this document snapshot
        var data = documentSnapshot.data() as Map<String, dynamic>;

        var arr = data['ranks'];
        // update the arr
        double sum = 0;
        for (int i = 0; i < arr.length; i++) {
          var x = arr[i];
          sum = sum + x;
        }
        double result = sum / arr.length;

        setState(() {
          _avg_rating = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text('User Info',
              style: TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22)),
        ),
      ),
      body: Center(
          child: Card(
        elevation: 25,
        margin: const EdgeInsets.fromLTRB(0, 200, 0, 250),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Avarage Rating of this user: "),
              const SizedBox(
                height: 26,
              ),
              Text(
                "$_avg_rating ",
                style:
                    const TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22),
              )
            ],
          ),
        ),
      )),
    );
  }
}
