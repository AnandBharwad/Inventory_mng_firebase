import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_summary.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  /// Low stock limit threshold (Adjust as needed, e.g., 5 items or less)
  static const int lowStockThreshold = 5;

  /// Stream to compute stock stats in real-time
  Stream<StockSummary> getStockSummaryStream() {
    return _firestore.collection("Product").snapshots().map((snapshot) {
      int totalProducts = snapshot.docs.length;
      
      int inStock = 0;
      int lowStock = 0;
      int outOfStock = 0;

      for (var doc in snapshot.docs) {
        ProductModel product = ProductModel.fromJson(doc.data(), doc.id);
        int qty = product.productQty ?? 0;

        if (qty == 0) {
          outOfStock++;
        } else if (qty <= lowStockThreshold) {
          lowStock++;
        } else {
          inStock++;
        }
      }

      return StockSummary(
        totalProducts: totalProducts,
        inStock: inStock,
        lowStock: lowStock,
        outOfStock: outOfStock,
      );
    });
  }
}
