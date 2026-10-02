import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_model.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_summary.dart';
import 'package:online_database_firebase/A_Firebase/routes/nav_routes.dart';
import 'package:online_database_firebase/A_Firebase/screen/category/fb_addCategory.dart';
import 'package:online_database_firebase/A_Firebase/screen/category/fd_edit_category.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_navProductListScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_productList_screen.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_addProduct.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fd_productDisplayScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/stock/fb_stockInOut.dart';
import 'package:online_database_firebase/A_Firebase/screen/stock/fb_stockScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/supplier/fb_supplier_addScreen.dart';
import 'package:online_database_firebase/A_Firebase/service/dashboard_service.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/service/stock_transaction_service.dart';
import 'package:online_database_firebase/A_Firebase/service/user_service.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String? _userName;
  final UserService _userService = UserService();

  late final Stream<StockSummary> stockSummaryStream;

  Future<void> _loadUserData() async {
    await _userService.fetchUserData();

    setState(() {
      _userName = _userService.getUserName;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loadUserData();
    stockSummaryStream = DashboardService().getStockSummaryStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeaderSection(
                  userName: _userName,
                  context: context,
                  stockSummaryStream: stockSummaryStream),
              //  _AnalyticsSection(),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildQuickActionSection(context),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildRecentTransactionsSection(context),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildRecentProductsSection(),
                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}

Widget _buildHeaderSection(
    {required String? userName,
    required BuildContext context,
    required Stream<StockSummary> stockSummaryStream}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF303BCB),
          Color(0xFF4C3FE5),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
    child: Column(
      children: [
        Row(
          children: [
            // Container(
            //   height: 42,
            //   width: 42,
            //   decoration: BoxDecoration(
            //       color: Colors.white.withOpacity(0.4),
            //       borderRadius: BorderRadius.circular(12)),
            //   child: Icon(Icons.menu),
            // ),
            const Spacer(),
            InkWell(
              onTap: () => Navigator.pushNamed(context, NavRoutes.profile),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withOpacity(0.4),
                child: Icon(Icons.person),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "Helloo",
                  //   style: TextStyle(color: Colors.white, fontSize: 18),
                  // ),
                  _getGreetings(),
                  Text(
                    "${userName?.toUpperCase() ?? "Loading..."} 👋",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.white.withOpacity(0.4)),
                    child: Text("Store Manager"),
                  )
                ],
              )),
        ),
        StreamBuilder<StockSummary>(
          stream: stockSummaryStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Row(
                  spacing: 9,
                  children: [
                    _numSection(
                      myColor: Colors.lightBlue,
                      icon: Icons.inventory_2_outlined,
                      title: "Total Products",
                      value: -1,
                    ),
                    _numSection(
                        myColor: Colors.green,
                        icon: Icons.check_circle_outline_outlined,
                        title: "In Stock",
                        value: -1),
                    _numSection(
                        myColor: Colors.orange,
                        icon: Icons.error_outline_outlined,
                        title: "Low Stock",
                        value: -1),
                    _numSection(
                        myColor: Colors.red,
                        icon: Icons.cancel_outlined,
                        title: "Out of Stock",
                        value: -1)
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                "Error while loading analytics\nError : ${snapshot.error} ",
                style: TextStyle(color: Colors.white),
              );
            }

            final status = snapshot.data ??
                StockSummary(
                    totalProducts: 0, inStock: 0, lowStock: 0, outOfStock: 0);

            return Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Row(
                spacing: 9,
                children: [
                  _numSection(
                    myColor: Colors.lightBlue,
                    icon: Icons.inventory_2_outlined,
                    title: "Total\nProducts",
                    value: status.totalProducts,
                  ),
                  _numSection(
                      myColor: Colors.green,
                      icon: Icons.check_circle_outline_outlined,
                      title: "In\nStock",
                      value: status.inStock),
                  _numSection(
                      myColor: Colors.orange,
                      icon: Icons.error_outline_outlined,
                      title: "Low\nStock",
                      value: status.lowStock),
                  _numSection(
                      myColor: Colors.red,
                      icon: Icons.cancel_outlined,
                      title: "Out of\nStock",
                      value: status.outOfStock)
                ],
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _getGreetings() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return Text(
      "Good Morning 🌄",
      style: TextStyle(color: Colors.white, fontSize: 18),
    );
  } else if (hour < 17) {
    return Text("Good Afternoon ☀️",
        style: TextStyle(color: Colors.white, fontSize: 18));
  } else {
    return Text("Good Evening 🌕",
        style: TextStyle(color: Colors.white, fontSize: 18));
  }
}

Widget _numSection(
    {required Color myColor,
    required IconData icon,
    required String title,
    required int value}) {
  return Expanded(
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: myColor.withOpacity(0.15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: myColor.withOpacity(0.30),
              child: Icon(
                icon,
                color: myColor,
              ),
            ),
            Text(
              value == -1 ? "..." : "$value",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(overflow: TextOverflow.ellipsis, height: 1.2),
            ),
          ],
        ),
      ),
    ),
  );
}
// Widget _AnalyticsSection() {
//   return;
// }

