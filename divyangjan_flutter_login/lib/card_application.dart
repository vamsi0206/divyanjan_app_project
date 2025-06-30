import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_session.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'personal_details_table.dart';

void main() => runApp(MaterialApp(home: Concessionpage()));

class Concessionpage extends StatefulWidget {
  @override
  _ConcessionpageState createState() => _ConcessionpageState();
}

class _ConcessionpageState extends State<Concessionpage> {
  //cotrollers for 1st table
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  //final TextEditingController dateController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  bool isFormFilled = false;

  // controllers for 2nd table
  final TextEditingController concessionController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController disabilityController = TextEditingController();
  final TextEditingController dobProofUploadController =
  TextEditingController();
  final TextEditingController photoIdProofUploadController =
  TextEditingController();
  final TextEditingController addressProofUploadController =
  TextEditingController();

  // controllers for 3rd table
  final field3Controller = TextEditingController();
  final field4Controller = TextEditingController();
  final field5Controller = TextEditingController();
  final number1Controller = TextEditingController();
  final number2Controller = TextEditingController();

  bool isConfirmed = false;

  List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  String? selectedState;
  DateTime? selectedDate;

  // TextEditingController field3Controller = TextEditingController();
  // TextEditingController field4Controller = TextEditingController();
  // TextEditingController field5Controller = TextEditingController();
  // TextEditingController number1Controller = TextEditingController();
  // TextEditingController number2Controller = TextEditingController();

  String? selectedDobProof;
  String? selectedPhotoIdProof = 'Voter ID Card';
  String? selectedAddressProof;

  final List<String> dobProofTypes = [
    'Birth Certificate issued by Registrar of Births and Deaths or the Municipal Corporation',
    'Transfer/School Leaving/ Matriculation Certificate issued by the school last attended/recognized educational board',
    'Passport',
    'PAN card',
    'Voter ID',
    'Certificate of Date of Birth issued by Group A Gazetted officer or Tehsildar on Letterhead',
  ];

  final List<String> photoIdProofTypes = [
    'Aadhaar Card',
    'Passport',
    'Voter ID Card',
    'PAN Card',
    'Driving License',
  ];

  final List<String> addressProofTypes = [
    'Electricity Bill ( not older than 3 months)',
    'Water Bill',
    'Bank Statement',
    'Ration Card',
    'Aadhaar Card',
  ];

  bool isButtonEnabled = false;

  void _trySubmit() async {
    if (!isFormFilled || !isConfirmed) return;
    await _submitForm(status:'submitting');
  }

