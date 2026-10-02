
class CategoryModel {
  String? id;
  String? categoryName;

  CategoryModel({
    this.id,
    required this.categoryName,
  });

  //Now , convert data into map format
  Map<String, dynamic> toMap() {
    return {
      "categoryName": categoryName,
    };
  }

  //when we fetch records from firebase it will return records in map format
  //but we  have to convert into product object.

  factory CategoryModel.fromJson(Map<String, dynamic> map, String documentId) {
    return CategoryModel(id: documentId,
     categoryName: map["categoryName"] );
  }
}
