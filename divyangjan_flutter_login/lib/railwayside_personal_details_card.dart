import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';

class PersonalDetailsCard extends StatefulWidget {
  const PersonalDetailsCard({super.key});

  @override
  State<PersonalDetailsCard> createState() => _PersonalDetailsCardState();
}

class _PersonalDetailsCardState extends State<PersonalDetailsCard> {

  Map<String,String> _details={};
  bool _isLoading=true;
  String _errorMessage='';


  final Map<String,String> _labelMapping={
    'name': 'Name',
    'gender': 'Gender',
    'disability_type_id': 'Disability',
    'email_id': 'Email ID',
    'mobile_number': 'Mobile Number',
  };
  @override
  void initState() {
    super.initState();
    _fetchPersonalDetails();
  }

  Future<void> _fetchPersonalDetails() async {
    try{
      final url = Uri.parse('http://172.20.10.2:3000/updateUserApplication/${UserSession().selectedApplicantId}');
      // final url = Uri.parse('https://mocki.io/v1/b4a010ab-a59c-4a5d-95cb-fc0596067385');
      final response = await http.get(
        url,
      );

      if(response.statusCode==200) {
        final data = json.decode(response.body);
        final Map<String, String> fetched = {};
        _labelMapping.forEach((key, label) {
          final rawValue = data[key];
          final String value = (rawValue == null || rawValue == false ||
              rawValue == '') ? '' : rawValue.toString();
          fetched[label] = value;
        });

        setState(() {
          _details = fetched;
          _isLoading = false;
          _errorMessage = '';
        });
      }else{
        setState((){
          _errorMessage='Error: ${response.statusCode}';
          _isLoading=false;
        });
      }
    } catch (e) {
      // If network fails or something crashes
      setState(() {
        _errorMessage = 'Network Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)));
    }

    if (_details.isEmpty) {
      return const Center(child: Text('No personal details available.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children:[
          Row(
            children:[
              Icon(Icons.person,color:Colors.teal),
              SizedBox(width:8),
              Text(
                'Personal Details',
                style:TextStyle(
                    fontSize:18,
                    fontWeight:FontWeight.bold,
                    fontFamily:'InriaSans',
                    color:Colors.teal.shade800
                ),
              ),
            ],
          ),
          SizedBox(height:10),
          Container(
            width:double.infinity,
            padding:const EdgeInsets.symmetric(vertical:16,horizontal:12),
            decoration:BoxDecoration(
              border:Border.all(color:Colors.purple.shade200,width:1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child:Column(
              crossAxisAlignment:CrossAxisAlignment.start,
              children:_details.entries.map((entry){
                return Padding(
                  padding:const EdgeInsets.symmetric(vertical:6.0),
                  child:Row(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children:[
                      SizedBox(
                        width:120,
                        child:Text(
                          '${entry.key}:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InriaSans',
                            fontSize: 14,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontFamily: 'InriaSans',
                            fontSize: 14,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
