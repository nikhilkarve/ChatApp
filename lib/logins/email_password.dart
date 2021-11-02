import './auth_class.dart';
import '../screens/dashboard.dart';
import 'package:chat_app/logins/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  var _email = "";
  var _password = "";
  var userCredentialsObj;
  var _role = "";
  // create firebae instance
  CollectionReference users =
      FirebaseFirestore.instance.collection("hw2_users");

  var fireAuth = FireAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text('Login',
              style: TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22)),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 20,
          margin: const EdgeInsets.all(20),
          child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(hintText: "Email"),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _email = val.trim();
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(hintText: "Password"),
                      textAlign: TextAlign.start,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _password = val.trim();
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).backgroundColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("checking.. please wait..")),
                          );

                          User? user = await fireAuth.signInUsingEmailPassword(
                              email: _email,
                              password: _password,
                              context: context);

                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const DashBoard()));
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Register()));
                      },
                      child: const Text(
                        "Not a User? Register here!",
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