Widget _buildQuickActionSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(
          height: 12,
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 24,
          childAspectRatio: 1,
          children: [
            _actionCard(
                icon: Icons.category_outlined,
                mytext: 'Add/Edit\nCategories',
                mycolor: const Color(0xFFFF5252),
                onTapFun: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => FbAddcategory(),
                  //     ));
                  Navigator.pushNamed(context, NavRoutes.addCategory);
                }),
            _actionCard(
              icon: Icons.add_box_outlined,
              mytext: "Add\nProduct",
              mycolor: const Color(0xFF4285F4),
              onTapFun: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FbAddproduct(),
                    ));
              },
            ),
            _actionCard(
              icon: Icons.person_add_alt_1,
              mytext: "Add\nSupplier",
              mycolor: const Color(0xFFFF7043),
              onTapFun: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FbSupplierAddscreen(),
                    ));
              },
            ),
            _actionCard(
              icon: Icons.inventory_2_outlined,
              mytext: "Edit\nCategory",
              mycolor: const Color(0xFF32A852),
              onTapFun: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FbEditCategoryScreen(),
                    ));
              },
            ),
            _actionCard(
              icon: Icons.bar_chart_rounded,
              mytext: "Stock\nScreen",
              mycolor: const Color(0xFF6C4CEB),
              onTapFun: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FbStockscreen(),
                    ));
              },
            ),
            _actionCard(
              icon: Icons.add_chart_outlined,
              mytext: "Stock\nTransaction",
              mycolor: Colors.deepOrange,
              onTapFun: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FbStockInOutScreeen(),
                  )),
            )
          ],
        )
      ],
    ),
  );
}

Widget _actionCard(
    {required IconData icon,
    required String mytext,
    required Color mycolor,
    required VoidCallback onTapFun}) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 0,
    child: InkWell(
      onTap: onTapFun,
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            spacing: 6.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 48,
                  width: 48,
                  // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                      color: mycolor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, size: 24, color: mycolor)),
              Text(
                mytext,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildRecentTransactionsSection(BuildContext context) {
  final StockTransactionService stockService = StockTransactionService();

  final ProductService productService = ProductService();
  return Padding(
    padding: const EdgeInsets.all(9.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 5,
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(12)),
            ),
            SizedBox(
              width: 9,
            ),
            Text(
              "Recent Transcation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FbStockInOutScreeen(),
                    ));
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "See All",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    Icon(
                      Icons.chevron_right_outlined,
                      size: 18,
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        StreamBuilder<List<StockTransactionModel>>(
          stream: stockService.fetchRecentStockTransaction(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Failed to load transaction : ${snapshot.error}"),
              );
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "No stock transactions recorded yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: 9,
              ),
              itemBuilder: (context, index) {
                final item = transactions[index];

                final isStockIn = item.type.toUpperCase() == "IN";

                return Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(14),
                        side: BorderSide(color: Colors.grey.shade200)),
                    child: ListTile(
                      // contentPadding: ,
                      leading: CircleAvatar(
                        backgroundColor: isStockIn
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        child: Icon(
                          isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isStockIn ? Colors.green : Colors.red,
                        ),
                      ),
                      title: FutureBuilder<String>(
                        future:
                            productService.getProductNameById(item.productId),
                        builder: (context, nameSnapshot) {
                          return Text(
                            nameSnapshot.data ?? "Loading Product...",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      subtitle: Text(
                        "${item.date.day}/${item.date.month}/${item.date.year} at ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isStockIn
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${isStockIn ? '+' : '-'}${item.quantity}",
                          style: TextStyle(
                            color: isStockIn ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ));
              },
            );
          },
        )
      ],
    ),
  );
}

// Location: lib/A_Firebase/screen/HomeScreen.dart

Widget _buildRecentProductsSection() {
  final ProductService productService = ProductService();

  return Padding(
    padding: const EdgeInsets.all(9.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 5,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              "Recently Added Products",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Latest 5",
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Live Stream of Last 5 Products
        StreamBuilder<List<ProductModel>>(
          stream: productService.fetchRecentProducts(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("Failed to load products: ${snapshot.error}"),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "No products added yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final product = products[index];

                return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FbProductDisplayScreen(product: product),
                      )),
                  borderRadius: BorderRadius.circular(3),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.withOpacity(0.12),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.indigo,
                        ),
                      ),
                      title: Text(
                        product.productName ?? "Unnamed Product",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Price: ₹${product.productPrice?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (product.productQty ?? 0) > 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Qty: ${product.productQty ?? 0}",
                          style: TextStyle(
                            color: (product.productQty ?? 0) > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}
