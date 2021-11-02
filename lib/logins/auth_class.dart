import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FireAuth {
  // simple snackbar for errors
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  // this function registers user with signin with email and password
  Future<User?> registerUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(
          FireAuth.customSnackBar(
            content: 'The password is weak.',
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          FireAuth.customSnackBar(
            content: 'The email is already in use.',
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        FireAuth.customSnackBar(
          content: "error in register",
        ),
      );
    }

    return user;
  }

  // signin with email and password
  Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          FireAuth.customSnackBar(
            content: "no user found for this email.",
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          FireAuth.customSnackBar(
            content: "email and password does not match. please try again.",
          ),
        );
      }
    }

    return user;
  }

  // regular signout functionality
  Future<void> signOut({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        FireAuth.customSnackBar(
          content: "error in signout.",
        ),
      );
    }
  }

  Future<User?> anonymousSignin({
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInAnonymously();
      user = userCredential.user;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        FireAuth.customSnackBar(
          content: 'Error occurred while anonymous signin. Try again.',
        ),
      );
    }

    return user;
  }

  Future<bool> sendSignInLinkToEmail(
      {required String email, required BuildContext context}) async {
    try {
      var acs = ActionCodeSettings(
          // URL you want to redirect back to. The domain (www.example.com) for this
          // URL must be whitelisted in the Firebase Console.
          url: 'https://www.example.com/finishSignUp?cartId=1234',
          // This must be true
          handleCodeInApp: true,
          iOSBundleId: 'com.example.ios',
          androidPackageName: 'com.example.android',
          // installIfNotAvailable
          androidInstallApp: true,
          // minimumVersion
          androidMinimumVersion: '12');

      var emailAuth = email;

      // send email
      FirebaseAuth.instance
          .sendSignInLinkToEmail(email: emailAuth, actionCodeSettings: acs)
          .catchError((onError) => ScaffoldMessenger.of(context).showSnackBar(
                FireAuth.customSnackBar(
                  content: 'error in sending email link $onError',
                ),
              ))
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                FireAuth.customSnackBar(
                  content: 'Successfully sent email verification.',
                ),
              ));

      // process completed
      return true;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        FireAuth.customSnackBar(
          content: 'Error while login with facebook.',
        ),
      );
      throw (e);
    }
  }

  // this function verifies the deep link for passwordless signin
  Future<bool> verifyEmailLinkAndSignIn(
      {required String email,
      required emailLink,
      required BuildContext context}) async {
    try {
      var auth = FirebaseAuth.instance;
      // Retrieve the email from wherever you stored it
      var emailAuth = email;
      // Confirm the link is a sign-in with email link.
      if (auth.isSignInWithEmailLink(emailLink)) {
        // The client SDK will parse the code from the link for you.
        auth
            .signInWithEmailLink(email: emailAuth, emailLink: emailLink)
            .then((value) {
          var userEmail = value.user;
          print('Successfully signed in with email link!');
        }).catchError((onError) {
          print('Error signing in with email link $onError');
        });
      }
      return true;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        FireAuth.customSnackBar(
          content: 'Error while login with facebook.',
        ),
      );
      throw (e);
    }
  }
}
