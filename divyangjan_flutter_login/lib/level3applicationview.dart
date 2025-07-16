import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'level3userdashboard.dart';
import 'user_session.dart';
import 'railwayside_personal_details_card.dart';
import 'package:intl/intl.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(fontFamily: 'InriaSans'),
    home: CISCardApproalpage(),
  ),
);

class CISCardApproalpage extends StatefulWidget {
  @override
  _CISCardApprovalState createState() => _CISCardApprovalState();
}

class _CISCardApprovalState extends State<CISCardApproalpage> {

  TextEditingController forwardController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController verifyContoller = TextEditingController();

  late String currentDate;
  int finalAge = 0;

  String? selectStatusType;
  bool isSubmitEnabled = false;

  String? selectedDocumenttype;
  //String? selectStatusType;

  //for table
  // These get filled from the API
  String? issuingCity;
  String? dob;
  String? fatherName;
  String? address;
  String? pinCode;
  String? city;
  String? district;
  String? state;
  String? hospitalName;
  String? doctorName;
  String? certificateDate;
  String? doctorRegNo;
  String? concessionCertNo;
  String? cardvalidfrom;
  String? cardvalidupto;
  String? issuingauthorityname;
  String issuingauthoritydesignation="CIS";
  String? disabilityType;
  String? label;
  String selectedReviewPeriod = '5 Years';
  String? calculatedRenewAfter;

  Map<String, dynamic>? applicantData;
  String? displayedFileName;
  final Map<String, String Function(Map<String, dynamic>)> documentTypeToField = {
    'Conc-Cert': (data) => data['concession_certificate'] ?? "",
    'Disability-Cert': (data) => data['disability_certificate'] ?? "",
    'Address proof': (data) => data['address_proof_upload'] ?? "",
    'DOB proof': (data) => data['dob_proof_upload'] ?? "",
    'ID proof': (data) => data['photoId_proof_upload'] ?? "",
    'photo': (data) => data['photograph'] ?? "",
  };

  bool isSpecialDisability = false;

  final List<String> documents = [
    'Conc-Cert',
    'Disability-Cert',
    'Address proof',
    'DOB proof',
    'ID proof',
    'photo',
  ];

