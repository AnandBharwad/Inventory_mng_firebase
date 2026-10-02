import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_model.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/service/stock_transaction_service.dart';

class FbStockInOutScreeen extends StatefulWidget {
  const FbStockInOutScreeen({super.key});

  @override
  State<FbStockInOutScreeen> createState() => _FbStockInOutScreeenState();
}

class _FbStockInOutScreeenState extends State<FbStockInOutScreeen> {
  late Stream<List<StockTransactionModel>> streamStockTransaction;

  late Map<String, String> productNameMap = {};

  Future<String> _getProductName(String ProductId) async {
    if (productNameMap.containsKey(ProductId)) {
      return productNameMap[ProductId]!;
    }

    final name = await ProductService().getProductNameById(ProductId);

    productNameMap[ProductId] = name;

    return name;
  }

  @override
  void initState() {
    super.initState();
    streamStockTransaction = StockTransactionService().fetchStockTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock In Out History"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<StockTransactionModel>>(
              stream: streamStockTransaction,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error while fetching data"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.08),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 55,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "No Products Found",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Your Products will appear here.",
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      ],
                    ),
                  );
                }

                final mystockTransactions = snapshot.data!;

                return ListView.builder(
                  itemCount: mystockTransactions.length,
                  itemBuilder: (context, index) {
                    //storing index in variable
                    final stock = mystockTransactions[index];
                    bool isIn = stock.type == "IN";

                    return FutureBuilder<String>(
                      future: _getProductName(stock.productId),
                      builder: (context, nameSnapshot) {
                        final productName = nameSnapshot.data ?? "Loading..";

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIn
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            child: Icon(
                              isIn
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              color: isIn ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(productName),
                          subtitle: Text(
                              "Type : ${stock.type} | Qty : ${stock.quantity} | Date : ${stock.date.toLocal().toString().split('.'[0])}"),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
