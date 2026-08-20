import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SupplierModel {
  String? id;
  String? supplierName;
  String? email;
  String? contact;

  SupplierModel({
    this.id,
    required this.supplierName,
    required this.email,
    required this.contact,
  });

  Map<String, dynamic> toMap() {
    return {
      "supplierName": supplierName,
      "email": email,
      "contact": contact,
    };
  }

  factory SupplierModel.fromJson(Map<String, dynamic> map, String documentId) {
    return SupplierModel(
      id: documentId,
      supplierName: map["supplierName"] ?? "--",
      email: map["email"] ?? "--",
      contact: map["contact"] ?? "--",
    );
  }
}
