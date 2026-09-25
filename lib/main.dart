import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'screens/survey_form_screen.dart';
import 'services/sync_service.dart';

void main() {
  runApp(const SurveyApp());
}

class SurveyApp extends StatefulWidget {
  const SurveyApp({super.key});

  @override
  State<SurveyApp> createState() => _SurveyAppState();
}

class _SurveyAppState extends State<SurveyApp> {
  @override
  void initState() {
    super.initState();

    // Tenta sincronizar pendências ao abrir o app...
    SyncService().syncPending();

    // ...e sempre que a conexão voltar durante o uso.
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        SyncService().syncPending();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesquisa Votus',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SurveyFormScreen(),
    );
  }
}