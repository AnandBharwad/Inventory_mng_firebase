import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/screen/fb_addCategory.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: Column(
            children: [
              _buildHeaderSection(),
              //  _AnalyticsSection(),
              _buildQuickActionSection(context)
            ],
          ),
        ),
      )),
    );
  }
}

Widget _buildHeaderSection() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF303BCB),
          Color(0xFF4C3FE5),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.menu),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.4),
              child: Icon(Icons.person),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good Morning",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Ravi Sharma 👋",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.white.withOpacity(0.4)),
                    child: Text("Store Manager"),
                  )
                ],
              )),
        ),
        Row(
          spacing: 3,
          children: [
            _numSection(
                title: "Total Products", value: 128, subTitle: "+12 this week"),
            _numSection(
                title: "Total Products", value: 128, subTitle: "+12 this week"),
            _numSection(
                title: "Total Products", value: 128, subTitle: "+12 this week"),
          ],
        )
      ],
    ),
  );
}

Widget _numSection(
    {required String title, required num value, required String subTitle}) {
  return Expanded(
    child: Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: Colors.white.withOpacity(0.7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            subTitle,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    ),
  );
}
// Widget _AnalyticsSection() {
//   return;
// }

Widget _buildQuickActionSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(
          height: 12,
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 24,
          childAspectRatio: 1,
          children: [
            _actionCard(
                icon: Icons.category_outlined,
                mytext: 'Edit\nCategories',
                mycolor: const Color(0xFFFF5252),
                onTapFun: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FbAddcategory(),
                      ));
                }),
            _actionCard(
              icon: Icons.add_box_outlined,
              mytext: "Add\nProduct",
              mycolor: const Color(0xFF4285F4),
              onTapFun: () {},
            ),
            _actionCard(
              icon: Icons.inventory_2_outlined,
              mytext: "View\nProducts",
              mycolor: const Color(0xFF32A852),
              onTapFun: () {},
            ),
            _actionCard(
              icon: Icons.category,
              mytext: "View\nCategory",
              mycolor: const Color(0xFF3984F7),
              onTapFun: () {},
            ),
            _actionCard(
              icon: Icons.person_add_alt_1,
              mytext: "Add\nSupplier",
              mycolor: const Color(0xFFFF7043),
              onTapFun: () {},
            ),
            _actionCard(
              icon: Icons.bar_chart_rounded,
              mytext: "Stock\nScreen",
              mycolor: const Color(0xFF6C4CEB),
              onTapFun: () {},
            )
          ],
        )
      ],
    ),
  );
}

Widget _actionCard(
    {required IconData icon,
    required String mytext,
    required Color mycolor,
    required VoidCallback onTapFun}) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTapFun,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          spacing: 6.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 46,
                width: 46,
                // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 24, color: mycolor)),
            Text(
              mytext,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16, height: 1),
            )
          ],
        ),
      ),
    ),
  );
}
