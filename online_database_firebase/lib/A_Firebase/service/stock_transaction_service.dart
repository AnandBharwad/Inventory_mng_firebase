import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_model.dart';

class StockTransactionService {
  Future<void> addStockTransaction(StockTransactionModel stockModel) async {
    await FirebaseFirestore.instance
        .collection("StockTransaction")
        .add(stockModel.toMap());
  }

  Stream<List<StockTransactionModel>> fetchStockTransaction() {
    return FirebaseFirestore.instance
        .collection("StockTransaction")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StockTransactionModel.fromjson(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<StockTransactionModel>> fetchRecentStockTransaction(
      {int limit = 5}) {
    return FirebaseFirestore.instance
        .collection("StockTransaction")
        .orderBy("date", descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StockTransactionModel.fromjson(doc.data(), doc.id);
      }).toList();
    });
  }
}
