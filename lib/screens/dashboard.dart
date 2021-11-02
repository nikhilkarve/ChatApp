import '../logins/auth_class.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../logins/log_reg.dart';
import 'user_search.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);
  // DashBoard(this.role);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  var format = DateFormat("d/M/y");
  var userId = "";

  FirebaseAuth auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt')
      .snapshots();

  bool isDataFetched = false;

  var fireAuth = FireAuth();

  @override
  void initState() {
    super.initState();

    // if user is not signed in then send him to all login
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AllLogins()));
      }
      setState(() {
        userId = user!.uid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
            title: const Text('UserList',
                style: TextStyle(fontFamily: 'Raleway', fontSize: 22)),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    // write your code here
                    // navigate to new widget
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SearchUser()));
                  },
                  child: const Icon(Icons.person_search_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    // write your code here
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text("Logging out?",
                                  textAlign: TextAlign.center),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      {Navigator.of(context).pop()},
                                  child: const Text('Discard'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // log out from app send user to login screen
                                    // await FirebaseAuth.instance.signOut();
                                    await fireAuth.signOut(context: context);
                                    // navigate to login
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) => AllLogins()));
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ));
                  },
                  child: const Icon(Icons.logout),
                ),
              )
            ],
            automaticallyImplyLeading: false),
      ),
      // body
      body: StreamBuilder<QuerySnapshot>(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading please wait..");
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users available'));
          }

          isDataFetched = true;

          // No error/wait time return listview
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: userId == document.id
                        ? null
                        : Card(
                            child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userId: userId,
                                    peerId: document.id,
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage:
                                      NetworkImage(data['imageURL'])),
                              title: Text(
                                  data["firstName"] + " " + data["lastName"]),
                              subtitle: Text("Joined on " +
                                  format
                                      .format(data['createdAt'].toDate())
                                      .toString()),
                            ),
                          )),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
