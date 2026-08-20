import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/model/supplierModel.dart';
import 'package:online_database_firebase/A_Firebase/service/supplierService.dart';

class FbSupplierAddscreen extends StatefulWidget {
  const FbSupplierAddscreen({super.key});

  @override
  State<FbSupplierAddscreen> createState() => _FbSupplierAddscreenState();
}

class _FbSupplierAddscreenState extends State<FbSupplierAddscreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  Supplierservice _supplierservice = Supplierservice();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> addSupplier() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String contact = _contactController.text.trim();

    SupplierModel supplier = SupplierModel(
      supplierName: name,
      email: email,
      contact: contact,
    );

    try {
      await _supplierservice.addSupplier(supplier);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Supplier added successfully"),
        ),
      );

      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Supplier"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(
          spacing: 9,
          children: [
            Container(
                height: 100,
                width: 100,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: Image.asset("assets/images/add_supplier.webp")),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: "Enter Supplier Name",
                    labelText: "Supplier Name",
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Fill this field";
                  }
                },
              ),
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                  hintText: "Enter Supplier Contact Number",
                  labelText: "Supplier Contact Number",
                  border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Fill this field";
                }
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                  hintText: "Enter Email",
                  labelText: "Supplier Email",
                  border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Fill this field";
                }
              },
            ),
            SizedBox(
              height: 10,
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addSupplier();
                    } else {
                      return;
                    }
                  },
                  child: Text("Add Supplier")),
            )
          ],
        ),
      ),
    );
  }
}
