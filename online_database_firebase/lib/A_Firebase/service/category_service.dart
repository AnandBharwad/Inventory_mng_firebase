import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:online_database_firebase/A_Firebase/model/category_model.dart';

class CategoryService {
  Future<void> addCategory(CategoryModel category) async {
    await FirebaseFirestore.instance
        .collection("Category")
        .add(category.toMap());
  }

  Stream<List<CategoryModel>> fetchCategory() {
    return FirebaseFirestore.instance.collection("Category").snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> removeCategory(String id) async {
    await FirebaseFirestore.instance
        .collection("Category")
        .doc(id)
        .delete();

  }
}
