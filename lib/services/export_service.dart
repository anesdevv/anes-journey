import 'package:flutter/foundation.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();

  factory ExportService() {
    return _instance;
  }

  ExportService._internal();

  Future<void> exportDataToJson() async {
    // Exporting from Firestore involves querying all collections.
    // This is currently disabled after migrating away from Hive.
    debugPrint('Export from Firestore is not currently implemented.');
  }
}
