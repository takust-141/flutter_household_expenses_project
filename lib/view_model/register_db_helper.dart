import 'package:household_expenses_project/model/register.dart';
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

  static Future<List<Register>> getRegisterOfMonth(DateTime date) async {
    int startOfMonth =
        DateTime(date.year, date.month, 1).millisecondsSinceEpoch;
    int endOfMonth =
        DateTime(date.year, date.month + 1, 0).millisecondsSinceEpoch;

    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [startOfMonth, endOfMonth]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterStateOfText(String text) async {
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

  static Future close() async => _database.close();
}
