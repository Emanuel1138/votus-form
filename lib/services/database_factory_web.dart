import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

Future<Database> openSurveyDatabase() async {
  return databaseFactoryWeb.openDatabase('survey.db');
}