import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all forms
  Future<List<QueryDocumentSnapshot>> getAllForms() async {
    QuerySnapshot snapshot = await _firestore.collection('forms').get();
    return snapshot.docs;
  }

  // Fetch forms by date range
  Future<List<QueryDocumentSnapshot>> getFormsByDateRange(
      DateTime startDate, DateTime endDate) async {
    QuerySnapshot snapshot = await _firestore
        .collection('forms')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();
    return snapshot.docs;
  }

  // Fetch forms by scooter ID
  Future<List<QueryDocumentSnapshot>> getFormsByScooterId(
      String scooterId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('forms')
        .where('scooterId', isEqualTo: scooterId)
        .get();
    return snapshot.docs;
  }

  // Fetch forms by user ID
  Future<List<QueryDocumentSnapshot>> getFormsByUserId(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('forms')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs;
  }

  // Fetch task summary by scooter ID
  Future<Map<String, int>> getTaskSummaryByScooterId(String scooterId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('forms')
        .where('scooterId', isEqualTo: scooterId)
        .get();

    Map<String, int> taskSummary = {};
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var tasks = Map<String, bool>.from(data['tasks']);
      tasks.forEach((task, isCompleted) {
        if (isCompleted) {
          taskSummary[task] = (taskSummary[task] ?? 0) + 1;
        }
      });
    }
    return taskSummary;
  }

  // Fetch user ID by user name, ignoring case
  Future<String> getUserIdByName(String userName) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    if (snapshot.docs.isNotEmpty) {
      for (var user in snapshot.docs) {
        if ((user['name'] as String)
            .toLowerCase()
            .contains(userName.toLowerCase())) {
          return user.id;
        }
      }
      throw Exception('User not found');
    } else {
      throw Exception('User not found');
    }
  }

  // Fetch user name by id
  Future<String> getUserNameById(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var user = snapshot.docs.first;
      return user['name'];
    } else {
      throw Exception('User not found');
    }
  }

  Future<List<QueryDocumentSnapshot>> getForms({
    DateTime? startDate,
    DateTime? endDate,
    String? scooterId,
    String? userId,
  }) async {
    Query query = _firestore.collection('forms');

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    if (scooterId != null) {
      query = query.where('scooterId', isEqualTo: scooterId);
    }

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    try {
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs;
    } on Exception catch (e) {
      // TODO
      print(e);
      throw (e);
    }
  }

  // Check if the user is an admin
  Future<bool> isAdmin(User? user) async {
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      return data?['isAdmin'] ?? false;
    } catch (e) {
      print('Admin check failed: $e');
      return false;
    }
  }
}
