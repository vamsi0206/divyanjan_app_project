import 'package:flutter/material.dart';
import 'level2userdashboard.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(fontFamily: 'InriaSans'),
    home: CmiHomePage(),
  ),
);

class WhitePage extends StatelessWidget {
  final String title;

  const WhitePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.deepPurple, title: Text(title)),
      body: Center(
        child: Text(
          '$title Page',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}

class CmiHomePage extends StatefulWidget {
  @override
  _CmiHomePageState createState() => _CmiHomePageState();
}

class _CmiHomePageState extends State<CmiHomePage> {
  bool isButtonEnabled = true;

  Widget _buildDashboardButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 45,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 220, 169, 239),
          foregroundColor: Colors.black,
          elevation: 9.0,
          shadowColor: Colors.grey.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.1,
          ),
        ),
      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "MENU OPTIONS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal[900],
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDashboardButton("A. CMI DASHBOARD", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CmiPage(),
                            ),
                          );
                        }),
                        SizedBox(height: 20),
                        _buildDashboardButton("B. CMI REPORTS", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WhitePage(title: "B. CMI REPORTS"),
                            ),
                          );
                        }),
                        SizedBox(height: 20),
                        _buildDashboardButton("C. CMI SUMMARY REPORT", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WhitePage(title: "C. CMI SUMMARY REPORT"),
                            ),
                          );
                        }),
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
