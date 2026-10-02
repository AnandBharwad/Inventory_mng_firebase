import 'package:flutter/material.dart';

import 'package:online_database_firebase/A_Firebase/model/category_model.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/model/supplierModel.dart';

import 'package:online_database_firebase/A_Firebase/service/category_service.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/service/supplierService.dart';

class FbAddproduct extends StatefulWidget {
  const FbAddproduct({super.key});

  @override
  State<FbAddproduct> createState() => _FbAddproductState();
}

class _FbAddproductState extends State<FbAddproduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final Supplierservice _supplierService = Supplierservice();

  String? _selectedCategoryId;
  String? _selectedSupplierId;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: Colors.indigo,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.indigo,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final int quantity = int.parse(
        _qtyController.text.trim(),
      );

      final double price = double.parse(
        _priceController.text.trim(),
      );

      final ProductModel product = ProductModel(
        productName: _nameController.text.trim(),
        productQty: quantity,
        productPrice: price,
        categoryId: _selectedCategoryId,
        supplierId: _selectedSupplierId,
      );

      await _productService.addProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Product Added Successfully"),
            behavior: SnackBarBehavior.floating,
          ),
        );

      _nameController.clear();
      _qtyController.clear();
      _priceController.clear();

      setState(() {
        _selectedCategoryId = null;
        _selectedSupplierId = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Error adding product: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Add New Product",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // PRODUCT NAME
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration(
                    label: "Product Name",
                    hint: "Enter Product Name",
                    icon: Icons.shopping_bag_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Product Name";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // QUANTITY
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration(
                    label: "Quantity",
                    hint: "Enter Quantity",
                    icon: Icons.numbers,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Product Quantity";
                    }

                    final quantity = int.tryParse(
                      value.trim(),
                    );

                    if (quantity == null) {
                      return "Enter a valid quantity";
                    }

                    if (quantity <= 0) {
                      return "Quantity must be greater than 0";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // PRICE
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: inputDecoration(
                    label: "Price",
                    hint: "Enter Price",
                    icon: Icons.currency_rupee,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Product Price";
                    }

                    final price = double.tryParse(
                      value.trim(),
                    );

                    if (price == null) {
                      return "Enter a valid price";
                    }

                    if (price <= 0) {
                      return "Price must be greater than 0";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // CATEGORY DROPDOWN
                StreamBuilder<List<CategoryModel>>(
                  stream: _categoryService.fetchCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        "Category Error: ${snapshot.error}",
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      );
                    }

                    final categories = snapshot.data ?? [];

                    if (categories.isEmpty) {
                      return const Text(
                        "No categories available",
                      );
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      isExpanded: true,
                      decoration: inputDecoration(
                        label: "Category",
                        hint: "Select Category",
                        icon: Icons.category_outlined,
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(
                            category.categoryName ?? "Unknown Category",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Select Category";
                        }

                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 15),

                // SUPPLIER DROPDOWN
                StreamBuilder<List<SupplierModel>>(
                  stream: _supplierService.fetchSupplier(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        "Supplier Error: ${snapshot.error}",
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      );
                    }

                    final suppliers = snapshot.data ?? [];

                    if (suppliers.isEmpty) {
                      return const Text(
                        "No suppliers available",
                      );
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedSupplierId,
                      isExpanded: true,
                      decoration: inputDecoration(
                        label: "Supplier",
                        hint: "Select Supplier",
                        icon: Icons.person_outline,
                      ),
                      items: suppliers.map((supplier) {
                        return DropdownMenuItem<String>(
                          value: supplier.id,
                          child: Text(
                            supplier.supplierName ?? "Unknown Supplier",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplierId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Select Supplier";
                        }

                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Add Product",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
