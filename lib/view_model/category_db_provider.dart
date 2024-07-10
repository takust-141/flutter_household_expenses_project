import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:household_expenses_project/model/category.dart';

class CategoryDBProvider {
  late Database db;

  Future<String> _getDbPath() async {
    var dbFilePath = '';
    if (Platform.isAndroid) {
      dbFilePath = await getDatabasesPath();
    } else if (Platform.isIOS) {
      final dbDirectory = await getLibraryDirectory();
      dbFilePath = dbDirectory.path;
      debugPrint("DB path : $dbFilePath");
    } else {
      throw Exception('Unable to determine platform.');
    }
    try {
      await Directory(dbFilePath).create(recursive: true);
    } catch (e) {
      rethrow;
    }

    final path = join(dbFilePath, 'category.db');
    return path;
  }

  Future open() async {
    late String path;
    try {
      path = await _getDbPath();
    } catch (e) {
      rethrow;
    }

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $categoryTable ( 
          $categoryId INTEGER PRIMARY KEY, 
          $categoryName TEXT NOT NULL,
          $categoryIconName TEXT NOT NULL,
          $categoryColor TEXT NOT NULL,
          $categotyParentId INTEGER)
        ''');
      },
    );
  }

  Future<Category> insert(Category category) async {
    category.id = await db.insert(categoryTable, category.toMap());
    return category;
  }

  //idは一意のため一件のみ返す
  Future<Category?> getCategory(int id) async {
    List<Map> maps = await db.query(
      categoryTable,
      columns: [
        categoryName,
        categoryIconName,
        categoryIconName,
        categotyParentId
      ],
      where: '$categoryId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> delete(int id) async {
    return await db.delete(
      categoryTable,
      where: '$categoryId = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Category category) async {
    return await db.update(
      categoryTable,
      category.toMap(),
      where: '$categoryId = ?',
      whereArgs: [category.id],
    );
  }

  Future close() async => db.close();
}
