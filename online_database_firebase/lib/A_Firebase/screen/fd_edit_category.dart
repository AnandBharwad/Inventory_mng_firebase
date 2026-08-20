import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/service/category_service.dart';

class FbEditCategory extends StatefulWidget {
  const FbEditCategory({super.key});

  @override
  State<FbEditCategory> createState() => _FbEditCategory();
}

class _FbEditCategory extends State<FbEditCategory> {
  CategoryService _categoryService = CategoryService();

  // String? _selectedCategoryId;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check and Delete Categories "),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text("Category"),
          Expanded(
            child: StreamBuilder(
                stream: _categoryService.fetchCategory(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error : ${snapshot.hasError}"),
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

                  if (snapshot.hasData) {
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
                                    await deleteCategoryRecord(
                                        categoryList[index].id!);
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
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          )
        ],
      ),
    );
  }
}
