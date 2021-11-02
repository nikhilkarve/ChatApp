import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'auth_class.dart';
import '../screens/dashboard.dart';
import 'email_password.dart';
import '../screens/splash.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FanPage",
      theme: ThemeData(
          primarySwatch: Colors.grey,
          backgroundColor: Colors.grey,
          accentColor: Color.fromRGBO(1, 1, 1, 1),
          accentColorBrightness: Brightness.dark,
          buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.grey,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)))),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            title: const Text('Register',
                style: TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22)),
          ),
        ),
        body: const RegisterUserForm(),
      ),
    );
  }
}

class RegisterUserForm extends StatefulWidget {
  const RegisterUserForm({Key? key}) : super(key: key);

  @override
  _RegisterUserFormState createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<RegisterUserForm> {
  final _formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  // email address, password, name, picture, bio, hometown, age.

  var _email = "";
  var _password = "";
  var _firstName = "";
  var _lastName = "";
  var userCredentialsObj;
  var isImageUploaded = false;
  // new code
  var _image;
  var blobData;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  var imageURL;

  Future<Uint8List> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = new File.fromUri(myUri);
    late Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      try {
        _image = File(image!.path);
        isImageUploaded = true;
      } catch (e) {
        print(e);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Register()));
      }

      // _image = File(image!.path);
      // isImageUploaded = true;
    });
    try {
      Uint8List audioByte;
      String myPath = image!.path;
      _readFileByte(myPath).then((bytesData) {
        audioByte = bytesData;
        //do your task here
        setState(() {
          blobData = audioByte;
        });
      });
    } catch (e) {
      // if path invalid or not able to read
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 20,
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // user display picture
                    CircleAvatar(
                      radius: 40.0,
                      backgroundImage:
                          imageURL != null ? NetworkImage(imageURL) : null,
                    ),

                    TextFormField(
                      decoration: const InputDecoration(hintText: "First Name"),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _firstName = val;
                        });
                      },
                    ),

                    TextFormField(
                      decoration: const InputDecoration(hintText: "Last Name"),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _lastName = val;
                        });
                      },
                    ),

                    // text field for email
                    TextFormField(
                      decoration: const InputDecoration(hintText: "Email"),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,

                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _email = val;
                        });
                      },
                    ),

                    // text field for password
                    TextFormField(
                      decoration: const InputDecoration(hintText: "Password"),
                      textAlign: TextAlign.start,

                      obscureText: true,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },

                      onChanged: (val) {
                        setState(() {
                          _password = val;
                        });
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).backgroundColor,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          firebase_storage.FirebaseStorage storage =
                              firebase_storage.FirebaseStorage.instance;
                          final _picker = ImagePicker();
                          PickedFile image;
                          // generate some random number
                          Random random = Random();
                          int randomNumber = random.nextInt(100000);

                          try {
                            image = (await _picker.getImage(
                                source: ImageSource.gallery))!;
                            var file = File(image.path);

                            if (image != null) {
                              // proceed
                              var snapShot = await storage
                                  .ref()
                                  .child("display-pictures/$randomNumber")
                                  .putFile(file);
                              var downloadURL =
                                  await snapShot.ref.getDownloadURL();

                              setState(() {
                                imageURL = downloadURL;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                FireAuth.customSnackBar(
                                  content: "NO Path received for image.",
                                ),
                              );
                            }
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(
                              FireAuth.customSnackBar(
                                content:
                                    "Couldn't select image from gallery. Please try again.",
                              ),
                            );
                          }
                        },
                        child: const Text("Upload Your Picture"),
                      ),
                    ),

                    // this is padding for register button
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
                          User? user =
                              await fireAuth.registerUsingEmailPassword(
                                  email: _email,
                                  password: _password,
                                  context: context);

                          if (user != null) {
                            CollectionReference users =
                                FirebaseFirestore.instance.collection("users");

                            users
                                .doc(user.uid)
                                .set({
                                  'firstName': _firstName,
                                  'lastName': _lastName,
                                  'email': _email,
                                  'password': _password,
                                  'imageURL': imageURL,
                                  'createdAt': DateTime.now(),
                                  'ranks': []
                                })
                                .then((value) => {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: const Text('Congrats!'),
                                                content: const Text(
                                                    'Your Registration is successful.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () => {
                                                      // finally navigate after login
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const DashBoard()))
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ))
                                    })
                                .catchError((error) => {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: const Text(
                                                    'Error Occurred!'),
                                                content: const Text(
                                                    'Error in saving your data to firestore. Please try again.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () => {
                                                      // finally navigate after login
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const SplashScreen()))
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ))
                                    });
                          }
                        }
                      },
                      child: const Text('Register'),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      },
                      child: const Text(
                        "Already Registered?",
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
