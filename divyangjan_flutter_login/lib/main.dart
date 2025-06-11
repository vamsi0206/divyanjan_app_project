import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'new_user.dart';

import 'staff_login.dart';




void main() => runApp(MaterialApp(
  theme: ThemeData(
    fontFamily: 'InriaSans'
  ),
  home: Home(),
));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled = _mobileController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tryLogin() {
    if (_formKey.currentState!.validate()) {
      print('LOGIN successful');
    }
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
              child: Image.asset(
                "assets/tr_railway_logo.png",
                fit: BoxFit.contain,
              ),
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

              )
            ],
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
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'APPLICANT LOGIN',
                      style: TextStyle(
                        fontFamily: 'InriaSans',

                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:Colors.black87,
                      ),

                    ),
                    SizedBox(height: 10),

                    Image.asset('assets/divyangjan_logo.jpg',
                      height: 150,
                      width: 150,
                    ),
                    SizedBox(height: 10),

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
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          labelText: 'Registered Mobile Number * ',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value){
                          if(value == null || value.trim().isEmpty){
                            return 'Please Enter your mobile number';
                          }else if (value.trim().length != 10) {
                            return 'Mobile number must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),



                    SizedBox(height: 10.0),

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
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText:! _isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Enter Your Password * ',
                          suffixIcon:  IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: (){
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),

                        keyboardType: TextInputType.text,
                        validator: (value){
                          if(value == null || value.trim().isEmpty){
                            return 'Please Enter your password';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 10.0),

                    SizedBox(
                      width: 300,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled ? _tryLogin:  null,


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

                    SizedBox(height: 20.0),

                    Container(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => StaffPage()),
                              );
                            },
                            child: Text(
                              'Staff Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF003BFF),

                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => NewUserPage()),
                              );
                            },
                            child: Text(
                              'New User ?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF003BFF),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    SizedBox(height: 20.0),


                    Center(
                      child: GestureDetector(
                        onTap: () {
                          print("user manual tapped");
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => NewUserPage()));
                        },

                        child: Text(
                          'User Manual',
                          style: TextStyle(
                            fontSize: 16,
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
    );
  }
}
