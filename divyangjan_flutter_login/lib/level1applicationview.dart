import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'railwayside_personal_details_card.dart';
import 'level1userdashboard.dart';
import 'user_session.dart';


void main() => runApp(
  MaterialApp(
    theme: ThemeData(fontFamily: 'InriaSans'),
    home: CardApprovalPage(),
  ),
);

class CardApprovalPage extends StatefulWidget {
  @override
  _CardApprovalState createState() => _CardApprovalState();
}

class _CardApprovalState extends State<CardApprovalPage> {
  String get forwardLabel {
    if (selectStatusType == 'TRANSFER') {
      return "APPROVE TO DIVISION USER*";
    } else {
      return "FORWARD/APPROVE CMI*";
    }
  }

  TextEditingController forwardController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  String? selectStatusType;
  bool isSubmitEnabled = false;
  bool isCheckboxChecked = false;
  bool isForwardToError = false;

  String? selectedDocumenttype;
  String? selectedForwardTo;
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



  String getDropdownLabel() {
    if (selectStatusType == "TRANSFER") return "Select Div ID";
    if (selectStatusType == "APPROVE") return "Select CMI";
    return "";
  }

  List<String> getDropdownOptions() {
    if (selectStatusType == "TRANSFER") return divIdOptions;
    if (selectStatusType == "APPROVE") return cmiOptions;
    return [];
  }

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

  String? fetchedFileName;


  final List<String> documents = [
    'Conc-Cert',
    'Disability-Cert',
    'Address proof',
    'DOB proof',
    'ID proof',
    'photo',
  ];

  String getDropdownHint() {
    if (selectStatusType == "TRANSFER") return "Select Division ID";
    if (selectStatusType == "APPROVE") return "Select CMI";
    return "Select Option";
  }

  final List<String> status = ['APPROVE', 'TRANSFER', 'REJECT'];

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
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
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
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
    final isStatusSelected = selectStatusType != null && selectStatusType!.isNotEmpty;
    final isForwardFilled = selectedForwardTo != null && selectedForwardTo!.trim().isNotEmpty;
    final isFeedbackFilled = feedbackController.text.trim().isNotEmpty;
    final isCommentFilled = commentController.text.trim().isNotEmpty;
    final isCheckboxCheckedLocal = isCheckboxChecked;

    bool enable = false;

    if (isStatusSelected && isCheckboxCheckedLocal) {
      if (selectStatusType == 'REJECT') {
        enable = isCommentFilled;
      } else if (selectStatusType == 'APPROVE' || selectStatusType == 'TRANSFER') {
        enable = isForwardFilled && isFeedbackFilled && isCommentFilled;
      }
    }

