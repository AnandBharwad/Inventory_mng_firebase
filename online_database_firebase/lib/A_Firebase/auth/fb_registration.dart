import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_login.dart';

class FbForm extends StatefulWidget {
  const FbForm({super.key});

  @override
  State<FbForm> createState() => _FbFormState();
}

class _FbFormState extends State<FbForm> {
  TextEditingController _userNameController = TextEditingController();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _contactNoController = TextEditingController();

  bool _toSee = true;

  @override
  void dispose() {
    super.dispose();
    _userNameController.dispose();
    _contactNoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> register(
    String email,
    String password,
    String username,
    String contact,
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      print("UID: $uid");

      await FirebaseFirestore.instance
          .collection("Manager")
          .doc(uid)
          .set({"email": email, "username": username, "contact": contact});

      print("Firestore data saved");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        title: Text("FireBase Form"),
        backgroundColor: Color.fromARGB(137, 118, 204, 238),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
            height: 450,
            width: 450,
            decoration: BoxDecoration(
                color: const Color.fromARGB(137, 118, 204, 238),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Form(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  spacing: 9,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                          hintText: "Enter your Name",
                          labelText: "Name",
                          icon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    TextFormField(
                      controller: _contactNoController,
                      decoration: InputDecoration(
                          hintText: "Enter your contact number",
                          labelText: "Contact No",
                          icon: Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: "Enter your email",
                          labelText: "E-mail",
                          icon: Icon(
                            Icons.mail,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _toSee,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        labelText: "Password",
                        icon: Icon(
                          Icons.password,
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(15)),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _toSee = !_toSee;
                            });
                          },
                          icon: _toSee
                              ? Icon(Icons.remove_red_eye)
                              : Icon(Icons.close),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40,
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              elevation: 6,
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(18),
                              ),
                            ),
                            onPressed: () {
                              register(
                                  _emailController.text,
                                  _passwordController.text,
                                  _userNameController.text,
                                  _contactNoController.text);

                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) => FbLogin()));
                            },
                            child: Text("Save Info")),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => FbLogin()));
                        },
                        child: Text("Already Login...!"))
                  ],
                ),
              )),
            )),
      ),
    );
  }
}
