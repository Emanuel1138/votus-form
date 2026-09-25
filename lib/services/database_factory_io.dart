import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openSurveyDatabase() async {
  final directory = await getApplicationDocumentsDirectory();

  final dbPath = p.join(
    directory.path,
    'survey.db',
  );

  return databaseFactoryIo.openDatabase(dbPath);
}