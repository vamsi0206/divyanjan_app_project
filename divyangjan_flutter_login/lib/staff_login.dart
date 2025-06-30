import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(fontFamily: 'InriaSans'),
  home: StaffPage(),
));

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final _staffIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _staffIdController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      isButtonEnabled = _staffIdController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              child: Image.asset('assets/tr_railway_logo.png', fit: BoxFit.contain),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DIVYANGJAN', style: TextStyle(fontFamily: 'OdorMeanChey', fontSize: 18, color: Colors.white)),
                Text('CARD APPLICATION', style: TextStyle(fontFamily: 'OdorMeanChey', fontSize: 18, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
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
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('ADMIN/STAFF LOGIN',
                      style: TextStyle(
                          fontFamily: 'InriaSans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),

                  SizedBox(height: 20),

                  Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 181, 74, 226), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _staffIdController,
                      decoration: InputDecoration(labelText: 'STAFF-ID/HRMS-ID *'),
                      keyboardType: TextInputType.text,
                    ),
                  ),

                  Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 181, 74, 226), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Your Password *',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () {
                        print('login now');
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFDD00),
                        foregroundColor: Colors.black,
                        elevation: 9.0,
                        shadowColor: Colors.grey.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

                  SizedBox(height: 40),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '(*)Timings',
                                style: TextStyle(fontSize: 16, color: Color(0xFF003BFF)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '8:00 AM - 8:00 PM',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                print("SSO tapped");
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
                          ),
                        ],
                      ),
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
