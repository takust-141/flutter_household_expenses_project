import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:household_expenses_project/model/category.dart';

final String selectColumns1 = categoryKeyList
    .asMap()
    .entries
    .map((entry) =>
        "c1.${entry.value} AS ${registerCategory1KeyList[entry.key]}")
    .join(", ");
final String selectColumns2 = categoryKeyList
    .asMap()
    .entries
    .map((entry) =>
        "c2.${entry.value} AS ${registerCategory2KeyList[entry.key]}")
    .join(", ");

//DBHelper
class RegisterDBHelper {
  static final Database _database = DbHelper.database;

  static Future<void> insertRegister(Register register) async {
    await _database.insert(registerTable, register.toMap());
  }

  static Future<void> deleteRegisterFromId(int id) async {
    await _database.delete(
      registerTable,
      where: '$registerId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateRegister(Register register) async {
    await _database.update(
      registerTable,
      register.toMap(),
      where: '$registerId = ?',
      whereArgs: [register.id!],
    );
  }

  static Future<List<Register>> getRegisterOfRange(
      DateTime startDate, DateTime endDate) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfText(String text) async {
    final String searchText = "%$text%";

    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE ( $registerTable.$registerMemo LIKE ? OR $registerTable.$registerAmount LIKE ? )
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [searchText, text]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfRangeAndCategoryList(
      DateTime startDate, DateTime endDate, List<Category> categoryList) async {
    List<Register> registerList = [];

    if (categoryList.isEmpty) return [];
    final placeholders = List.filled(categoryList.length, '?').join(',');

    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    AND (c1.$categoryId IN ($placeholders)
    OR c2.$categoryId IN ($placeholders))
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      ...categoryList.map((category) => category.id),
      ...categoryList.map((category) => category.id)
    ]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfRangeAndSelectExpenses(
      DateTime startDate,
      DateTime endDate,
      SelectExpenses selectExpenses) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    AND c1.$categoryExpenses = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      selectExpenses.name
    ]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfCategory(Category category) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE c1.$categoryId = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [category.id]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfSelectExpenses(
      SelectExpenses selectExpenses) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE c1.$categoryExpenses = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [selectExpenses.name]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getAllRegister() async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''');

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future close() async => _database.close();
}
