import 'dart:async';

import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/category_model.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fd_ediiScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fd_productDisplayScreen.dart';
import 'package:online_database_firebase/A_Firebase/service/category_service.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';

class FbNavProductListScreen extends StatefulWidget {
  const FbNavProductListScreen({super.key});

  @override
  State<FbNavProductListScreen> createState() => _FbNavProductListScreenState();
}

enum SortOption { nameAsc, priceAsc, priceDesc, stockLow }

class _FbNavProductListScreenState extends State<FbNavProductListScreen> {
  final TextEditingController _searchProductController =
      TextEditingController();

  late Stream<List<CategoryModel>> categoryStream;
  late Stream<List<ProductModel>> productStream;

  bool isListLayout = true;

  Map<String, String> categoryNameMap = {};

  String searchQuery = "";

  String selectedCategoryId = "All";

  SortOption selectedSort = SortOption.nameAsc;

  Future<String> getCategoryName(String? categoryId) async {
    if (categoryId == null || categoryId.trim().isEmpty) {
      return "General";
    }

    if (categoryNameMap.containsKey(categoryId)) {
      return categoryNameMap[categoryId]!;
    }

    String categoryName =
        await CategoryService().fetchCategoryNameById(categoryId);

    categoryNameMap[categoryId] = categoryName;

    return categoryName;
  }

  @override
  void initState() {
    super.initState();

    categoryStream = CategoryService().fetchCategory();
    productStream = ProductService().fetchProduct();
  }

  @override
  void dispose() {
    _searchProductController.dispose();
    super.dispose();
  }

  void changeLayout() {
    setState(() {
      isListLayout = !isListLayout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 248, 250),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 16),
              _buildCategorySection(context),
              const SizedBox(height: 16),
              Expanded(
                child: _buildProductSection(context, isListLayout),
              ),
            ],
          ),
        ),
      ),
    );
  }

