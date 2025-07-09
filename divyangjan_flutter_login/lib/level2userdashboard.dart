import 'package:flutter/material.dart';
import 'level1usernavigation.dart';
import 'railwayapplicationsdashboard.dart';


void main() => runApp(
  MaterialApp(
    theme: ThemeData(fontFamily: 'InriaSans'),
    home: CmiPage(),
  ),
);

class CmiPage extends StatefulWidget {
  @override
  State<CmiPage> createState() => _CmiPageState();
}

class _CmiPageState extends State<CmiPage> {
  void _showNavigationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navItem(context, "A. CMI DASHBOARD", null),
          _navItem(
            context,
            "B. CMI REPORTS",
            WhitePage(title: "B. CMI REPORTS"),
          ),
          _navItem(
            context,
            "C. SUMMARY REPORT",
            WhitePage(title: "C. SUMMARY REPORT"),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, Widget? page) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context); // Close bottom sheet

        if (page == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You are already on this page")),
          );
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(255, 181, 74, 226),
            centerTitle: true,
            elevation: 0.0,
            leading: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.asset("assets/rail_logo.png", fit: BoxFit.contain),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DIVYANGJAN',
                  style: TextStyle(
                    fontFamily: 'OdorMeanChey',
                    fontSize: 18,
                    color: Color.fromARGB(255, 254, 255, 254),
                  ),
                ),
                Text(
                  'CARD APPLICATION',
                  style: TextStyle(
                    fontFamily: 'OdorMeanChey',
                    fontSize: 18,
                    color: Color.fromARGB(255, 254, 255, 254),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.phone),
                tooltip: 'contact information',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.teal[900]),
                          onPressed: () {
                            _showNavigationMenu(context);
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Divyangjan CMI Dashboard",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.teal[900],
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: DashboardPage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );

  }
}