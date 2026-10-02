// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:online_database_firebase/A_Firebase/routes/nav_routes.dart';
// class FbLogin extends StatefulWidget {
//   const FbLogin({super.key});

//   @override
//   State<FbLogin> createState() => _FbLoginState();
// }

// class _FbLoginState extends State<FbLogin> {
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();

//   var _formCheck = GlobalKey<FormState>();
//   bool _tooSee = true;

//   Future<bool> checkLoginData(String email, String password) async {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);

//       String uid = userCredential.user!.uid;

//       print("------------------->>>>>> UID ${uid}");
//       DocumentSnapshot doc =
//           await FirebaseFirestore.instance.collection("Manager").doc(uid).get();

//       print("Hello ${doc["username"]}");
//       return true;
//     } catch (e) {
//       print("Login Error : $e");
//       return false;
//     }
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amber,
//       appBar: AppBar(
//         title: Text("FireBase Form"),
//         backgroundColor: Color.fromARGB(137, 118, 204, 238),
//         foregroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Container(
//             height: 400,
//             width: 450,
//             decoration: BoxDecoration(
//                 color: const Color.fromARGB(137, 118, 204, 238),
//                 borderRadius: BorderRadius.circular(20)),
//             child: Center(
//               child: Form(
//                   key: _formCheck,
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       spacing: 9,
//                       children: [
//                         SizedBox(
//                           height: 40,
//                         ),
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: InputDecoration(
//                             hintText: "Enter your email",
//                             labelText: "E-mail",
//                             labelStyle: TextStyle(color: Colors.black),
//                             icon: Icon(
//                               Icons.mail,
//                               color: Colors.black,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Colors.black, width: 2),
//                                 borderRadius: BorderRadius.circular(15)),
//                             errorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                     color: Colors.redAccent, width: 2),
//                                 borderRadius: BorderRadius.circular(15)),
//                             focusedErrorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                     color: Colors.redAccent, width: 2),
//                                 borderRadius: BorderRadius.circular(15)),
//                           ),
//                           validator: (value) {
//                             if (value!.isEmpty || value == null) {
//                               return "Please Enter Your Email";
//                             }
//                           },
//                         ),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: _tooSee,
//                           decoration: InputDecoration(
//                             hintText: "Enter your password",
//                             labelText: "Password",
//                             labelStyle: TextStyle(color: Colors.black),
//                             icon: Icon(
//                               Icons.password,
//                               color: Colors.black,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Colors.black, width: 2),
//                                 borderRadius: BorderRadius.circular(15)),
//                             errorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                     color: Colors.redAccent, width: 2),
//                                 borderRadius: BorderRadius.circular(15)),
//                             focusedErrorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                     color: Colors.redAccent, width: 2),
//                                 borderRadius: BorderRadius.circular(15)),
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _tooSee = !_tooSee;
//                                 });
//                               },
//                               icon: _tooSee
//                                   ? Icon(Icons.remove_red_eye)
//                                   : Icon(Icons.close),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value!.isEmpty || value == null) {
//                               return "Please Enter Your Email";
//                             }
//                           },
//                         ),
//                         SizedBox(
//                           height: 12,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: SizedBox(
//                             height: 40,
//                             width: double.maxFinite,
//                             child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.black,
//                                   backgroundColor: Colors.white,
//                                   elevation: 6,
//                                   shape: ContinuousRectangleBorder(
//                                     borderRadius:
//                                         BorderRadiusGeometry.circular(18),
//                                   ),
//                                 ),
//                                 onPressed: () async {
//                                   if (_formCheck.currentState!.validate()) {
//                                     bool isLogin = await checkLoginData(
//                                         _emailController.text.toString(),
//                                         _passwordController.text.toString());

//                                     if (isLogin) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(SnackBar(
//                                         content: Text("Login Successfull"),
//                                         backgroundColor: Colors.green,
//                                       ));
//                                       if (!mounted) return;
//                                       // Navigator.pushReplacement(
//                                       //     context,
//                                       //     MaterialPageRoute(
//                                       //         builder: (_) => FbHomescreen()));
//                                       Navigator.pushNamed(
//                                           context, NavRoutes.bottomPages);
//                                     } else {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(SnackBar(
//                                         content: Text(
//                                             "Login Faild,Please cheack your credentials"),
//                                         backgroundColor: Colors.redAccent,
//                                       ));
//                                     }
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                             content: Text(
//                                                 "Please Fill up The form")));
//                                   }
//                                 },
//                                 child: Text("Save Info")),
//                           ),
//                         )
//                       ],
//                     ),
//                   )),
//             )),
//       ),
//     );
//   }
// }
