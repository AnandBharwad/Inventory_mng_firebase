import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_login.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_reg.dart';
import 'package:online_database_firebase/A_Firebase/routes/nav_routes.dart';
import 'package:online_database_firebase/A_Firebase/screen/HomeScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/bottompages.dart';
import 'package:online_database_firebase/A_Firebase/screen/category/fb_addCategory.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_productList_screen.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_addProduct.dart';
import 'package:online_database_firebase/A_Firebase/screen/stock/fb_stockScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/supplier/fb_supplier_addScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_user_profile.dart';
import 'package:online_database_firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: NavRoutes.register,
      routes: {
        NavRoutes.bottomPages: (context) => Bottompages(),
        NavRoutes.newHome: (context) => Homescreen(),
        NavRoutes.register: (context) => FbForm(),
        NavRoutes.login: (context) => FbLogin(),
        // NavRoutes.home: (context) => FbHomescreen(),
        NavRoutes.profile: (context) => FbUserProfile(),
        NavRoutes.addProduct: (context) => FbAddproduct(),
        NavRoutes.addCategory: (context) => FbAddcategory(),
        NavRoutes.addSupplier: (context) => FbSupplierAddscreen(),
        NavRoutes.viewProducts: (context) => FbProductlistScreen(),
        NavRoutes.viewStocks: (context) => FbStockscreen(),
        // NavRoutes.editCategory :(context) => FbEditCategory();
        // NavRoutes.displayProduct: (context) =>
        //     FbProductDisplayScreen(product: product),
      },
      debugShowCheckedModeBanner: false,
      home: FbForm(),
    );
  }
}
