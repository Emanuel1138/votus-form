import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/question.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import 'thank_you_screen.dart';

class SurveyFormScreen extends StatefulWidget {
  const SurveyFormScreen({super.key});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final Map<int, String> _answers = {};
  bool _submitting = false;

  bool get _isComplete => _answers.length == surveyQuestions.length;

  Future<void> _submit() async {
    if (!_isComplete) return;
    setState(() => _submitting = true);

    final deviceId = const Uuid().v4();
    final answeredAt = DateTime.now().toIso8601String();
    final answersJson = jsonEncode(
      surveyQuestions
          .map((q) => {'question_id': q.id, 'answer': _answers[q.id]})
          .toList(),
    );

    // Salva local primeiro — isso sempre funciona, com ou sem internet.
    await DatabaseHelper.instance.insertResponse(
      deviceId: deviceId,
      answersJson: answersJson,
      answeredAt: answeredAt,
    );

    // Tenta sincronizar na hora, se tiver internet — mas não bloqueia o agradecimento.
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.none)) {
      SyncService().syncPending();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ThankYouScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa de satisfação')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...surveyQuestions.map((q) => _buildQuestion(q)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isComplete && !_submitting ? _submit : null,
            child: _submitting
                ? const CircularProgressIndicator()
                : const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Question q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold)),
            ...q.options.map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _answers[q.id],
                  onChanged: (value) => setState(() => _answers[q.id] = value!),
                )),
          ],
        ),
      ),
    );
  }
}