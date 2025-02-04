import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/view_model/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:household_expense_project/model/category.dart';

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

  //追加
  static Future<void> insertRegister(Register register) async {
    try {
      await _database.insert(registerTable, register.toMap());
    } catch (e) {
      rethrow;
    }
  }

  //追加（一括）
  static Future<void> insertRegisterList(List<Register> registerList) async {
    // 一括挿入するSQLクエリを構築
    StringBuffer values = StringBuffer();
    List<Object?> args = []; // プレースホルダの引数を格納するリスト

    for (Register register in registerList) {
      // プレースホルダを作成
      values.write("(?, ?, ?, ?, ?, ?, ?),");
      int categoryId = (register.subCategory == null)
          ? register.category!.id!
          : register.subCategory!.id!;
      args.add(register.amount); // amount
      args.add(categoryId); // categoryId
      args.add(register.memo); // memo
      args.add(register.date.millisecondsSinceEpoch); // date（ミリ秒）
      args.add(register.recurringId); // recurringId
      args.add(register.registrationDate.millisecondsSinceEpoch);
      args.add(register.updateDate?.millisecondsSinceEpoch);
    }

    // 最後のカンマを削除
    String sql = '''
    INSERT INTO $registerTable ($registerAmount, $registerCategoryId, $registerMemo, $registerDate ,$registerRecurringId ,$registerRegistrationDate,$registerUpdateDate)
    VALUES ${values.toString().substring(0, values.length - 1)};
    ''';

    try {
      await _database.rawInsert(sql, args);
    } catch (e) {
      rethrow;
    }
  }

  //削除（Idから）
  static Future<void> deleteRegisterFromId(int id) async {
    await _database.delete(
      registerTable,
      where: '$registerId = ?',
      whereArgs: [id],
    );
  }

  //更新
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

    WHERE ( $registerTable.$registerMemo LIKE ? OR c1.$categoryName LIKE ? OR c2.$categoryName LIKE ?   OR $registerTable.$registerAmount LIKE ?  )
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [searchText, searchText, searchText, text]);

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

  static Future<List<Register>> getRegisterOfRangeAndSelectExpense(
      DateTime startDate, DateTime endDate, SelectExpense selectExpense) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    AND c1.$categoryExpense = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      selectExpense.name
    ]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfRangeAndCategory(
      DateTime startDate, DateTime endDate, Category category) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    AND c1.$categoryId = ? OR c2.$categoryId = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      category.id,
      category.id
    ]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfRangeAndSubCategory(
      DateTime startDate, DateTime endDate, Category subCategory) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId
    
    WHERE $registerTable.$registerDate BETWEEN ? AND ?
    AND c1.$categoryId = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      subCategory.id
    ]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }

  static Future<List<Register>> getRegisterOfSelectExpense(
      SelectExpense selectExpense) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE c1.$categoryExpense = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [selectExpense.name]);

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

  static Future<List<Register>> getRegisterOfRecurringId(
      int recurringId) async {
    List<Register> registerList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerTable.*, $selectColumns1, $selectColumns2
    FROM $registerTable
    INNER JOIN $categoryTable AS c1 ON $registerTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE $registerRecurringId = ?
    ORDER BY $registerTable.$registerDate ASC,  $registerTable.$registerId ASC
    ''', [recurringId]);

    for (var map in listMap) {
      registerList.add(Register.fromMap(map));
    }
    return registerList;
  }
}
