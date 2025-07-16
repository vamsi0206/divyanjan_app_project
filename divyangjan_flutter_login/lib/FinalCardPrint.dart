import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';

void main() =>
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Finalcard()));

// MODEL CLASS
class CardData {
  final String cardNo;
  final String name;
  final String bookingName;
  final String gender;
  final String dob;
  final String hospitalName;
  final String doctorName;
  final String doctorRegNo;
  final String handicapNature;
  final String validityYears;
  final String cardValidFrom;
  final String cardValidUpto;
  final String certificateIssueDate;

  CardData({
    required this.cardNo,
    required this.name,
    required this.bookingName,
    required this.gender,
    required this.dob,
    required this.hospitalName,
    required this.doctorName,
    required this.doctorRegNo,
    required this.handicapNature,
    required this.validityYears,
    required this.cardValidFrom,
    required this.cardValidUpto,
    required this.certificateIssueDate,
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      cardNo: json['card_number']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bookingName: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: json['date_of_birth']?.toString() ?? '',
      hospitalName: json['hospital_name']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString() ?? '',
      doctorRegNo: json['doctor_reg_no']?.toString() ?? '',
      handicapNature: json['disability_type_id']?.toString() ?? '',
      validityYears: json['concession_card_validity']?.toString() ?? '',
      cardValidFrom: json['card_issue_date']?.toString() ?? '',
      cardValidUpto: json['card_issue_valid_till']?.toString() ?? '',
      certificateIssueDate: json['certificate_issue_date']?.toString() ?? '',
    );
  }


}

class Finalcard extends StatefulWidget {
  @override
  State<Finalcard> createState() => _FinalcardState();
}

class _FinalcardState extends State<Finalcard> {
  CardData? cardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCardData();
  }

  Future<void> fetchCardData() async {
    final response = await http.get(Uri.parse('http://172.20.10.2:3000/fetchingCard/${UserSession().applicant_id}'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> dataList = decoded['data'];
      if (dataList.isNotEmpty) {
        final data = dataList[0];

        setState(() {
          cardData = CardData.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("No application data found.");
      }
    } else {
      setState(() => isLoading = false);
      print("Error loading card data: ${response.statusCode}");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (cardData == null) {
      return Scaffold(
        body: Center(child: Text("Failed to load card data")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: 750,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Card(
              margin: EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 3,
              child: Container(
                width: 750,
                padding: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      color: Color(0xFFD9F4F1),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/tr_railway_logo.png",
                            height: 55,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error, color: Colors.red);
                            },
                          ),
                          SizedBox(height: 6),
                          Text(
                            "INDIAN RAILWAY’S DIVYANGJAN IDENTITY CARD",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info Section
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: buildCardFromForm(
                        cardNo: cardData!.cardNo,
                        name: cardData!.name,
                        bookingName: cardData!.bookingName,
                        gender: cardData!.gender,
                        dob: cardData!.dob,
                        hospitalName: cardData!.hospitalName,
                        doctorName: cardData!.doctorName,
                        doctorRegNo: cardData!.doctorRegNo,
                        handicapNature: cardData!.handicapNature,
                        validityYears: cardData!.validityYears,
                        cardValidFrom: cardData!.cardValidFrom,
                        cardValidUpto: cardData!.cardValidUpto,
                        certificateIssueDate: cardData!.certificateIssueDate,
                      ),
                    ),

                    // Footer & Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "COMPUTER GENERATED AND\nSIGNATURE NOT REQUIRED",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal[800],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Add print logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text("Print"),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text("Close"),
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
      ),
    );
  }

  // Helper: Info Card Widget
  Widget buildCardFromForm({
    required String cardNo,
    required String name,
    required String bookingName,
    required String gender,
    required String dob,
    required String hospitalName,
    required String doctorName,
    required String doctorRegNo,
    required String handicapNature,
    required String validityYears,
    required String cardValidFrom,
    required String cardValidUpto,
    required String certificateIssueDate,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: Text content
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoText("IDENTITY CARD NO", cardNo, bold: true),
              infoText("NAME", name, bold: true),
              infoText("NAME FOR BOOKING (16 Chars Max)", bookingName, bold: true),
              infoText("GENDER", gender, bold: true),
              infoText("DATE OF BIRTH", dob, bold: true),
              infoText("NAME OF GOVT. HOSPITAL/CLINIC/INSTITUTION", hospitalName, bold: true),
              infoText("NAME OF THE GOVT. DOCTOR", doctorName),
              infoText("REGISTRATION NO. OF DOCTOR", doctorRegNo, bold: true),
              infoText("NATURE OF HANDICAP", handicapNature, bold: true),
              infoText("VALIDITY OF CERTIFICATE", validityYears, bold: true),
              infoText("CARD VALID FROM", cardValidFrom, bold: true),
              infoText("CARD VALID UPTO", cardValidUpto, bold: true),
              infoText("CERTIFICATE ISSUE DATE", certificateIssueDate, bold: true),
              SizedBox(height: 20),
              QrImageView(
                data: '''{
                      "cardNo": "$cardNo",
                      "name": "$name",
                      "dob": "$dob",
                      "gender": "$gender",
                      "hospital": "$hospitalName",
                      "validFrom": "$cardValidFrom",
                      "validUpto": "$cardValidUpto"
                    }''',
                version: QrVersions.auto,
                size: 100.0,
                backgroundColor: Colors.white,
              ),

            ],
          ),
        ),

        // RIGHT: Sample Image
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              'assets/aadharsamplecard.png',
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, size: 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget infoText(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label : ",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: Colors.teal[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}