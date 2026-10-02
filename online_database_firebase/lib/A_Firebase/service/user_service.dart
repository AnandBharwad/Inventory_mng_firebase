import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  late String _userName;
  late String _userEmail;
  late String _userContact;

  String get getUserName {
    return _userName;
  }

  String get getUserEmail {
    return _userEmail;
  }

  String get getUserContact {
    return _userContact;
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("Manager")
        .doc(user!.uid)
        .get();

    _userName = document["username"];
    _userEmail = document["email"];
    _userContact = document["contact"];
  }

  Future<void> updateUserData(
      String userName, String userContact, String userEmail) async {
    User? user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("Manager").doc(user?.uid).set(
        {"userName": userName, "contact": userContact, "email": userEmail});
  }
}