    setState(() {
      isSubmitEnabled = enable;
    });
  }

  List<String> cmiOptions = [];
  List<String> divIdOptions = [];


  Future<void> _submitForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final String status = selectStatusType ?? "";
    final String forwardTo = selectedForwardTo ?? "";
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
    print("Status: $status");
    print("Forward To: '$forwardTo'");
    print("Feedback: '$feedback'");
    print("Comment: '$comment'");


    if ((status == 'APPROVE' || status == 'TRANSFER') &&
        (forwardTo.isEmpty || feedback.isEmpty || comment.isEmpty)) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Please complete all fields for APPROVE/TRANSFER')),
      );
      return;
    }

    try {
      final url = Uri.parse('http://172.20.10.2:3000/applicationAction/${UserSession().selectedApplicantId}/action');
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};
      final body = jsonEncode({
        'action': status,
        'current_processing_employee': forwardTo,
        'comments': finalComment,
      });
      print('Sending request to: $url');
      print('Body: $body');
      print('Status: $status');
      print('Forward To: $forwardTo');
      print('Feedback: $feedback');
      print('Comment: $comment');



      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Form submitted successfully')),
        );
        navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => DivisonPage())
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


  @override
  void initState() {
    super.initState();
    forwardController.addListener(_updateSubmitButtonState);
    feedbackController.addListener(_updateSubmitButtonState);
    commentController.addListener(_updateSubmitButtonState);
    fetchAndSetDataFromApi();
  }

  @override
  void dispose() {
    forwardController.dispose();
    feedbackController.dispose();
    commentController.dispose();
    super.dispose();
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
          });
        }
      } else {
        _setEmptyValues();
      }
    } catch (e) {
      _setEmptyValues();
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
    ].every((field) => field != null && field!.isNotEmpty)) {
      setState(() {
        isSubmitEnabled = true;
      });
    }
  }

  Future<void> fetchTransferDivisionOptions() async {
    final response = await http.get(
        Uri.parse("http://172.20.10.2:3000/baseEmployeeOptions/${UserSession().staff_id}")
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> raw = body['level1_users'] as List<dynamic>;
      setState(() {
        divIdOptions = raw.map((e) => e['user_id'].toString()).toList();
      });
    }
  }

  Future<void> fetchNextLevelOptions() async {
    final response = await http.get(
        Uri.parse("http://172.20.10.2:3000/baseEmployeeOptions/${UserSession().staff_id}")
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> raw = body['level2_users'] as List<dynamic>;
      setState(() {
        cmiOptions = raw.map((e) => e['user_id'].toString()).toList();
      });
    }
  }

  // Future<void> fetchDocumentFileName(String documentType) async {
  //   try {
  //     final response = await http.get(Uri.parse(
  //       "https://your-api.com/get-doc-name?docType=$documentType",
  //     ));
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       setState(() {
  //         fetchedFileName = data['file_name']; // Adjust key as per your API
  //       });
  //     } else {
  //       setState(() {
  //         fetchedFileName = "No file found";
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       fetchedFileName = "Error fetching file";
  //     });
  //   }
  // }
  //


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
                                'DIVYANGJAN CARD APPROVAL',
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
                                'Download Documnets of the Applicant ',
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

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
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
                            SizedBox(width: 10),
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
                                // TODO: Implement history logic
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
                                "FORWARD/APPROVE CMI DETAILS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color.fromARGB(244, 84, 83, 83),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 12.0),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 200,
                              child: buildDropdown(
                                label: "APPROVE/REJECT *",
                                value: selectStatusType,
                                items: status,
                                onChanged: (val) async {
                                  setState(() {
                                    selectStatusType = val;

                                    if (val == 'REJECT') {
                                      selectedForwardTo = null;
                                    }

                                    isForwardToError = false;
                                    cmiOptions = [];
                                    divIdOptions = [];
                                  });

                                  // Load dropdown options
                                  if (val == "APPROVE") {
                                    await fetchNextLevelOptions();
                                  } else if (val == "TRANSFER") {
                                    await fetchTransferDivisionOptions();
                                  }


                                },

                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    forwardLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color.fromARGB(244, 84, 83, 83),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color.fromARGB(255, 181, 74, 226)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: (selectStatusType == "APPROVE" || selectStatusType == "TRANSFER")
                                        ? DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedForwardTo,
                                        hint: Text(getDropdownHint()),
                                        items: getDropdownOptions().map((option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedForwardTo = val;
                                            _updateSubmitButtonState();
                                          });
                                        },

                                      ),
                                    )
                                        : TextField(
                                      controller: forwardController,
                                      enabled: selectStatusType != "REJECT",
                                      decoration: InputDecoration.collapsed(
                                        hintText: "Enter CMI",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),


                      SizedBox(height: 10.0),

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
                            const SizedBox(height: 6),
                            Container(
                              width: 200,
                              height: 55,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(
                                    255,
                                    181,
                                    74,
                                    226,
                                  ), // same violet border
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextField(
                                controller: feedbackController,
                                decoration: InputDecoration(
                                  //hintText: 'Enter something...', // Optional: adds a light placeholder
                                  // border: InputBorder.none,       // Optional: remove if you want default underline
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

                      SizedBox(height: 12.0),

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

                      SizedBox(height: 12.0),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isCheckboxChecked,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckboxChecked = value!;
                                });
                                _updateSubmitButtonState();
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0),

                                child: Text(
                                  'I hereby declare that Application Details and Documents uploaded for TestCase with Disability ..  have been verified and Found to be OK. Concession Certificate Verification can be intiated for Card Generation.',
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

                      SizedBox(height: 12.0),

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