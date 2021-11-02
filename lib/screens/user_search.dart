import 'package:flutter/material.dart';
import '../logins/log_reg.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUser extends StatefulWidget {
  SearchUser({Key? key}) : super(key: key);

  @override
  _SearchUserState createState() => _SearchUserState();
}

// post class
class Post {
  final String title;
  final String imageURL;

  Post(this.title, this.imageURL);
}

class _SearchUserState extends State<SearchUser> {
  final TextEditingController _textController = TextEditingController();

  final Stream<QuerySnapshot> _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  static const border = OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(left: Radius.circular(5)));

  var userId = "";
  Map<String, dynamic> datax = {};
  var _arr = [];

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
          title: const Text('Search',
              style: TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22)),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Search By First Name',
                  border: border,
                  errorBorder: border,
                  disabledBorder: border,
                  focusedBorder: border,
                  focusedErrorBorder: border,
                  suffixIcon: Container(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _textController.clear();
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _arr = [];
                              });
                              setState(() {});
                              // query the users buy first Name
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .where('firstName',
                                      isEqualTo: _textController.text.trim())
                                  .get()
                                  .then((QuerySnapshot querySnapshot) {
                                var arr = [];
                                querySnapshot.docs.forEach((doc) {
                                  Map<String, String> d = {};

                                  d['firstName'] = doc['firstName'];
                                  d['lastName'] = doc['lastName'];
                                  d['imageURL'] = doc['imageURL'];
                                  d['peerId'] = doc.id;

                                  arr.add(d);

                                  setState(() {
                                    _arr = arr;
                                  });
                                });
                              });

                              setState(() {});
                              _textController.clear();
                            },
                            icon: Icon(Icons.search),
                          ),
                        ],
                      ))),
            ),
            Expanded(
              child: _arr.isEmpty
                  ? const Text("No Users found")
                  : ListView.builder(
                      itemCount: _arr.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_arr[index]['peerId'] != userId) {
                          return Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      userId: userId,
                                      peerId: _arr[index]['peerId'],
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage:
                                        NetworkImage(_arr[index]['imageURL'])),
                                title: Text(_arr[index]["firstName"] +
                                    " " +
                                    _arr[index]["lastName"]),
                              ),
                            ),
                          );
                        } else {
                          return const ListTile(
                            title: Text("This User already logged in"),
                          );
                        }
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
