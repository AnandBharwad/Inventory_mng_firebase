import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/screen/fd_productDisplayScreen.dart';

class FbProductviewscreen extends StatefulWidget {
  const FbProductviewscreen({super.key});

  @override
  State<FbProductviewscreen> createState() => _FbProductviewscreenState();
}

class _FbProductviewscreenState extends State<FbProductviewscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onDoubleTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FbProductDisplayScreen(product: product))),
                  child: Card(
                    child: ListTile(
                      title: Text(product.productName!),
                      subtitle: Text(product.productPrice!.toString()),
                      trailing: Text(product.productQty!.toString()),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
