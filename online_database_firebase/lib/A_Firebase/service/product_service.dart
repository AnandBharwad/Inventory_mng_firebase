import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';

class ProductService {
  Future<void> addProduct(ProductModel product) async {
    await FirebaseFirestore.instance.collection("Product").add(product.toMap());
  }

  Stream<List<ProductModel>> fetchProduct() {
    return FirebaseFirestore.instance
        .collection("Product")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Stream to fetch the last 5 added products
Stream<List<ProductModel>> fetchRecentProducts({int limit = 5}) {
  return FirebaseFirestore.instance
      .collection("Product")
      .limit(limit)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return ProductModel.fromJson(doc.data(), doc.id);
    }).toList();
  });
}

  Future<void> updateEntireProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection("Product")
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      print("Product Update Message : $e");
    }
  }

  Future<void> deleteProductRecord(String id) async {
    try {
      await FirebaseFirestore.instance.collection("Product").doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStock(String productId, int quantity) async {
    await FirebaseFirestore.instance
        .collection("Product")
        .doc(productId)
        .update({"productQty": quantity});
  }

  Future<int> getCurrentStock(String productId) async {
    var doc = await FirebaseFirestore.instance
        .collection("Product")
        .doc(productId)
        .get();

    return doc["productQty"];
  }

 Future<String> getProductNameById(String productId) async {

  var doc = await FirebaseFirestore.instance
      .collection("Product")
      .doc(productId)
      .get();
  return doc["productName"] ?? "Unknown";
}

}
