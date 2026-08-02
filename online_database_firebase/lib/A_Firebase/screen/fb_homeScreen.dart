import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_addProduct.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_login.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_productViewScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_user_profile.dart';

class FbHomescreen extends StatefulWidget {
  const FbHomescreen({super.key});

  @override
  State<FbHomescreen> createState() => _FbHomescreenState();
}

class _FbHomescreenState extends State<FbHomescreen> {
  String? userName = "";

  Future<void> fetchData() async {
    User? user = await FirebaseAuth.instance.currentUser;
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("Manager")
        .doc(user!.uid)
        .get();

    userName = document["username"];
  }

  Future<void> logeOutUser() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => FbLogin()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Manager Dashboard",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FbUserProfile(),
                  ));
            },
            icon: Icon(Icons.person),
          )
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            // Add Product Card
            InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => FbAddproduct()));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.add_shopping_cart,
                          color: Colors.blue, size: 26),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Add Product",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // View Product Card
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => FbProductviewscreen()));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.indigo.shade50,
                      child: const Icon(Icons.inventory_2_outlined,
                          color: Colors.indigo, size: 26),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "View Products",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
