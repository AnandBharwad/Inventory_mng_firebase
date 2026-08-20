import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_model.dart';

class StockTransactionService {
  Future<void> addStockTransaction(StockModel stockModel) async {
    await FirebaseFirestore.instance
        .collection("StockTransaction")
        .add(stockModel.toMap());
  }
}
