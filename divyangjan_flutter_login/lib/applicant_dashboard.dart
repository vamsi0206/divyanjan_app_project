import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';
import 'applicant_dashboard_classes.dart';
import 'card_application.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(fontFamily: 'InriaSans'),
  home: ApplicantPage(),
));

class ApplicantPage extends StatefulWidget {
  @override
  _ApplicantPageState createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final applicantId = UserSession().applicant_id;

    if (applicantId == null) {
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    try {
      final url = Uri.parse('http://172.20.10.2:3000/applicantDashboard/${UserSession().applicant_id}');
      final response = await http.get(url);
      print("DEBUG: HTTP status code: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status']?.toString().toLowerCase();
        print("DEBUG: status from backend is: $status (${status.runtimeType})");

        if (status == null || status == 'draft' || status == 'rejected') {
          setState(() {
            _isButtonEnabled = true;
          });
        } else {
          setState(() {
            _isButtonEnabled = false;
          });
        }

      }
    } catch (e) {
      print("Network error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(255, 181, 74, 226),
            centerTitle: true,
            elevation: 0.0,
            leading: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.asset('assets/tr_railway_logo.png', fit: BoxFit.contain),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DIVYANGJAN',
                  style: TextStyle(
                    fontFamily: 'OdorMeanChey',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'CARD APPLICATION',
                  style: TextStyle(
                    fontFamily: 'OdorMeanChey',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
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
                  SizedBox(
                    width: 300,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Concessional button - blind');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFDD00),
                        foregroundColor: Colors.black,
                        elevation: 9.0,
                        shadowColor: Colors.grey.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.download, size: 24, color: Colors.black),
                          SizedBox(width: 45),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Concession Form',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('for Blind',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    width: 300,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Concessional button - disability');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFDD00),
                        foregroundColor: Colors.black,
                        elevation: 9.0,
                        shadowColor: Colors.grey.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.download, size: 24, color: Colors.black),
                          SizedBox(width: 45),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Concession Form',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('for other disability',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Concessionpage()),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFDD00),
                          foregroundColor: Colors.black,
                          elevation: 9.0,
                          shadowColor: Colors.grey.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Click here to Apply',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            Text('for Concession Card',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Text('Applicant Dashboard',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(height: 20.0),
                  ApplicationDetailsTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
