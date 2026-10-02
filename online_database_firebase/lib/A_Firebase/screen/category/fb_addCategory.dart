import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/category_model.dart';
import 'package:online_database_firebase/A_Firebase/service/category_service.dart';

class FbAddcategory extends StatefulWidget {
  const FbAddcategory({super.key});

  @override
  State<FbAddcategory> createState() => _FbAddcategory();
}

class _FbAddcategory extends State<FbAddcategory> {
  final TextEditingController _categoryNameController = TextEditingController();

  final CategoryService _categoryService = CategoryService();

  Future<void> addCategory() async {
    if (_categoryNameController.text.trim().isNotEmpty) {
      try {
        CategoryModel _categoryModel =
            CategoryModel(categoryName: _categoryNameController.text);
        await _categoryService.addCategory(_categoryModel);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${_categoryNameController.text} add Successfully...!"),
          backgroundColor: Colors.green,
        ));

        _categoryNameController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to add Category : $e"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Empty Textfield or invalid input"),
        backgroundColor: Colors.deepOrange,
      ));
    }
  }

  Future<void> deleteCategoryRecord(String id) async {
    try {
      await _categoryService.removeCategory(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Category Deleted Successfully"),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error while Deleting Category : $e")));
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Add Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage("assets/images/add_category.jpg"),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    spacing: 12,
                    children: [
                      TextField(
                        controller: _categoryNameController,
                        decoration: InputDecoration(
                            hintText: "Enter Category Name",
                            labelText: "Category Name",
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 52,
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: ContinuousRectangleBorder(
                                    borderRadius:
                                        BorderRadiusGeometry.circular(9))),
                            onPressed: () {
                              addCategory();
                            },
                            child: Text("Add Category")),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 9,
              children: [
                Container(
                  width: 5,
                  height: 25,
                  decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(12)),
                ),
                Text(
                  "Category Details",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(31, 41, 55, 1),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 9,
            ),
            Expanded(
              child: StreamBuilder<List<CategoryModel>>(
                  stream: _categoryService.fetchCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error : ${snapshot.error}"),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No Categoriess Found"),
                      );
                    }

                    final categoryList = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: ListTile(
                              title: Text(categoryList[index].categoryName ??
                                  "No Name"),
                              subtitle: Text(categoryList[index].id ?? "No Id"),
                              trailing: IconButton(
                                  onPressed: () async {
                                    bool? isDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Delete Category !"),
                                          content: Text(
                                              "Do you want to delete ${categoryList[index].categoryName}"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: Text("Cancel")),
                                            ElevatedButton(
                                                onPressed: ()  {
                                                  Navigator.pop(context, true);
                                                },
                                                child: Text("Delete"))
                                          ],
                                        );
                                      },
                                    );
                                    if (isDelete != true) return;

                                    if (categoryList[index].id != null) {
                                      await deleteCategoryRecord(
                                          categoryList[index].id!);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
