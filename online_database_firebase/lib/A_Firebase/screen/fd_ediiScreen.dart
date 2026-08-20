import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/category_model.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/model/supplierModel.dart';
import 'package:online_database_firebase/A_Firebase/service/category_service.dart';
import 'package:online_database_firebase/A_Firebase/service/supplierService.dart';

class FbEditScreen extends StatefulWidget {
  final ProductModel prodModel;

  const FbEditScreen({
    super.key,
    required this.prodModel,
  });

  @override
  State<FbEditScreen> createState() => _FbEditScreenState();
}

class _FbEditScreenState extends State<FbEditScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final CategoryService _categoryService = CategoryService();

  // final Supplierservice _supplierservice = Supplierservice();

  String? _selectedCategoryId;
  String? _slectedSupplierId;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.prodModel.productName ?? "";

    _quantityController.text = widget.prodModel.productQty?.toString() ?? "";

    _priceController.text = widget.prodModel.productPrice?.toString() ?? "";

    // existing category selected
    _selectedCategoryId = widget.prodModel.categoryId;

    _slectedSupplierId = widget.prodModel.selectedSupplierId;
  }

  @override
  void dispose() {
    _nameController.dispose();

    _quantityController.dispose();

    _priceController.dispose();

    super.dispose();
  }

  Future<void> updateFireStore(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection("Product")
          .doc(product.id)
          .update(product.toMap());

      print("Update successful");
    } catch (e) {
      print("Update failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Product Details",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Product Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Product Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // CATEGORY DROPDOWN

            StreamBuilder<List<CategoryModel>>(
              stream: _categoryService.fetchCategory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                  );
                }

                final categories = snapshot.data ?? [];

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(
                        category.categoryName ?? "",
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            StreamBuilder(
              stream: Supplierservice().fetchSupplier(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error while fetching supplier ?");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                List<SupplierModel> suppliers = snapshot.data!;

                return DropdownButtonFormField(
                  value: _slectedSupplierId,
                  items: suppliers.map((suppliers) {
                    return DropdownMenuItem(
                        value: suppliers.id,
                        child: Text(suppliers.supplierName ?? "No data found"));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _slectedSupplierId = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "Supplier",
                      hintText: "Choose Supplier",
                      border: OutlineInputBorder()),
                );
              },
            ),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (_selectedCategoryId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select category",
                              ),
                            ),
                          );

                          return;
                        }

                        final categories =
                            await _categoryService.fetchCategory().first;

                        final selectedCategory = categories.firstWhere(
                          (cat) => cat.id == _selectedCategoryId,
                        );

                        ProductModel updatedProduct = ProductModel(
                          id: widget.prodModel.id,
                          productName: _nameController.text.trim(),
                          productQty:
                              int.tryParse(_quantityController.text) ?? 0,
                          productPrice:
                              double.tryParse(_priceController.text) ?? 0.0,
                          categoryId: selectedCategory.id,
                          // categoryName: selectedCategory.categoryName,
                        );

                        await updateFireStore(updatedProduct);

                        if (!mounted) return;

                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Update",
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