  final List<String> status = ['APPROVE', 'REJECT'];

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(244, 84, 83, 83),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 181, 74, 226),
                ), //Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: items
                      .map(
                        (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoField(String label, [String? value]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label *",
            style: const TextStyle(
              color: Color.fromARGB(244, 84, 83, 83),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            //controller: controller,
            controller: TextEditingController(text: value ?? ""),
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: Color.fromARGB(255, 245, 245, 245), //read only feel
            ),
          ),
        ],
      ),
    );
  }


  void _updateSubmitButtonState() {
    final isFeedbackFilled = feedbackController.text.trim().isNotEmpty;
    final isCommentFilled = commentController.text.trim().isNotEmpty;

    setState(() {
      if (selectStatusType == 'APPROVE') {
        isSubmitEnabled = isFeedbackFilled && isCommentFilled;
      } else if (selectStatusType == 'REJECT') {
        isSubmitEnabled = isCommentFilled; // Feedback optional
      } else {
        isSubmitEnabled = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // forwardController.addListener(_updateSubmitButtonState);
    feedbackController.addListener(_updateSubmitButtonState);
    commentController.addListener(_updateSubmitButtonState);
    verifyContoller.addListener(_updateSubmitButtonState);
    fetchAndSetDataFromApi();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }


  @override
  void dispose() {
    //  forwardController.dispose();
    feedbackController.dispose();
    commentController.dispose();
    verifyContoller.dispose();
    super.dispose();
  }
  String? calculateValidUpto(String validFrom, String renewAfter) {
    final fromDate = DateTime.parse(validFrom);
    if (renewAfter == '5 Years') {
      return DateTime(fromDate.year + 5, fromDate.month, fromDate.day).toIso8601String().split('T').first;
    } else if (renewAfter == '10 Years') {
      return DateTime(fromDate.year + 10, fromDate.month, fromDate.day).toIso8601String().split('T').first;
    } else if (renewAfter == 'lifetime') {
      return DateTime(fromDate.year + 100, fromDate.month, fromDate.day).toIso8601String().split('T').first;
    }
    return null;
  }
  Future<void> fetchAndSetDataFromApi() async {
    try {
      final response = await http.get(
        Uri.parse("http://172.20.10.2:3000/applicantDashboard/${UserSession().selectedApplicantId}"),
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> dataList = jsonBody['data'] ?? [];
        if (dataList.isNotEmpty) {
          final data = dataList[0];
          setState(() {
            applicantData = data;
            issuingCity = data['hospital_city'] ?? "";
            dob = data['date_of_birth'] ?? "";
            fatherName = data['fathers_name'] ?? "";
            address = data['address'] ?? "";
            pinCode = data['pin_code'] ?? "";
            city = data['city'] ?? "";
            district = data['district'] ?? "";
            state = data['statename'] ?? "";
            hospitalName = data['hospital_name'] ?? "";
            doctorName = data['doctor_name'] ?? "";
            certificateDate = data['certificate_issue_date']?.substring(0, 10) ?? "";
            doctorRegNo = data['doctor_reg_no'] ?? "";
            concessionCertNo = data['concession_certificate'] ?? "";
            issuingauthorityname = data['current_processing_employee_name'];
            disabilityType = data['disability_type_id'];
            label = disabilityType;
            if (certificateDate != null && selectedReviewPeriod != null) {
              isSpecialDisability = label != null && [
                "Orthopaedically Handicapped/Paraplegic/Patients who cannot travel without an escort",
                "Persons with Blindness (Total absence of sight or as per RlyBoard CC 1 of 2025)"
              ].contains(label);
              cardvalidfrom=calculateValidFrom(currentDate);
              if (dob != null && dob!.isNotEmpty) {
                finalAge = calculateAge(dob!);
                calculatedRenewAfter = calculateRenewAfter(finalAge, isSpecialDisability);
              }
              if (isSpecialDisability) {
                selectedReviewPeriod = calculatedRenewAfter!;
              }
              cardvalidupto = calculateValidUpto(certificateDate!, selectedReviewPeriod);

            }
          });
          _checkIfFormIsReady();
        }
      } else {
        _setEmptyValues();
      }
    } catch (e) {
      _setEmptyValues();
    }
  }

  int calculateAge(String dob) {
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String? calculateValidFrom(String currentDate){
    final curDate = DateTime.parse(currentDate);
    return DateTime(curDate.year,curDate.month, curDate.day+1).toIso8601String().split('T').first;
  }
  String calculateRenewAfter(int theAge,bool hasSpecialDisability) {
    if (hasSpecialDisability) {
      if (theAge < 25) {
        return '5 Years';
      } else if (theAge <= 35) {
        return '10 Years';
      } else {
        return 'lifetime';
      }
    }else {
      return '5 Years';
    }
  }

  Future<void> _submitForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final String status = selectStatusType ?? "";
    final String feedback = feedbackController.text.trim();
    final String comment = commentController.text.trim();
    final String finalComment = "$feedback | $comment";

    if (status.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Please select a status type')),
      );
      return;
    }

    if (status == 'REJECT' && comment.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Please provide a comment when rejecting')),
      );
      return;
    }

    try {
      final url = Uri.parse('http://172.20.10.2:3000/applicationAction/${UserSession().selectedApplicantId}/action');
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};
      final body = jsonEncode({
      'action': status,
      'comments': finalComment,
      'concession_card_validity': selectedReviewPeriod,
      'card_issue_date': cardvalidfrom,
      'card_issue_valid_till': cardvalidupto,
      });

      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Form submitted successfully')),
        );
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => CisPage()),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _setEmptyValues() {
    setState(() {
      issuingCity = "";
      dob = "";
      fatherName = "";
      address = "";
      pinCode = "";
      city = "";
      district = "";
      state = "";
      hospitalName = "";
      doctorName = "";
      certificateDate = "";
      doctorRegNo = "";
      concessionCertNo = "";
    });
  }

  void _checkIfFormIsReady() {
    if ([
      issuingCity,
      dob,
      fatherName,
      address,
      pinCode,
      city,
      district,
      state,
      hospitalName,
      doctorName,
      certificateDate,
      doctorRegNo,
      concessionCertNo,
      cardvalidfrom,
      cardvalidupto,
      issuingauthorityname,
      issuingauthoritydesignation,
    ].every((field) => field != null && field.isNotEmpty)) {
      setState(() {
        isSubmitEnabled = true;
      });
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
              child: Image.asset('assets/tr_railway_logo.png', fit: BoxFit.contain),
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
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  //height: MediaQuery.of(context).size.height - kToolbarHeight,
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
                    children: [
                      Center(
                        child: Container(
                          width: 500,

                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .grey
                                  .shade300, // //Color.fromARGB(255, 181, 74, 226),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            // SizedBox(height: 20.0),
                            children: [
                              Text(
                                'CARD FINAL APPROVAL & GENERATION',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30.0),
                      PersonalDetailsCard(),
                      //need to implement function of personal details
                      SizedBox(height: 15.0),

                      Center(
                        child: Container(
                          width: 500,

                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            // SizedBox(height: 20.0),
                            children: [
                              Text(
                                'Card Applicant Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8.0),

                      Center(
                        child: Container(
                          width: 400,
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color.fromARGB(255, 181, 74, 226),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),

                              buildInfoField(
                                "Card Issuing city *",
                                issuingCity,
                              ),
                              buildInfoField("Date of Birth *", dob),
                              buildInfoField("Father's Name *", fatherName),
                              buildInfoField("Address *", address),
                              buildInfoField("PIN-CODE *", pinCode),
                              buildInfoField("City *", city),
                              buildInfoField("District *", district),
                              buildInfoField("State *", state),
                              buildInfoField("Hospital Name *", hospitalName),
                              buildInfoField("Name of Doctor*", doctorName),
                              buildInfoField(
                                "Certificate Iss Date *",
                                certificateDate,
                              ),
                              buildInfoField("Doctor Reg No *", doctorRegNo),
                              buildInfoField(
                                "Concession Cert No*",
                                concessionCertNo,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0),

                      Center(
                        child: Container(
                          width: 500,
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            // SizedBox(height: 20.0),
                            children: [
                              Text(
                                'Download Documents of the Applicant ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8.0),

                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: buildDropdown(
                                  label: "DOCUMENT Type *",
                                  value: selectedDocumenttype,
                                  items: documents,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedDocumenttype = val;
                                      if (applicantData != null && val != null) {
                                        displayedFileName = documentTypeToField[val]!(applicantData!);
                                        if (displayedFileName == null || displayedFileName!.isEmpty) {
                                          displayedFileName = "No file found";
                                        }
                                      } else {
                                        displayedFileName = "";
                                      }
                                    });
                                  },

                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "File Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color.fromARGB(244, 84, 83, 83),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Color.fromARGB(255, 181, 74, 226)),
                                        borderRadius: BorderRadius.circular(6),
                                        color: Color.fromARGB(255, 245, 245, 245),
                                      ),
                                      child: Text(
                                        displayedFileName ?? 'Select document to view file name',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(height: 10.0),

                      SizedBox(
                        width: 500, // Set overall width of the button group
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Download Button
                            ElevatedButton.icon(
                              onPressed: () {
                                print('download');
                              },
                              icon: Icon(Icons.download, color: Colors.black),
                              label: Text(
                                "DOWNLOAD",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,

                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),

                            ElevatedButton.icon(
                              onPressed: () {
                                print('view');
                              },
                              icon: Icon(Icons.visibility, color: Colors.black),
                              label: Text(
                                "VIEW",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),

                            SizedBox(width: 8.0),

                            ElevatedButton.icon(
                              onPressed: () {
                              },
                              icon: Icon(Icons.history, color: Colors.black),
                              label: Text(
                                "HISTORY",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                      SizedBox(height: 18.0),

                      Center(
                        child: Container(
                          width: 500,

                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            // SizedBox(height: 20.0),
                            children: [
                              Text(
                                "ACTION TAKEN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 12.0),

                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: buildDropdown(
                                  label: "APPROVE/REJECT *",
                                  value: selectStatusType,
                                  items: status,
                                  onChanged: (val) {
                                    setState(() {
                                      selectStatusType = val;
                                      _updateSubmitButtonState();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "FEEDBACK *",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color.fromARGB(244, 84, 83, 83),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Container(
                                      width: 200,
                                      height: 55,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color.fromARGB(255, 181, 74, 226),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: TextField(
                                        controller: feedbackController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(height: 10.0),

                      TextField(
                        textAlign: TextAlign.center,
                        controller: commentController,
                        // Center the text and placeholder
                        decoration: InputDecoration(
                          hintText: 'Leave a comment', // Placeholder text
                          border: OutlineInputBorder(), // Default border
                          contentPadding: EdgeInsets.all(
                            12,
                          ), // Optional: space inside the box
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 18.0),

                      Center(
                        child: Container(
                          width: 500,

                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            // SizedBox(height: 20.0),
                            children: [
                              Text(
                                "Card Issue Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),

                      Center(
                        child: Container(
                          width: 400,
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color.fromARGB(255, 181, 74, 226),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),

                              buildInfoField("Cert Issue Date *", certificateDate),
                              buildInfoField("Card Valid From *", cardvalidfrom),

                              // Dropdown for Card Review After
                              Text(
                                "Card Renew After *",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),

                              isSpecialDisability
                                  ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  calculatedRenewAfter ?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                                  : DropdownButtonFormField<String>(
                                value: selectedReviewPeriod,
                                items: ['5 Years', '10 Years', 'lifetime']
                                    .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedReviewPeriod = value!;
                                    cardvalidupto = calculateValidUpto(certificateDate ?? "", selectedReviewPeriod);
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),


                              SizedBox(height: 12),


                              buildInfoField("Card Valid Upto *", cardvalidupto),
                              buildInfoField("Issuing Authority Name *", issuingauthorityname),
                              buildInfoField("Issuing Authority Designation *", issuingauthoritydesignation),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(height: 10.0),

                      SizedBox(
                        width: 180,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isSubmitEnabled ? _submitForm : null,
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
                            'SUBMIT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}