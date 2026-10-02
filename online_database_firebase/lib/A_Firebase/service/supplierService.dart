import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/supplierModel.dart';

class Supplierservice {
  Future<void> addSupplier(SupplierModel suplier) async {
    await FirebaseFirestore.instance
        .collection("Supplier")
        .add(suplier.toMap());
  }

  Stream<List<SupplierModel>> fetchSupplier() {
    return FirebaseFirestore.instance
        .collection("Supplier")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SupplierModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    return await FirebaseFirestore.instance
        .collection("Supplier")
        .doc(supplier.id)
        .update(supplier.toMap());
  }

  Future<bool> deleteSupplier(String supplierId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Supplier")
          .doc(supplierId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

//if we need name by id
  Future<String> fetchSupplierNameById(String supplierId) async {
    var doc = await FirebaseFirestore.instance
        .collection("Supplier")
        .doc(supplierId)
        .get();
    if (!doc.exists) {
      return "Unknown";
    }
    return doc["supplierName"];
  }
}
