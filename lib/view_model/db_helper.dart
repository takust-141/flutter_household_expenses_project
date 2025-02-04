import 'dart:io';

import 'package:flutter/material.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //シングルトンパターン（インスタンスが1つで静的）
  static final DbHelper _instance = DbHelper._();
  factory DbHelper() => _instance;
  DbHelper._();

  static late final Database database;

  static Future<String> getDBPath(String dbName) async {
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

  static Future openDataBase() async {
    final path = await getDBPath('register');
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $categoryTable ( 
          $categoryId INTEGER PRIMARY KEY, 
          $categoryName TEXT NOT NULL,
          $categoryIcon TEXT NOT NULL,
          $categoryColor TEXT NOT NULL,
          $categoryParentId INTEGER,
          $categoryOrder INTEGER NOT NULL,
          $categoryExpense TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $registerTable ( 
          $registerId INTEGER PRIMARY KEY, 
          $registerAmount INTEGER NOT NULL,
          $registerCategoryId INTEGER NOT NULL,
          $registerMemo TEXT,
          $registerDate INTEGER NOT NULL,
          $registerRecurringId INTEGER,
          $registerRegistrationDate INTEGER NOT NULL,
          $registerUpdateDate INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE $registerRecurringTable ( 
          $registerRecurringPrimaryId INTEGER PRIMARY KEY, 
          $registerRecurringAmount INTEGER NOT NULL,
          $registerRecurringCategoryId INTEGER NOT NULL,
          $registerRecurringMemo TEXT,
          $registerRecurringDateStart INTEGER NOT NULL,
          $registerRecurringDateEnd INTEGER,
          $registerRecurringOrder INTEGER NOT NULL,
          $registerRecurringSetting TEXT NOT NULL,
          $registerRescheduleSetting TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future closeDataBase() async {
    if (database.isOpen) {
      database.close();
    }
  }
}
