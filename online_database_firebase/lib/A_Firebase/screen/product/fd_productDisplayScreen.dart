import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/service/category_service.dart';
import 'package:online_database_firebase/A_Firebase/service/supplierService.dart';

class FbProductDisplayScreen extends StatefulWidget {
  final ProductModel product;

  const FbProductDisplayScreen({super.key, required this.product});
  @override
  State<FbProductDisplayScreen> createState() => FbProductDisplayScreenState();
}

class FbProductDisplayScreenState extends State<FbProductDisplayScreen> {
  String categoryName = "Loading...";
  String supplierName = "Loading...";

  Future<void> getEssentialData() async {
    String categoryNameF = await CategoryService()
        .fetchCategoryNameById(widget.product.categoryId!);
    String supplierNameF = await Supplierservice()
        .fetchSupplierNameById(widget.product.supplierId!);
    setState(() {
      categoryName = categoryNameF;
      supplierName = supplierNameF;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getEssentialData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Tag Label
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "INVENTORY ITEM",
                        style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1),
                      ),
                    ),
                  ),

                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.lightBlue.shade200,
                              Colors.indigoAccent.shade400
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.indigo,
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),

                  Text(
                    widget.product.productName!,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  Text(
                    "₹ ${widget.product.productPrice!.toString()}",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 9, horizontal: 9),
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(
                                    Icons.layers_outlined,
                                    color: Colors.deepOrange,
                                  )),
                              const SizedBox(
                                width: 9,
                              ),
                              Text(
                                "Available Stock",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              Spacer(),
                              Text(
                                "${widget.product.productQty} Units",
                                style: TextStyle(
                                    color: widget.product.productQty! > 5
                                        ? Colors.green
                                        : widget.product.productQty! == 0
                                            ? Colors.red
                                            : Colors.orange,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 18,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 9, horizontal: 9),
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(
                                    Icons.category_outlined,
                                    color: Colors.deepOrange,
                                  )),
                              const SizedBox(
                                width: 9,
                              ),
                              Text(
                                "Category",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              Spacer(),
                              Text(
                                categoryName,
                                style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 18,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 9, horizontal: 9),
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(
                                    Icons.factory_outlined,
                                    color: Colors.deepOrange,
                                  )),
                              const SizedBox(
                                width: 9,
                              ),
                              Text(
                                "Supplier",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              Spacer(),
                              Text(
                                supplierName,
                                style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
