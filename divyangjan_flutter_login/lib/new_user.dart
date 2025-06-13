import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() => runApp(MaterialApp(
  theme: ThemeData(
      fontFamily: 'InriaSans'
  ),
  home: NewUserPage(),
));

class NewUserPage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<NewUserPage> {
  bool isButtonEnabled = false;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _emailController = TextEditingController();






  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _mobileController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);


  }
  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }



  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();



  String selectedGender = 'Male';
  String selectedCategory = '1)Hearing and Speech Impairement Totally Both Afflictions Together';
  bool isConfirmed = false;

  void _tryLogin() {
    if (_formKey.currentState!.validate()) {
      print('Form Submitted');
      print('Name: ${_nameController.text}');
      print('Mobile: ${_mobileController.text}');
      // You can also show a snackbar or navigate to another screen here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form Submitted Successfully ✅')),
      );
    } else {
      print('Form validation failed ❌');
    }
  }

  void _updateButtonState() {
    final isNameValid = _nameController.text.trim().isNotEmpty;
    final isMobileValid = _mobileController.text.trim().length == 10;
    final isPasswordMatching = _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.trim().isNotEmpty;
    final isCheckboxChecked = isConfirmed;
    final isEmailValid = _emailController.text.trim().isNotEmpty;

    setState(() {
      isButtonEnabled = isNameValid && isMobileValid && isCheckboxChecked && isPasswordMatching && isEmailValid;
    });
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
                'assets/tr_railway_logo.png',
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
                tooltip: 'Contact Info',
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child:    SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30),
            child: Form(
              key :_formKey,
              autovalidateMode:AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,

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
                          'New Account Creation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '(All Fields are Mandatory)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Note : Ensure correct entry of Name and Gender. Modification not allowed after registration !!! ',

                          style: TextStyle(
                            fontSize: 13,

                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 10.0),

                        Container(
                          width: 300,
                          //height: 60.0,
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
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Applicant Name * ',

                              ),

                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              ],
                              validator: (value){
                                if(value == null || value.trim().isEmpty){
                                  return 'Name is required';
                                }
                                return null;
                              }

                          ),
                        ),

                        SizedBox(height: 10.0),

                        Container(
                          width: 300,
                          //height: 60.0,
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
                              labelText: 'Mobile Number * ',
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Mobile number is required';
                              } else if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Enter a valid 10-digit number';
                              }
                              return null;


                            },
                          ),
                        ),

                        SizedBox(height: 10.0),

                        Container(
                          width: 300,
                          //height: 60.0,
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
                              labelText: 'Create New Password * ',
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
                          ),
                        ),







                        SizedBox(width: 10.0),

                        Container(
                          width: 300,
                          //height: 60.0,
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
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password * ',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),

                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            keyboardType: TextInputType.text,

                          ),
                        ),


                        SizedBox(height: 6.0),

                        Container(
                          width: 300,
                          //height: 60.0,
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
                            controller: _emailController,

                            decoration: InputDecoration(
                              labelText: 'E-mail Id * ',
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 6.0),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Container(
                                  width: 60,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Gender : ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 6),

                                Container(
                                  width: 90,
                                  height: 30,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    items: ['Male', 'Female','other']
                                        .map((gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment : CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Disability :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 6),

                                Container(
                                  width: 150,
                                  height: 30,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    items: ['1)Hearing and Speech Impairement Totally Both Afflictions Together', '2)Orthopaedically Handicapped/Paraplegic/Patients who cannot travel without an escort', '3)Persons with Blindness (Total absence of sight or as per RlyBoard CC 1 of 2025)', '4)Persons with Intellectual Disability who cannot travel without an escort']
                                        .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value!;
                                      });
                                    },
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 12.0),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),

                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isConfirmed,
                                activeColor: Colors.green,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isConfirmed = value!;
                                  });
                                  _updateButtonState();
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0),


                                  child:Text(
                                    'I confirm that details given above belong to me and hereby state that I have no objection in authenticating my name and mobile number for the purpose of issuing of Divyangjan Concession Card by concerned Railway Authorities. I understand that my personal data will not be used for any other purposes other than issuing of Divyangjan Concession card',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            SizedBox(
                              width: 140,
                              height: 45,
                              child: ElevatedButton(

                                onPressed: isButtonEnabled ? _tryLogin : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isButtonEnabled ? Color(0xFFFFDD00) : Colors.grey[400],
                                  foregroundColor: Colors.black,
                                  elevation: 9.0,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),


                            SizedBox(width: 40),


                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '← Back to',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Home Screen',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}