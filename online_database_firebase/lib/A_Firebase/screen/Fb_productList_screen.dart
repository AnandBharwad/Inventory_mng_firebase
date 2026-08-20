import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/routes/nav_routes.dart';
import 'package:online_database_firebase/A_Firebase/screen/fd_ediiScreen.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/screen/fd_productDisplayScreen.dart';

class FbProductlistScreen extends StatefulWidget {
  const FbProductlistScreen({super.key});

  @override
  State<FbProductlistScreen> createState() => _FbProductlistScreen();
}

class _FbProductlistScreen extends State<FbProductlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.4),
      appBar: AppBar(
        title: Text("View products"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ProductModel>>(
          stream: ProductService().fetchProduct(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text("No Products Found"),
              );
            }

            final products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return InkWell(
                  hoverColor: Colors.amber.withOpacity(0.5),
                  onDoubleTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FbProductDisplayScreen(product: product))),
                  child: Card(
                    child: Row(
                      children: [
                        Flexible(
                          child: ListTile(
                            title: Text(product.productName!),
                            subtitle: Text(product.productPrice!.toString()),
                            trailing: Text(product.productQty!.toString()),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (!mounted) return;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => FbEditScreen(
                                            prodModel: product,
                                          )));
                            },
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () async {
                              if (!mounted) return;
                              CircularProgressIndicator();
                              await ProductService()
                                  .deleteProductRecord(product.id);
                            },
                            icon: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
