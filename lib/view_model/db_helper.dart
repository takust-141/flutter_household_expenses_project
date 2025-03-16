import 'dart:io';
import 'package:flutter/material.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/select_expense_state.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final defaultMapList = [
  {
    categoryId: 1,
    categoryName: '食費',
    categoryIcon: Symbols.restaurant.codePoint.toString(),
    categoryColor: Colors.red.shade600.toARGB32().toString(),
    categoryParentId: null,
    categoryOrder: 1,
    categoryExpense: SelectExpense.outgo.name,
  },
  {
    categoryId: 2,
    categoryName: 'スーパー',
    categoryIcon: Symbols.shopping_cart.codePoint.toString(),
    categoryColor: Colors.deepOrange.toARGB32().toString(),
    categoryParentId: 1,
    categoryOrder: 1,
    categoryExpense: SelectExpense.outgo.name,
  },
  {
    categoryId: 3,
    categoryName: '外食',
    categoryIcon: Symbols.fastfood.codePoint.toString(),
    categoryColor: Colors.orange.toARGB32().toString(),
    categoryParentId: 1,
    categoryOrder: 2,
    categoryExpense: SelectExpense.outgo.name,
  },
  {
    categoryId: 4,
    categoryName: '家賃',
    categoryIcon: Symbols.home.codePoint.toString(),
    categoryColor: Colors.green.toARGB32().toString(),
    categoryParentId: null,
    categoryOrder: 2,
    categoryExpense: SelectExpense.outgo.name,
  },
  {
    categoryId: 5,
    categoryName: '給料',
    categoryIcon: Symbols.payments.codePoint.toString(),
    categoryColor: Colors.indigo.toARGB32().toString(),
    categoryParentId: null,
    categoryOrder: 1,
    categoryExpense: SelectExpense.income.name,
  },
];

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

  static Future<void> openDataBase() async {
    final path = await getDBPath('register');
    try {
      database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          Batch batch = db.batch();
          batch.execute('''
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
          batch.execute('''
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
          batch.execute('''
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
          await batch.commit();

          // 初期データを挿入
          Batch insertBatch = db.batch();
          for (var defaultMap in defaultMapList) {
            insertBatch.insert(categoryTable, defaultMap);
          }
          await insertBatch.commit();
        },
      );
    } catch (e) {
      debugPrint("db err");
    }
  }

  static Future closeDataBase() async {
    if (database.isOpen) {
      database.close();
    }
  }
}
