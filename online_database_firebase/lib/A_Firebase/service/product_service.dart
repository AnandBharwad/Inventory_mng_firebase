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
}
