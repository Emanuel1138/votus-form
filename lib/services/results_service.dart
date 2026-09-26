import 'dart:convert';
import 'package:http/http.dart' as http;

class ResultsService {
  static const String _endpoint = 'https://votus-form-api.onrender.com/api/survey-responses/summary';

  Future<Map<int, Map<String, int>>> fetchSummary() async {
    final response = await http.get(
      Uri.parse(_endpoint),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar resultados (${response.statusCode})');
    }

    final Map<String, dynamic> raw = jsonDecode(response.body);

    return raw.map((questionId, answers) => MapEntry(
          int.parse(questionId),
          Map<String, int>.from(answers as Map),
        ));
  }
}