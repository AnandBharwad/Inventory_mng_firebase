import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_login.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_registration.dart';
import 'package:online_database_firebase/A_Firebase/routes/nav_routes.dart';
import 'package:online_database_firebase/A_Firebase/screen/Fb_productList_screen.dart';
import 'package:online_database_firebase/A_Firebase/screen/HomeScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_addCategory.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_addProduct.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_homeScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_stockScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_supplier_addScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_user_profile.dart';
import 'package:online_database_firebase/A_Firebase/screen/fd_edit_category.dart';
import 'package:online_database_firebase/A_Firebase/screen/fd_productDisplayScreen.dart';
import 'package:online_database_firebase/firebase_options.dart';
import 'package:online_database_firebase/A_Firebase/screen/Fb_productList_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: NavRoutes.register,
      routes: {
        // NavRoutes.newHome: (context) => Homescreen(),
        NavRoutes.register: (context) => FbForm(),
        NavRoutes.login: (context) => FbLogin(),
        NavRoutes.home: (context) => FbHomescreen(),
        NavRoutes.profile: (context) => FbUserProfile(),
        NavRoutes.addProduct: (context) => FbAddproduct(),
        NavRoutes.addCategory: (context) => FbAddcategory(),
        NavRoutes.addSupplier :(context) => FbSupplierAddscreen(),
        NavRoutes.viewProducts: (context) => FbProductlistScreen(),
        NavRoutes.viewStocks: (context) => FbStockscreen(),
        NavRoutes.editCategory: (context) => FbEditCategory(),
        // NavRoutes.displayProduct: (context) =>
        //     FbProductDisplayScreen(product: product),
      },
      debugShowCheckedModeBanner: false,
      home: FbForm(),
    );
  }
}
