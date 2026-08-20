class StockModel {
  String? id;
  String productId;
  String type;
  int quantity;
  DateTime date;

  StockModel(
      {this.id,
      required this.productId,
      required this.type,
      required this.quantity,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "type": type,
      "quantity": quantity,
      "date": date.toIso8601String()
    };
  }

  factory StockModel.fromjson(Map<String, dynamic> map, String documentId) {
    return StockModel(
        id: documentId,
        productId: map["productId"],
        type: map["type"],
        quantity: map["quantity"],
        date: DateTime.parse(map["date"]));
  }
}
