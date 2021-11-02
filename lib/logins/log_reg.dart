import 'package:flutter/material.dart';
import './auth_class.dart';
import 'email_password.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../logins/register.dart';

class AllLogins extends StatefulWidget {
  AllLogins({Key? key}) : super(key: key);

  @override
  _AllLoginsState createState() => _AllLoginsState();
}

class _AllLoginsState extends State<AllLogins> {
  var fireAuth = FireAuth();

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text('Login/Register',
              style: TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NEW REGISTRATION
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).backgroundColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.black,
                ),
                label: const Text('New User Registration'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Register(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const SizedBox(height: 25),
              const SizedBox(height: 25),

              // EMAIL AND PASSWORD
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).backgroundColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.envelope,
                  color: Colors.black,
                ),
                label: const Text('Sign-In with email & password'),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Login()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
