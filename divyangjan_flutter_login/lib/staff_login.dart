import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
      fontFamily: 'InriaSans'
  ),
  home: StaffPage(),
));

class StaffPage extends StatelessWidget {
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
              child: Image.asset(
                'assets/tr_railway_logo.png',
                 fit: BoxFit.contain,
              ),
            ),title: Column(
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
          ),
        ),
      ),


      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Space below the AppBar
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - kToolbarHeight - 20,
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
                  Text(
                    'ADMIN/STAFF LOGIN',
                    style: TextStyle(
                      fontFamily: 'InriaSans',

                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:Colors.black87,
                    ),

                  ),

                  SizedBox(height: 20.0),

                  Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    padding: EdgeInsets.fromLTRB(10.0,1.0,10.0,10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 181, 74, 226),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'STAFF-ID/HRMS-ID * ',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),

                  SizedBox(height: 20.0),

                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {

                        print('Get OTP pressed');
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
                      child: Text(
                        'GET OTP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.0),

                  Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    padding: EdgeInsets.fromLTRB(10.0,1.0,10.0,10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 181, 74, 226),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'OTP * ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  SizedBox(height: 20.0),

                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {

                        print('login now');
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
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.0),

                  Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '(*)Timings',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF003BFF),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '8:00 AM - 8:00 PM',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),



                        Container(
                          width: 100,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print("SSO tapped");
                                    // important :: Navigator.push(context, MaterialPageRoute(builder: (_) => StaffLoginPage()));
                                  },
                                  child: Text(
                                    'SSO',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003BFF),

                                    ),
                                  ),
                                ),

                              ]),
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