  void _trySaveDraft() async {
    await _submitForm(status:'draft');
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = isConfirmed;
    });
  }

  void checkForDuplicates(List<String> list, String label) {
    final duplicates = list.toSet().length != list.length;
    if (duplicates) {
      print("⚠ Duplicate found in $label list: $list");
    }
  }

  @override
  void initState() {
    super.initState();
    //1st table listeners
    fatherNameController.addListener(_checkFormFilled);
    addressController.addListener(_checkFormFilled);
    pinCodeController.addListener(_checkFormFilled);
    cityController.addListener(_checkFormFilled);
    districtController.addListener(_checkFormFilled);
    stateController.addListener(_checkFormFilled);
    // dateController.addListener(_checkFormFilled);
    dobController.addListener(_checkFormFilled);


    checkForDuplicates(
      photoIdProofTypes,
      "Photo ID Proof Types",
    ); // for duplicates

    //2nd table listeners

    concessionController.addListener(_checkFormFilled);
    photoController.addListener(_checkFormFilled);
    disabilityController.addListener(_checkFormFilled);
    dobProofUploadController.addListener(_checkFormFilled);
    photoIdProofUploadController.addListener(_checkFormFilled);
    addressProofUploadController.addListener(_checkFormFilled);

    //3rd tabel listeners

    field3Controller.addListener(_checkFormFilled);
    field4Controller.addListener(_checkFormFilled);
    field5Controller.addListener(_checkFormFilled);
    number1Controller.addListener(_checkFormFilled);
    number2Controller.addListener(_checkFormFilled);
  }

  @override
  void dispose() {
    // 1st table controllers
    fatherNameController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    dobController.dispose();

    // 2nd table controllers
    concessionController.dispose();
    photoController.dispose();
    disabilityController.dispose();
    dobProofUploadController.dispose();
    photoIdProofUploadController.dispose();
    addressProofUploadController.dispose();

    // 3rd table controllers
    field3Controller.dispose();
    field4Controller.dispose();
    field5Controller.dispose();
    number1Controller.dispose();
    number2Controller.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDraft(); // Moved here from initState
  }


  void _checkFormFilled() {
    bool filled =
    //1st table fields
    fatherNameController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        pinCodeController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        districtController.text.trim().isNotEmpty &&
        stateController.text.trim().isNotEmpty &&
        dobController.text.trim().isNotEmpty &&
        //2nd table fields
        concessionController.text.trim().isNotEmpty &&
        photoController.text.trim().isNotEmpty &&
        disabilityController.text.trim().isNotEmpty &&
        dobProofUploadController.text.trim().isNotEmpty &&
        photoIdProofUploadController.text.trim().isNotEmpty &&
        addressProofUploadController.text.trim().isNotEmpty &&
        selectedDobProof != null &&
        selectedPhotoIdProof != null &&
        selectedAddressProof != null &&
        //3rd table fields
        selectedState != null &&
        selectedDate != null &&
        field3Controller.text.trim().isNotEmpty &&
        field4Controller.text.trim().isNotEmpty &&
        field5Controller.text.trim().isNotEmpty &&
        number1Controller.text.trim().isNotEmpty &&
        number2Controller.text.trim().isNotEmpty;

    if (isFormFilled != filled) {
      setState(() {
        isFormFilled = filled;
      });
    }
  }

  Future<void> _submitForm({required String status}) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final url = Uri.parse(
        'http://172.20.10.2:3000/updateUserApplication/',
      ); // 🛑 Replace with real endpoint
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final body = jsonEncode({
        "applicant_id":UserSession().applicant_id,
        "fatherName": fatherNameController.text.trim(),
        "address": addressController.text.trim(),
        "pin_code": pinCodeController.text.trim(),
        "city": cityController.text.trim(),
        "district": districtController.text.trim(),
        "statename": stateController.text.trim(),
        "dob": dobController.text.trim(),
        "concessionCertificate": concessionController.text.trim(),
        "photograph": photoController.text.trim(),
        "disabilityCertificate": disabilityController.text.trim(),
        "dobProofType": selectedDobProof ?? "",
        "dobProofUpload": dobProofUploadController.text.trim(),
        "photoIdProofType": selectedPhotoIdProof ?? "",
        "photoIdProofUpload": photoIdProofUploadController.text.trim(),
        "addressProofType": selectedAddressProof ?? "",
        "addressProofUpload": addressProofUploadController.text.trim(),
        "rlyCertIssueDate": selectedDate?.toIso8601String() ?? "",
        "rlyCertIssuingState": selectedState ?? "",
        "hospitalCity": field3Controller.text.trim(),
        "hospitalName": field4Controller.text.trim(),
        "doctorName": field5Controller.text.trim(),
        "doctorRegNo": number1Controller.text.trim(),
        "disabilityCertNo": number2Controller.text.trim(),
        "status": status,
      });

      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      print("Sending data: $body");


      if (response.statusCode == 200 || response.statusCode == 201) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(status == 'draft' ? 'Draft Saved ✅' : 'Form Submitted 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Submission Failed ❌'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    }
  }
  Future<void> _loadDraft() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final applicantId = UserSession().applicant_id;

    try {
      final url = Uri.parse('http://172.20.10.2:3000/updateUserApplication/$applicantId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final draft = responseBody['data'][0];


        setState(() {
          fatherNameController.text = draft['fatherName'] ?? '';
          addressController.text = draft['address'] ?? '';
          pinCodeController.text = draft['pin_code'] ?? '';
          cityController.text = draft['city'] ?? '';
          districtController.text = draft['district'] ?? '';
          stateController.text = draft['statename'] ?? '';
          dobController.text = draft['dob'] ?? '';

          concessionController.text = draft['concessionCertificate'] ?? '';
          photoController.text = draft['photograph'] ?? '';
          disabilityController.text = draft['disabilityCertificate'] ?? '';
          selectedDobProof = draft['dobProofType'];
          dobProofUploadController.text = draft['dobProofUpload'] ?? '';
          selectedPhotoIdProof = draft['photoIdProofType'];
          photoIdProofUploadController.text = draft['photoIdProofUpload'] ?? '';
          selectedAddressProof = draft['addressProofType'];
          addressProofUploadController.text = draft['addressProofUpload'] ?? '';
          selectedDate = DateTime.tryParse(draft['rlyCertIssueDate'] ?? '');
          selectedState = draft['rlyCertIssuingState'];

          field3Controller.text = draft['hospitalCity'] ?? '';
          field4Controller.text = draft['hospitalName'] ?? '';
          field5Controller.text = draft['doctorName'] ?? '';
          number1Controller.text = draft['doctorRegNo'] ?? '';
          number2Controller.text = draft['disabilityCertNo'] ?? '';
        });

        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Draft loaded ✅')));
      } else {
        print('No draft found or error: ${response.body}');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error loading draft: $e')),
      );
    }
  }

  @override
  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.teal.shade700)),
          ),
        ],
      ),
    );
  }

  //    DropdownButtonFormField<String>(
  //   value: selectedPhotoIdProof,
  //   items: photoIdProofTypes.map((item) {
  //     return DropdownMenuItem(
  //       value: item,
  //       child: Text(item),
  //     );
  //   }).toList(),
  //   onChanged: (val) => setState(() => selectedPhotoIdProof = val),
  // )

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(),
        suffixIcon: Icon(Icons.mic),
      ),
      value: value,
      isExpanded: true,
      onChanged: (val) {
        onChanged(val);
        _checkFormFilled();
      }, // ✅ call here

      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis, maxLines: 2),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  //   Widget buildTextField(String label, TextEditingController controller) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 12.0),
  //     child: TextField(
  //       controller: controller,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         labelStyle: TextStyle(color: Colors.grey.shade800),
  //         border: OutlineInputBorder(),
  //       ),
  //     ),
  //   );
  // }

  Widget buildNumberField(String label, TextEditingController controller) {
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
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
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
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildTextField(String label, IconData icon) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: TextFormField(
  //       decoration: InputDecoration(
  //         labelText: label,
  //         suffixIcon: Icon(icon, size: 20, color: Colors.grey.shade700),
  //         border: UnderlineInputBorder(),
  //       ),
  //     ),
  //   );
  // }

  // Widget buildNumberField(String label, IconData icon) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: TextFormField(
  //       keyboardType: TextInputType.number,
  //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //       decoration: InputDecoration(
  //         labelText: label,

  //         suffixIcon: Icon(icon, size: 20, color: Colors.grey.shade700),
  //         border: UnderlineInputBorder(),
  //       ),
  //     ),
  //   );
  // }
  Widget buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: dobController, // ✅ using global controller
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              dobController.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
            _checkFormFilled(); // ✅ ensure we re-check form filled
          }
        },
        decoration: InputDecoration(
          labelText: "Date of Birth *",
          suffixIcon: Icon(Icons.calendar_today, size: 20),
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 254, 255, 254),
                  ),
                ),
                Text(
                  'CARD APPLICATION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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
            Container(
              width: double.infinity,

              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
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
                            'DIVYANGJAN CARD APPLICATION  FORM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '( All * Mark Fields are Mandatory)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15.0),


                  PersonalDetailsCard(),

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
                            'Card Application Details',
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
                        border: Border.all(
                          color: Color.fromARGB(255, 181, 74, 226),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDateField(context),
                          buildTextField(
                            "Father's Name *",
                            fatherNameController,
                          ),
                          buildTextField("Address *", addressController),
                          buildTextField("PIN-CODE *", pinCodeController),
                          buildTextField("City *", cityController),
                          buildTextField("District *", districtController),
                          buildTextField("State *", stateController),
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
                            'Upload Files( Allowed types: jpeg,jpg,png,pdf) ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '(Min_Size: 5 KB and Max_Size: 600 KB Each )',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.0),

                  Center(
                    child: Container(
                      width: 400,
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 181, 74, 226),
                        ), //Colors.grey.shade300
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTextField(
                            "Concession Certificate Upload",
                            concessionController,
                          ),
                          buildTextField("Photograph Upload", photoController),
                          buildTextField(
                            "Disability Certificate Upload",
                            disabilityController,
                          ),

                          buildDropdown(
                            label: "DOB Proof Type *",
                            value: selectedDobProof,
                            items: dobProofTypes,
                            onChanged: (val) {
                              setState(() {
                                selectedDobProof = val;
                              });
                              _checkFormFilled();
                            },
                          ),
                          buildTextField(
                            "DOB Proof Upload",
                            dobProofUploadController,
                          ),
                          buildDropdown(
                            label: "Photo ID Proof Type *",
                            value: selectedPhotoIdProof,
                            items: photoIdProofTypes,
                            onChanged: (val) {
                              setState(() {
                                selectedPhotoIdProof = val;
                              });
                              _checkFormFilled();
                            },
                          ),

                          buildTextField(
                            "Photo ID Proof Upload",
                            photoIdProofUploadController,
                          ),
                          buildDropdown(
                            label: "Address Proof Type *",
                            value: selectedAddressProof,
                            items: addressProofTypes,
                            onChanged: (val) {
                              setState(() {
                                selectedAddressProof = val;
                              });
                              _checkFormFilled();
                            },
                          ),

                          buildTextField(
                            "Address Proof Upload",
                            addressProofUploadController,
                          ),
                        ],
                      ),
                    ),
                  ),

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
                            'Details of Concession certificate ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ' Issued from Government Hospital',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10.0),

                  Center(
                    child: Container(
                      width: 400,
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 181, 74, 226),
                        ), //Colors.grey.shade300
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field 1: Date
                          Text(
                            "RLY Concession Cert Issue Date *",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                                _checkFormFilled();
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? selectedDate.toString().split(' ')[0]
                                    : "Select date",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),

                          // Field 2: State Dropdown
                          SizedBox(height: 16),
                          Text(
                            "Cert Issuing State *",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedState,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: states.map((state) {
                              return DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedState = val;
                              });
                              _checkFormFilled();
                            },
                          ),

                          // Field 3–5: Normal Fields
                          buildTextField(
                            "Cert Issuing Hospital City",
                            field3Controller,
                          ),
                          buildTextField(
                            "Cert Issuing Hospital Name*",
                            field4Controller,
                          ),
                          buildTextField("Doctor Name*", field5Controller),

                          // Field 6–7: Number Fields
                          buildNumberField(
                            "Doctor Registration Number *",
                            number1Controller,
                          ),
                          buildNumberField(
                            "Disability Certificate Number *",
                            number2Controller,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.0),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),

                    child: Row(
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

                            child: Text(
                              'I confirm that details given above belong to me and hereby state that I have no objection in authenticating my name and mobile number for the purpose of issuing of Divyangjan Concession Card by concerned Railway Authorities.I understand that my personal data will not be used for any other purposes other than issuing of Divyangjan Concession card.',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(255, 58, 56, 56),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _trySaveDraft,
                          //() {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text('Draft submitted!'),
                          //       backgroundColor: Colors.green,
                          //       duration: Duration(seconds: 2),
                          //     ),
                          //   );
                          // },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDD00), // Always yellow
                            foregroundColor: Colors.black,
                            elevation: 9.0,
                            shadowColor: Colors.grey.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'SAVE DRAFT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16.0),

                      SizedBox(
                        width: 180,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: isFormFilled && isConfirmed
                              ? _trySubmit
                              : null, //isConfirmed && isFormFilled
                          //     ? _tryLogin
                          //     : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonEnabled
                                ? Color(0xFFFFDD00)
                                : Colors.grey[400],
                            foregroundColor: Colors.black,
                            elevation: 9.0,
                            shadowColor: Colors.grey.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'SAVE AND SUBMIT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}