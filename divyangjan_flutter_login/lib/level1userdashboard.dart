import 'package:flutter/material.dart';
import 'railwayapplicationsdashboard.dart';
import 'level1usernavigation.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(fontFamily: 'InriaSans'),
    home: DivisonPage(),
  ),
);

class DivisonPage extends StatefulWidget {
  @override
  State<DivisonPage> createState() => _DivisonPageState();
}

class _DivisonPageState extends State<DivisonPage> {
  void _showNavigationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navItem(context, "A. DIVISION DASHBOARD", null),
          _navItem(context, "B. MANUAL REGISTRATION", WhitePage(title: "B. MANUAL REGISTRATION")),
          _navItem(context, "C. DIVISION REPORTS", WhitePage(title: "C. DIVISION REPORTS")),
          _navItem(context, "D. SUMMARY REPORT", WhitePage(title: "D. SUMMARY REPORT")),
          _navItem(context, "E. MODIFY CARD", WhitePage(title: "E. MODIFY CARD")),
          _navItem(context, "F. CHANGE CARD STATUS", WhitePage(title: "F. CHANGE CARD STATUS")),
          _navItem(context, "G. SEARCH CARD DETAILS", WhitePage(title: "G. SEARCH CARD DETAILS")),
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
              child: Image.asset("assets/tr_railway_logo.png", fit: BoxFit.contain),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DIVYANGJAN',
                  style: TextStyle(
                    fontFamily: 'OdorMeanChey',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'CARD APPLICATION',
                  style: TextStyle(
                    fontFamily: 'OdorMeanChey',
                    fontSize: 18,
                    color: Colors.white,
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
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
                        "Divyangjan Division User Dashboard",
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
                ],
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: DashboardPage(),
            ),
          ],
        ),
      ),
    );
  }
}
