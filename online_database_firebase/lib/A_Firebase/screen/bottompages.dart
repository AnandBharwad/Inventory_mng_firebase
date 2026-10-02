import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/screen/HomeScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_user_profile.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_navProductListScreen.dart';
import 'package:online_database_firebase/A_Firebase/screen/product/fb_productList_screen.dart';

class Bottompages extends StatefulWidget {
  const Bottompages({super.key});

  @override
  State<Bottompages> createState() => BottompagesState();
}

class BottompagesState extends State<Bottompages> {
  int currentIndex = 0;

  List<Widget> pages = [
    Homescreen(),
    FbNavProductListScreen(),
    FbUserProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: pages[currentIndex],
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home"),
            NavigationDestination(
                icon: Icon(Icons.donut_small_outlined),
                selectedIcon: Icon(Icons.donut_small),
                label: "Products"),
            NavigationDestination(
                icon: Icon(Icons.account_box_outlined),
                selectedIcon: Icon(Icons.account_box),
                label: "Profile")
          ]),
    );
  }
}
