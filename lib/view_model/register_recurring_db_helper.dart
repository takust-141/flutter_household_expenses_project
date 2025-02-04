import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/view_model/db_helper.dart';
import 'package:household_expense_project/view_model/register_db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:household_expense_project/model/category.dart';

//DBHelper
class RegisterRecurringDBHelper {
  static final Database _database = DbHelper.database;

  static Future<int> insertRegisterRecurring(
      RegisterRecurring registerRecurring) async {
    try {
      return await _database.insert(
          registerRecurringTable, registerRecurring.toMap());
    } catch (e) {
      rethrow;
    }
  }

  //削除（Idから）
  static Future<void> deleteRegisterRecurringFromId(int id) async {
    try {
      await _database.transaction((txn) async {
        //register削除
        await txn.delete(
          registerTable,
          where: '$registerRecurringId = ?',
          whereArgs: [id],
        );
        //register recurring削除
        await txn.delete(
          registerRecurringTable,
          where: '$registerRecurringPrimaryId = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  //更新（registerは削除→新規）
  static Future<void> updateRegisterRecurring(
      RegisterRecurring registerRecurring, List<Register> registerList) async {
    try {
      // registerを一括挿入するSQLクエリを構築
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

      //db処理トランザクション
      await _database.transaction((txn) async {
        //register削除
        await txn.delete(
          registerTable,
          where: '$registerRecurringId = ?',
          whereArgs: [registerRecurring.id],
        );
        //register新規作成
        await txn.rawInsert(sql, args);

        //register recurring更新
        await txn.update(
          registerRecurringTable,
          registerRecurring.toMap(),
          where: '$registerRecurringPrimaryId = ?',
          whereArgs: [registerRecurring.id!],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  //更新（期間の変更：registerのinsert+delete）
  static Future<void> insertAndDeleteRegisterRecurring(
    RegisterRecurring registerRecurring,
    List<Register> insertRegisterList,
    List<(DateTime, DateTime?)> delDateRangeList,
  ) async {
    try {
      //db処理トランザクション
      await _database.transaction((txn) async {
        //register削除
        for (var dateRange in delDateRangeList) {
          DateTime startDate = dateRange.$1;
          DateTime? endDate = dateRange.$2;

          // where句を組み立てる
          String whereClause =
              '$registerRecurringId = ? AND $registerDate >= ?';
          List<dynamic> whereArgs = [
            registerRecurring.id,
            startDate.millisecondsSinceEpoch
          ];

          // 終了日がある場合は追加条件を加える
          if (endDate != null) {
            whereClause += ' AND $registerDate <= ?';
            whereArgs.add(endDate.millisecondsSinceEpoch);
          }

          // 削除処理
          await txn.delete(
            registerTable,
            where: whereClause,
            whereArgs: whereArgs,
          );
        }

        //register新規作成
        if (insertRegisterList.isNotEmpty) {
          // registerを一括挿入するSQLクエリを構築
          StringBuffer values = StringBuffer();
          List<Object?> args = []; // プレースホルダの引数を格納するリスト
          for (Register register in insertRegisterList) {
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

          await txn.rawInsert(sql, args);
        }

        //register recurring更新
        await txn.update(
          registerRecurringTable,
          registerRecurring.toMap(),
          where: '$registerRecurringPrimaryId = ?',
          whereArgs: [registerRecurring.id!],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  //更新（registerから）
  static Future<void> updateRegisterRecurringFromRegister(
      Register register) async {
    try {
      //db処理トランザクション
      await _database.transaction((txn) async {
        //register更新
        await txn.update(
          registerTable,
          {
            registerAmount: register.amount,
            registerCategoryId:
                register.subCategory?.id ?? register.category!.id!,
            registerMemo: register.memo,
            registerUpdateDate: DateTime.now().millisecondsSinceEpoch,
          },
          where: '$registerRecurringId = ?',
          whereArgs: [register.recurringId!],
        );

        //register recurring更新
        await txn.update(
          registerRecurringTable,
          {
            registerRecurringAmount: register.amount,
            registerRecurringCategoryId:
                register.subCategory?.id ?? register.category!.id!,
            registerRecurringMemo: register.memo,
          },
          where: '$registerRecurringPrimaryId = ?',
          whereArgs: [register.recurringId!],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  //更新（registerから）
  static Future<void> updateRegisterRecurringFromRegisterAfterBaseDate(
      Register register, DateTime baseDate) async {
    try {
      //db処理トランザクション
      await _database.transaction((txn) async {
        //register更新
        await txn.update(
          registerTable,
          {
            registerAmount: register.amount,
            registerCategoryId:
                register.subCategory?.id ?? register.category!.id!,
            registerMemo: register.memo,
            registerUpdateDate: DateTime.now().millisecondsSinceEpoch,
          },
          where: '$registerRecurringId = ? AND $registerDate >= ?',
          whereArgs: [register.recurringId!, baseDate.millisecondsSinceEpoch],
        );

        //register recurring更新
        await txn.update(
          registerRecurringTable,
          {
            registerRecurringAmount: register.amount,
            registerRecurringCategoryId:
                register.subCategory?.id ?? register.category!.id!,
            registerRecurringMemo: register.memo,
          },
          where: '$registerRecurringPrimaryId = ?',
          whereArgs: [register.recurringId!],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  //Expensesからリスト取得
  static Future<List<RegisterRecurring>> getRegisterRecurringOfSelectExpense(
      SelectExpense selectExpense) async {
    List<RegisterRecurring> registerRecurringList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerRecurringTable.*, $selectColumns1, $selectColumns2
    FROM $registerRecurringTable
    INNER JOIN $categoryTable AS c1 ON $registerRecurringTable.$registerRecurringCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    WHERE c1.$categoryExpense = ?
    ORDER BY $registerRecurringTable.$registerRecurringOrder ASC
    ''', [selectExpense.name]);

    for (var map in listMap) {
      registerRecurringList.add(RegisterRecurring.fromMap(map));
    }
    return registerRecurringList;
  }

  //全取得
  static Future<List<RegisterRecurring>> getAllRegisterRecurring() async {
    List<RegisterRecurring> registerRecurringList = [];
    List<Map> listMap = await _database.rawQuery('''
    SELECT $registerRecurringTable.*, $selectColumns1, $selectColumns2
    FROM $registerRecurringTable
    INNER JOIN $categoryTable AS c1 ON $registerRecurringTable.$registerCategoryId = c1.$categoryId
    LEFT OUTER JOIN $categoryTable AS c2 ON c1.$categoryParentId = c2.$categoryId

    ORDER BY $registerRecurringTable.$registerRecurringOrder ASC
    ''');

    for (var map in listMap) {
      registerRecurringList.add(RegisterRecurring.fromMap(map));
    }
    return registerRecurringList;
  }
}
