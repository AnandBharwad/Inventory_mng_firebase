import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductModel {
  String? id;
  String? productName;
  int? productQty;
  double? productPrice;

  ProductModel(
  
      {this.id,
        required this.productName,
      required this.productQty,
      required this.productPrice});

  //Now , convert data into map format
  Map<String, dynamic> toMap() {
    return {
      "productName": productName,
      "productQty": productQty,
      "productPrice": productPrice
    };
  }

  //when we fetch records from firebase it will return records in map format
  //but we  have to convert into product object.

  factory ProductModel.fromJson(Map<String, dynamic> map, String documentId) {
    return ProductModel(
        id: documentId,
        productName: map["productName"],
        productQty: (map["productQty"] as num).toInt(),
        productPrice: (map["productPrice"] as num).toDouble());
  }
}
