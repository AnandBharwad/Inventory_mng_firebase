import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FbUserProfile extends StatefulWidget {
  const FbUserProfile({super.key});

  @override
  State<FbUserProfile> createState() => _FbUserProfileState();
}

class _FbUserProfileState extends State<FbUserProfile> {
  String? userName;
  String? userEmail;
  String? userContact;

  late Future<void> _fetchDataFuture;

  Future<void> fetchData() async {
    User? user = await FirebaseAuth.instance.currentUser;
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("Manager")
        .doc(user!.uid)
        .get();

    userName = document["username"];
    userEmail = document["email"];
    userContact = document["contact"];
  }

  @override
  void initState() {
    super.initState();
    // Initialize the future once to prevent reload loops on rebuild
    _fetchDataFuture = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Profile Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.red),
        

      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Photo Avatar Holder
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo.shade50,
                    child: const Icon(
                      Icons.person_outline,
                      size: 50,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(3, 9),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.indigo.withOpacity(0.1),
                            radius: 20,
                            child: const Icon(Icons.person,
                                color: Colors.indigo, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Name",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName ?? "Not Set",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1),
                      ),

                      // User Contact Data Tile
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            radius: 20,
                            child: const Icon(Icons.phone,
                                color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Contact Number",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userContact ?? "Not Set",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(
                          height: 1,
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            child: Icon(
                              Icons.mail,
                              color: Colors.amberAccent,
                              size: 20,
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                Text(
                                  userEmail!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
