import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/auth/new_login.dart';
import 'package:online_database_firebase/A_Firebase/routes/nav_routes.dart';

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
      backgroundColor: Colors.grey.withOpacity(0.2),
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
            InkWell(
              onTap: () => Navigator.pushNamed(context, NavRoutes.editCategory),
              // borderRadius: BorderRadius.circular(16)
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.redAccent.withOpacity(0.3),
                      child: Icon(
                        Icons.category,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Check & Delete Cateogries",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

            // Add Product Card
            InkWell(
              onTap: () => Navigator.pushNamed(context, NavRoutes.addProduct),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
              onTap: () => Navigator.pushNamed(context, NavRoutes.viewProducts),
              borderRadius: BorderRadius.circular(9),
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

            InkWell(
              onTap: () => Navigator.pushNamed(context, NavRoutes.addCategory),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 14,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color.fromARGB(255, 6, 243, 14)
                          .withOpacity(0.3),
                      child: Icon(Icons.add),
                    ),
                    Text("Add Category",
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),

            InkWell(
              onTap: () => Navigator.pushNamed(context, NavRoutes.addSupplier),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.amber.withOpacity(0.2),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.amber,
                      ),
                    ),
                    Text("Add Supplier",
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),

            InkWell(
              onTap: () => Navigator.pushNamed(context, NavRoutes.viewStocks),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.withOpacity(0.6),
                      child: Icon(
                        Icons.production_quantity_limits,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Text("Stock Screen")
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