// APP BAR
  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(23, 32, 51, 1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your inventory items',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SEARCH
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchProductController,
      onChanged: (value) {
        setState(() {
          searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search products by name...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffix: _searchProductController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchProductController.clear();
                  setState(() {
                    searchQuery = "";
                  });
                },
                icon: Icon(Icons.clear, color: Colors.redAccent),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        constraints: BoxConstraints(minHeight: 0, minWidth: 0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
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
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // CATEGORY SECTION
  Widget _buildCategorySection(BuildContext context) {
    return SizedBox(
      height: 40,
      child: StreamBuilder<List<CategoryModel>>(
        stream: categoryStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorMessage(
              'Unable to load categories',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyMessage(
              'No categories found',
            );
          }

          final categories = snapshot.data!;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              //Index 0 means "All" categorychip
              if (index == 0) {
                final bool isAllSelected = selectedCategoryId == "All";

                return _buildChip(
                  label: "All",
                  isSelected: isAllSelected,
                  onTap: () {
                    setState(() {
                      selectedCategoryId = "All";
                    });
                  },
                );
              }

              final category = categories[index - 1];
              final bool isSelected = selectedCategoryId == category.id;

              return _buildChip(
                label: category.categoryName ?? "Unknown",
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedCategoryId =
                        isSelected ? "All" : (category.id ?? "All");
                  });
                },
              );
              // return _buildCategoryChip(
              //   context,
              //   categories[index],
              // );
            },
          );
        },
      ),
    );
  }

  Widget _buildChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected ? Colors.indigo : Colors.grey.shade300)),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    CategoryModel category,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          category.categoryName ?? 'Unknown',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // PRODUCT SECTION
  Widget _buildProductSection(BuildContext context, bool isListLayout) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProductHeader(context, isListLayout),
          const Divider(height: 1),
          isListLayout
              ? Expanded(
                  child: _buildProductList(context),
                )
              : Expanded(
                  child: _buildProductGrid(context),
                )
        ],
      ),
    );
  }

  // PRODUCT HEADER
  Widget _buildProductHeader(BuildContext context, bool isListLayout) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              _showSortBottomSheet(context);
            },
            icon: const Icon(
              Icons.sort,
              size: 18,
            ),
            label: Text("Sort"),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => changeLayout(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isListLayout ? Colors.indigo : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.view_list_rounded,
                      size: 18,
                      color: isListLayout ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => changeLayout(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isListLayout ? Colors.transparent : Colors.indigo,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 18,
                      color: isListLayout ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  //filter option by showing Bottomsheet
  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: 10,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12)),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Sort Products By",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 12,
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text("Name (A to Z)"),
              selected: selectedSort == SortOption.nameAsc,
              onTap: () {
                setState(() {
                  selectedSort = SortOption.nameAsc;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text("Price (Low to High)"),
              selected: selectedSort == SortOption.priceAsc,
              onTap: () {
                setState(() {
                  selectedSort = SortOption.priceAsc;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text("Price (High to Low)"),
              selected: selectedSort == SortOption.priceDesc,
              onTap: () {
                setState(() {
                  selectedSort = SortOption.priceDesc;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.warning_amber_rounded),
              title: const Text("Low Stock First"),
              selected: selectedSort == SortOption.stockLow,
              onTap: () {
                setState(() {
                  selectedSort = SortOption.stockLow;
                  Navigator.pop(context);
                });
              },
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.redAccent,
                  )),
            )
          ],
        );
      },
    );
  }

  // PRODUCT LIST
  Widget _buildProductList(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: productStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorMessage(
            'Unable to load products',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyMessage(
            'No products found',
          );
        }

        final allProducts = snapshot.data!;

        final products = allProducts.where(
          (product) {
            final name = product.productName?.toLowerCase() ?? '';
            final matchSearch =
                searchQuery.isEmpty || name.contains(searchQuery);

            final matchCategory = selectedCategoryId == "All" ||
                product.categoryId == selectedCategoryId;

            return matchSearch && matchCategory;
          },
        ).toList();

        switch (selectedSort) {
          case SortOption.nameAsc:
            products.sort(
                (a, b) => (a.productName ?? '').compareTo(b.productName ?? ''));
            break;

          case SortOption.priceAsc:
            products.sort(
                (a, b) => (a.productPrice ?? 0).compareTo(b.productPrice ?? 0));
            break;

          case SortOption.priceDesc:
            products.sort(
                (a, b) => (b.productPrice ?? 0).compareTo(a.productPrice ?? 0));
            break;
          case SortOption.stockLow:
            products.sort(
                (a, b) => (a.productQty ?? 0).compareTo(b.productQty ?? 0));
            break;
        }
        if (products.isEmpty) {
          return _buildEmptyMessage(searchQuery.isNotEmpty
              ? 'No Products Found Matching "$searchQuery"'
              : 'No Products In This Category');
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                4,
              ),
              child: Row(
                children: [
                  Text(
                    '${products.length} products',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        color: Colors.grey.shade500,
                        size: 18,
                      ),
                      Text(
                        "Double tap to see info of Product",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: getCategoryName(products[index].categoryId),
                      builder: (context, categoryNameSnapshot) {
                        final categoryName =
                            categoryNameSnapshot.data ?? "Loading...";

                        return _buildProductCard(
                            context, products[index], categoryName);
                      });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // PRODUCT CARD
  Widget _buildProductCard(
      BuildContext context, ProductModel product, String categoryName) {
    return InkWell(
      onDoubleTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FbProductDisplayScreen(product: product),
          )),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // Product image placeholder
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(width: 14),

            // Product information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? 'Unnamed Product',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${product.productPrice ?? '--'}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.indigo.withOpacity(0.3))),
                    child: Text(
                      "${categoryName}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStockBedge(product.productQty),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      if (!mounted) {
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FbEditScreen(prodModel: product),
                          ));
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.green,
                    )),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Product"),
                          content: Text(
                              "Are you sure you want to delete '${product.productName}'?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () async {
                                if (product.id != null) {
                                  await ProductService()
                                      .deleteProductRecord(product.id!);
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: productStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorMessage("Unable to load product");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyMessage("No Products Found");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.indigo,
            ),
          );
        }

        List<ProductModel> allProducts = snapshot.data!;

        List<ProductModel> products = allProducts.where(
          (product) {
            final name = product.productName?.toLowerCase() ?? "";
            final matchSearch =
                searchQuery.isEmpty || name.contains(searchQuery);

            final matchCategory = selectedCategoryId == "All" ||
                product.categoryId == selectedCategoryId;
            return matchSearch && matchCategory;
            // return name.contains(searchQuery);
          },
        ).toList();

        if (products.isEmpty) {
          return _buildEmptyMessage(searchQuery.isNotEmpty
              ? 'No Products Found Matching "$searchQuery"'
              : 'No Products In This Category');
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 04),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${products.length} products",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.66,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0),
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: getCategoryName(products[index].categoryId),
                      builder: (context, categoryNameSnapshot) {
                        var categoryName =
                            categoryNameSnapshot.data ?? "Loading...";
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.indigo.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Center(
                                        child: Icon(
                                          Icons.inventory_2_outlined,
                                          color: Colors.indigo,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: _buildStockBedge(
                                            products[index].productQty),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  products[index].productName ?? "Unknown",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "₹${products[index].productPrice!.toString()}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 3),
                                  decoration: BoxDecoration(
                                      color: Colors.indigo.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              Colors.indigo.withOpacity(0.3))),
                                  child: Text(
                                    "${categoryName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FbProductDisplayScreen(
                                                          product:
                                                              products[index]),
                                                ));
                                          },
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Colors.lightBlue,
                                            semanticLabel: "Info",
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FbEditScreen(
                                                          prodModel:
                                                              products[index]),
                                                ));
                                          },
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: Colors.green,
                                            semanticLabel: "Edit",
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    "Delete Product"),
                                                content: Text(
                                                    "Are you sure you want to delete '${products[index].productName}'?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                    onPressed: () async {
                                                      if (products[index].id !=
                                                          null) {
                                                        await ProductService()
                                                            .deleteProductRecord(
                                                                products[index]
                                                                    .id!);
                                                      }
                                                      if (context.mounted)
                                                        Navigator.pop(context);
                                                    },
                                                    child: const Text("Delete",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            semanticLabel: "Delete",
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStockBedge(int? qauntity) {
    final int qty = qauntity ?? 0;

    String text;
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (qty == 0) {
      text = "Out Stock";
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      borderColor = Colors.red.shade200;
    } else if (qty <= 5) {
      text = "Low Stock";
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      borderColor = Colors.orange.shade200;
    } else {
      text = "In Stock";
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      borderColor = Colors.green.shade200;
    }

    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    //   decoration: BoxDecoration(
    //     color: bgColor,
    //     borderRadius: BorderRadius.circular(6),
    //     border: Border.all(color: borderColor),
    //   ),
    //   child: Text(
    //     text,
    //     style: TextStyle(
    //       fontSize: 11,
    //       fontWeight: FontWeight.w600,
    //       color: textColor,
    //     ),
    //   ),
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        Text(
          qty.toString(),
          style: TextStyle(
              color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "Units",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
        )
      ],
    );
  }

  // STATES
  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
