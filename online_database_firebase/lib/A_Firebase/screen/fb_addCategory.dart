import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/category_model.dart';
import 'package:online_database_firebase/A_Firebase/service/category_service.dart';

class FbAddcategory extends StatefulWidget {
  const FbAddcategory({super.key});

  @override
  State<FbAddcategory> createState() => _FbAddcategory();
}

class _FbAddcategory extends State<FbAddcategory> {
  TextEditingController _categoryNameController = TextEditingController();

  CategoryService _categoryService = CategoryService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage("assets/images/add_category.jpg"),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                  hintText: "Enter Category Name",
                  labelText: "Category Name",
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 55,
            ),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(9))),
                  onPressed: () async {
                    CategoryModel _categoryModel = CategoryModel(
                        categoryName: _categoryNameController.text.toString());
                    await _categoryService.addCategory(_categoryModel);
                  },
                  child: Text("Add Category")),
            )
          ],
        ),
      ),
    );
  }
}
