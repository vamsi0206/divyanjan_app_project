import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';
import 'level1applicationview.dart';

class Applicant {
  final String id;
  final String name;
  final String mobile;
  final String city;
  final String date;
  final String applicationNumber;

  Applicant({
    required this.id,
    required this.name,
    required this.mobile,
    required this.city,
    required this.date,
    required this.applicationNumber,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['applicant_id'].toString(),
      name: json['applicant_name'] ?? '',
      mobile: json['applicant_mobile_number'] ?? '',
      city: json['applicant_city'] ?? '',
      date: json['submission_date'] ?? '',
      applicationNumber: json['application_id'].toString(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Applicant> _applicants = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchApplicantList();
  }

  Future<void> _fetchApplicantList() async {
    try {
      final url = Uri.parse('http://172.20.10.2:3000/employeePage/${UserSession().level_user}/${UserSession().staff_id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = json.decode(response.body);
        final List<dynamic> responseData = responseMap['data'];
        final List<Applicant> fetchedApplicants = [];

        for (final item in responseData) {
          fetchedApplicants.add(Applicant.fromJson(item));
        }

        setState(() {
          _applicants = fetchedApplicants;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Network error: $error';
        _isLoading = false;
      });
    }
  }

  void _onRowTap(Applicant applicant) {
    UserSession().selectedApplicantId = applicant.id;

    if (UserSession().level_user == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CardApprovalPage()),
      );
    } else if (UserSession().level_user == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ApplicantDetailPage()),
      );
    } else if (UserSession().level_user == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ApplicantDetailPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unknown user level: ${UserSession().level_user}')),
      );
    }
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.purple.shade100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('App No.', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildApplicantRow(Applicant applicant, int index) {
    final Color backgroundColor = index % 2 == 0 ? Colors.purple[50]! : Colors.deepPurple[100]!;

    return InkWell(
      onTap: () {
        _onRowTap(applicant);
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(applicant.date)),
            Expanded(flex: 2, child: Text(applicant.applicationNumber)),
            Expanded(flex: 2, child: Text(applicant.name)),
            Expanded(flex: 2, child: Text(applicant.mobile)),
            Expanded(flex: 2, child: Text(applicant.city)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applicants')),
        body: Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildHeaderRow(),
                  for (int i = 0; i < _applicants.length; i++)
                    _buildApplicantRow(_applicants[i], i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApplicantDetailPage extends StatelessWidget {
  const ApplicantDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? selectedId = UserSession().selectedApplicantId;

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Details')),
      body: Center(
        child: Text('Fetching details for Applicant ID: $selectedId'),
      ),
    );
  }
}
