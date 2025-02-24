import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

import '../services/auth/admin_service.dart';
import '../services/auth/auth_service.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  List<QueryDocumentSnapshot> _forms = [];
  Map<String, int> _taskSummary = {};
  DateTimeRange? _selectedDateRange;
  String _scooterId = '';
  String _selectedUserName = '';
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _scooterIdController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllForms();
  }

  Future<void> _fetchAllForms() async {
    List<QueryDocumentSnapshot> forms = await _adminService.getAllForms();

    // Sort the forms by timestamp in descending order
    forms.sort((a, b) {
      DateTime dateA = (a.data() as Map<String, dynamic>)['timestamp'].toDate();
      DateTime dateB = (b.data() as Map<String, dynamic>)['timestamp'].toDate();
      return dateB.compareTo(dateA); // Descending order
    });

    setState(() {
      _forms = forms;
    });
  }

  Future<void> _fetchForms() async {
    DateTime? startDate;
    DateTime? endDate;
    if (_selectedDateRange != null) {
      startDate = DateTime(
        _selectedDateRange!.start.year,
        _selectedDateRange!.start.month,
        _selectedDateRange!.start.day,
      );

      endDate = DateTime(
        _selectedDateRange!.end.year,
        _selectedDateRange!.end.month,
        _selectedDateRange!.end.day,
        23,
        59,
        59,
        999,
      );
    }

    String? userId;
    if (_selectedUserName.isNotEmpty) {
      try {
        userId = await _adminService.getUserIdByName(_selectedUserName);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı bulunamadı')));
        return;
      }
    }

    String? scooterId;
    if (_scooterId.isNotEmpty) {
      scooterId = _scooterId;
    }

    List<QueryDocumentSnapshot> forms = await _adminService.getForms(
      startDate: startDate,
      endDate: endDate,
      scooterId: scooterId,
      userId: userId,
    );

    // Sort the forms by timestamp in descending order
    forms.sort((a, b) {
      DateTime dateA = (a.data() as Map<String, dynamic>)['timestamp'].toDate();
      DateTime dateB = (b.data() as Map<String, dynamic>)['timestamp'].toDate();
      return dateB.compareTo(dateA); // Descending order
    });

    setState(() {
      _forms = forms;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDateRange = null;
      _scooterId = '';
      _selectedUserName = '';
      _scooterIdController.clear();
      _userNameController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _taskSummary = {};
      _fetchAllForms();
    });
  }

  Future<void> _exportToCSV() async {
    List<List<dynamic>> csvData = [
      <String>[
        'Scooter ID',
        'Personel Adı',
        'Tarih',
        'İşlemler',
        'Notlar',
      ]
    ];

    for (var form in _forms) {
      var data = form.data() as Map<String, dynamic>;

      Map<String, bool> tasks;
      if (data['tasks'] is Map<dynamic, dynamic>) {
        tasks = (data['tasks'] as Map<dynamic, dynamic>).cast<String, bool>();
      } else if (data['tasks'] is List<dynamic>) {
        tasks = {for (var task in data['tasks']) task: true};
      } else {
        tasks = {};
      }

      var completedTasks = tasks.entries
          .where((task) => task.value)
          .map((task) => task.key)
          .toList();

      csvData.add([
        data['scooterId'] ?? 'N/A',
        data['userName'] ?? 'N/A',
        data['timestamp'].toDate().toString(),
        completedTasks.join(', '),
        data['notes'] ?? 'None'
      ]);
    }

    // Convert list to CSV string
    String csv = const ListToCsvConverter().convert(csvData);

    // Add BOM to ensure proper encoding
    final bom = utf8.encode('\u{FEFF}');
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bom, bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create and click the download link
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'forms.csv')
      ..click();

    // Revoke the URL to free up resources
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel dosyası indirildi.')),
    );
  }

  void logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Sayfası'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Başlangıç Tarihi',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _startDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          _selectedDateRange = DateTimeRange(
                            start: pickedDate,
                            end: _selectedDateRange?.end ?? pickedDate,
                          );
                          _fetchForms();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: 'Bitiş Tarihi',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _endDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          _selectedDateRange = DateTimeRange(
                            start: _selectedDateRange?.start ?? pickedDate,
                            end: pickedDate,
                          );
                          _fetchForms();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _scooterIdController,
                    decoration: const InputDecoration(
                      labelText: 'Scooter ID',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _scooterId = value;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'Personel adı',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _selectedUserName = value;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchForms,
                  child: const Text('Ara'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: _clearFilters,
                  child: const Text('Temizle'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _exportToCSV,
                  child: const Text('Excele Aktar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _forms.length,
                itemBuilder: (context, index) {
                  var form = _forms[index];
                  var data = form.data() as Map<String, dynamic>;

                  // Handle different types for tasks
                  Map<String, bool> tasks;
                  if (data['tasks'] is Map<dynamic, dynamic>) {
                    tasks = (data['tasks'] as Map<dynamic, dynamic>)
                        .cast<String, bool>();
                  } else if (data['tasks'] is List<dynamic>) {
                    tasks = {for (var task in data['tasks']) task: true};
                  } else {
                    tasks = {};
                  }

                  var completedTasks = tasks.entries
                      .where((task) => task.value)
                      .map((task) => task.key)
                      .toList();

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Scooter ID: ${data['scooterId']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future:
                                _authService.getUserNameById(data['userId']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                    'Personel bilgileri yükleniyor...');
                              } else if (snapshot.hasError) {
                                return const Text(
                                    'Hata: Personel bilgileri yüklenemedi');
                              } else {
                                return Text('• Pesonel Adı: ${snapshot.data}');
                              }
                            },
                          ),
                          Text('• Tarih: ${data['timestamp'].toDate()}'),
                          Text(
                              '• Yapılan İşlemler: \n${completedTasks.join(', \n')}'),
                          Text('• Notlar: ${data['notes'] ?? 'not yok'}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_taskSummary.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'İşlem Özetleri:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (var entry in _taskSummary.entries)
                      ListTile(
                        title: Text(entry.key),
                        trailing: Text(entry.value.toString()),
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
