import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';

class ApplicationDetail {
  final String label;
  final String value;
  final String key;

  ApplicationDetail({required this.label, required this.value, required this.key});
}

class ApplicationDetailsTable extends StatefulWidget {
  const ApplicationDetailsTable({super.key});

  @override
  State<ApplicationDetailsTable> createState() => _ApplicationDetailsTableState();
}

class _ApplicationDetailsTableState extends State<ApplicationDetailsTable> {
  List<ApplicationDetail> _details = [];
  String _errorMessage = '';
  bool _isLoading = true;
  String _statusValue = ''; // Store status to control icon behavior

  final List<String> _expectedKeys = [
    'application_id',
    'submission_date',
    'name',
    'mobile_number',
    'station_id',
    'status',
    'comments',
    'normalPrint',
    'idPrint'
  ];

  @override
  void initState() {
    super.initState();
    _fetchApplicationDetails();
  }

  Future<void> _fetchApplicationDetails() async {
    try {
      final url = Uri.parse('http://172.20.10.2:3000/applicantDashboard/${UserSession().applicant_id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> applicationList = jsonData['data'];

        if (applicationList.isNotEmpty) {
          final Map<String, dynamic> application = applicationList[0];
          final List<ApplicationDetail> fetched = [];

          for (final key in _expectedKeys) {
            final dynamic rawValue = application[key];
            final String value = (rawValue == null || rawValue == false || rawValue == '') ? ' ' : rawValue.toString();
            final label = _formatLabel(key);

            if (key == 'status') {
              _statusValue = value;
            }

            fetched.add(ApplicationDetail(label: label, value: value, key: key));
          }

          setState(() {
            _details = fetched;
            _errorMessage = '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No application data found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network Error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatLabel(String key) {
    switch (key) {
      case 'application_id':
        return 'Application Number';
      case 'submission_date':
        return 'Application Date';
      case 'name':
        return 'Applicant Name';
      case 'mobile_number':
        return 'Mobile Number';
      case 'station_id':
        return 'Card Issuing Station';
      case 'status':
        return 'Status';
      case 'comments':
        return 'Application Feedback';
      case 'normalPrint':
        return 'Normal Print';
      case 'idPrint':
        return 'ID Print';
      default:
        return key;
    }
  }

  void _onOpenPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open action triggered.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    if (_details.isEmpty) {
      return const Center(child: Text('No details available'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith((states) => Colors.purple.shade100),
          columns: const [
            DataColumn(
              label: Text('Attribute', style: TextStyle(fontFamily: 'InriaSans', fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Value', style: TextStyle(fontFamily: 'InriaSans', fontWeight: FontWeight.bold)),
            ),
          ],
          rows: _details.map((detail) {
            return DataRow(
              cells: [
                DataCell(Text(detail.label, style: const TextStyle(fontFamily: 'InriaSans'))),
                DataCell(
                  detail.key == 'idPrint'
                      ? IconButton(
                    icon: Icon(
                      Icons.open_in_new,
                      color: _statusValue == 'Approved' ? Colors.blue : Colors.grey,
                    ),
                    onPressed: _statusValue == 'Approved' ? _onOpenPressed : null,
                  )
                      : Text(detail.value, style: const TextStyle(fontFamily: 'InriaSans')),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
