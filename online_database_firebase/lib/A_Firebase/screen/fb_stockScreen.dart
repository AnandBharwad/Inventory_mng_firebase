import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_model.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/service/stock_service.dart';

class FbStockscreen extends StatefulWidget {
  const FbStockscreen({super.key});

  @override
  State<FbStockscreen> createState() => _FbStockscreenState();
}

class _FbStockscreenState extends State<FbStockscreen> {
  ProductService _productService = ProductService();
  String? _selectedProduct;

  TextEditingController _quantityController = TextEditingController();
  Future<void> addStockRecord() async {
    final String productId = _selectedProduct!;
    print(productId);
    final int current_Stock = await _productService.getCurrentStock(productId);

    final int new_stock = int.parse(_quantityController.text.toString());

    final int updated_Stock = current_Stock + new_stock;

    print("------------->>>>>>> Current Stock ${current_Stock}");
    print("------------->>>>>>> new_stock  ${new_stock}");
    print("------------->>>>>>>updated_Stock ${updated_Stock}");

    await _productService.updateStock(productId, updated_Stock);

    final transactionModel = StockModel(
        productId: productId,
        type: "IN",
        quantity: updated_Stock,
        date: DateTime.now());

    await StockTransactionService().addStockTransaction(transactionModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 9,
          children: [
            StreamBuilder<List<ProductModel>>(
              stream: _productService.fetchProduct(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                  );
                }

                final products = snapshot.data ?? [];

                return DropdownButtonFormField<String>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder()),
                  items: products.map((products) {
                    return DropdownMenuItem<String>(
                      value: products.id,
                      child: Text(
                        products.productName ?? "",
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value;
                    });
                  },
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                  hintText: "Enter Quantity ",
                  labelText: "Quantity",
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder()),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(9))),
                  onPressed: () {
                    addStockRecord();
                  },
                  child: Text("Save")),
            )
          ],
        ),
      ),
    );
  }
}
