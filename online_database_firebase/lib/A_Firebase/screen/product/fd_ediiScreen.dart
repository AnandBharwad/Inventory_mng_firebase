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

  final Supplierservice _supplierservice = Supplierservice();

  String? _selectedCategoryId;
  String? _selectedSupplierId;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.prodModel.productName ?? "";

    _quantityController.text = widget.prodModel.productQty?.toString() ?? "";

    _priceController.text = widget.prodModel.productPrice?.toString() ?? "";

    // existing category selected
    _selectedCategoryId = widget.prodModel.categoryId;

    _selectedSupplierId = widget.prodModel.supplierId;
  }

  @override
  void dispose() {
    _nameController.dispose();

    _quantityController.dispose();

    _priceController.dispose();

    super.dispose();
  }

  Future<bool> updateFireStore(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection("Product")
          .doc(product.id)
          .update(product.toMap());

      debugPrint("Update Successfull");
      return true;
    } catch (e) {
      debugPrint("Update failed: $e");

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Update Failed : $e")));
      }

      return false;
    }
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter product name")));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Select Category")));
      return;
    }

    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Select Supplier ")));
      return;
    }

    final int? quantity = int.tryParse(_quantityController.text.trim());

    final double? price = double.tryParse(_priceController.text.toString());

    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Enter Valid Quantity")));
      return;
    }

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Enter Valid  price")));
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final ProductModel updatedProduct = ProductModel(
        id: widget.prodModel.id,
        productName: _nameController.text.trim(),
        productQty: quantity,
        productPrice: price,
        categoryId: _selectedCategoryId,
        supplierId: _selectedSupplierId);

    final bool success = await updateFireStore(updatedProduct);

    if (!mounted) return;

    setState(() {
      _isUpdating = false;
    });

    if (success) {
      Navigator.pop(context, updatedProduct);
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
                    "Category Error : ${snapshot.error}",
                  );
                }

                final categories = snapshot.data ?? [];

                //prevent dropedown assertion if old category no longer exists.
                final categoryExists = categories
                    .any((category) => category.id == _selectedCategoryId);

                final String? validCategoryId =
                    categoryExists ? _selectedCategoryId : null;

                return DropdownButtonFormField<String>(
                  value: validCategoryId,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    hintText: "Choose Category",
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(
                        category.categoryName ?? "No Category Name",
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Supplier Error : ${snapshot.hasError}");
                }

                final suppliers = snapshot.data ?? [];

//prevent dropdown assertion if old supplier no longer exists.
                final supplierExits = suppliers
                    .any((supplier) => supplier.id == _selectedSupplierId);

                final String? validSupplierId =
                    supplierExits ? _selectedSupplierId : null;

                // List<SupplierModel> suppliers = snapshot.data!;

                return DropdownButtonFormField(
                  value: validSupplierId,
                  items: suppliers.map((suppliers) {
                    return DropdownMenuItem(
                        value: suppliers.id,
                        child: Text(suppliers.supplierName ?? "No data found"));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "Supplier",
                      hintText: "Choose Supplier",
                      border: OutlineInputBorder()),
                );
              },
            ),

            SizedBox(
              height: 30,
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
                      onPressed: () {
                        _isUpdating ? null : _updateProduct();
                        // if (_selectedCategoryId == null) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       content: Text(
                        //         "Please select category",
                        //       ),
                        //     ),
                        //   );

                        //   return;
                        // }

                        // // final categories =
                        // //     await _categoryService.fetchCategory().first;

                        // // final selectedCategory = categories.firstWhere(
                        // //   (cat) => cat.id == _selectedCategoryId,
                        // // );

                        // ProductModel updatedProduct = ProductModel(
                        //     id: widget.prodModel.id,
                        //     productName: _nameController.text.trim(),
                        //     productQty:
                        //         int.tryParse(_quantityController.text) ?? 0,
                        //     productPrice:
                        //         double.tryParse(_priceController.text) ?? 0.0,
                        //     categoryId: _selectedCategoryId,
                        //     selectedSupplierId: _selectedSupplierId
                        //     // categoryName: selectedCategory.categoryName,
                        //     );

                        // await updateFireStore(updatedProduct);

                        // if (!mounted) return;

                        // Navigator.pop(context);
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
