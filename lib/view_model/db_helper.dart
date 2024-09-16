import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Future<String> getDbPath(String dbName) async {
    var dbFilePath = '';
    if (Platform.isAndroid) {
      dbFilePath = await getDatabasesPath();
    } else if (Platform.isIOS) {
      final dbDirectory = await getLibraryDirectory();
      dbFilePath = dbDirectory.path;
    } else {
      throw Exception('Unable to determine platform.');
    }
    debugPrint("DB path : $dbFilePath");
    try {
      await Directory(dbFilePath).create(recursive: true);
    } catch (e) {
      rethrow;
    }
    dbName = '$dbName.db';

    String path = join(dbFilePath, dbName);
    return path;
  }
}
