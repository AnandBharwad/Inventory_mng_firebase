 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_database_firebase/A_Firebase/model/category_model.dart';

class CategoryService {
  Future<void> addCategory(CategoryModel category) async {
    final categoryName = category.categoryName?.trim() ?? "";

    if (categoryName.isEmpty) {
      throw Exception("Category Name cannot be empty");
    }

    final normalizedName = normalizeCategoryName(categoryName);

    final existinfCategory = await FirebaseFirestore.instance
        .collection("Category")
        .doc(normalizedName)
        .get();

    if (existinfCategory.exists) {
      throw Exception("Category Already Exists");
    }

    await FirebaseFirestore.instance
        .collection("Category")
        .doc(normalizedName)
        .set({"categoryName": categoryName});

    // //2nd
    // final categoryId = normalizeCategoryName(categoryName);

    // final categoryRef =
    //     FirebaseFirestore.instance.collection("Category").doc(categoryId);

    // final existingCategory = await categoryRef.get();

    // if (existingCategory.exists) {
    //   throw Exception("Category already exists");
    // }

    // await categoryRef.set({
    //   "categoryName": categoryName,
    // });

    //
    //await FirebaseFirestore.instance
    //     .collection("Category")
    //     .add(category.toMap());
  }

  String normalizeCategoryName(String name) {
    return name.trim().toLowerCase();
  }

  Stream<List<CategoryModel>> fetchCategory() {
    return FirebaseFirestore.instance
        .collection("Category")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
/* 

.snapshots().map((snapshot){
  return snapshots.docs.map((doc){
  return CategoryModel.fromjson(doc.data(),doc.id);}).tolist();
})


*/

  Future<void> removeCategory(String id) async {
    await FirebaseFirestore.instance.collection("Category").doc(id).delete();
  }

  Future<String> fetchCategoryNameById(String categoryId) async {
    var document = await FirebaseFirestore.instance
        .collection("Category")
        .doc(categoryId)
        .get();

    if (!document.exists) {
      return "Unknown";
    }


    return document["categoryName"]?.toString() ?? "Unknown";
  }
}
