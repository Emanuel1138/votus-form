import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class SyncService {
  static const String _endpoint = 'https://votus-form-api.onrender.com/api/survey-responses';

  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> syncPending() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final pending = await _db.getPendingResponses();

    for (final row in pending) {
      try {
        final response = await http.post(
          Uri.parse(_endpoint),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'device_id': row['device_id'],
            'answered_at': row['answered_at'],
            'answers': jsonDecode(row['answers']),
          }),
        );

        if (response.statusCode == 201) {
          await _db.markAsSynced(row['id'] as int);
        }
      } catch (_) {
        // sem internet de verdade ou API fora do ar — tenta de novo na próxima chamada
        break;
      }
    }
  }
}