import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/view_model/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:household_expense_project/model/category.dart';

//DBHelper
class CategoryDBHelper {
  static final Database _database = DbHelper.database;

  //全カテゴリ取得
  static Future<(List<Category>, List<Category>)> getAllCategory() async {
    final batch = _database.batch();
    batch.query(
      categoryTable,
      where: "$categoryParentId IS NULL AND $categoryExpense = ?",
      whereArgs: [SelectExpense.outgo.name],
      orderBy: "$categoryOrder ASC",
    );
    batch.query(
      categoryTable,
      where: "$categoryParentId IS NULL AND $categoryExpense = ?",
      whereArgs: [SelectExpense.income.name],
      orderBy: "$categoryOrder ASC",
    );

    final List<Object?> batchResult = await batch.commit();
    List<List<Map>> listMaps = batchResult.cast<List<Map<dynamic, dynamic>>>();

    List<Category> outgoCategoryList = [];
    for (var map in listMaps[0]) {
      outgoCategoryList.add(Category.fromMap(map));
    }
    List<Category> incomeCategoryList = [];
    for (var map in listMaps[1]) {
      incomeCategoryList.add(Category.fromMap(map));
    }
    return (outgoCategoryList, incomeCategoryList);
  }

  //サブカテゴリーリスト取得
  static Future<List<Category>> getAllSubCategory(int parentId) async {
    List<Category> categoryList = [];
    List<Map> listMap = await _database.query(
      categoryTable,
      where: '$categoryParentId IS NOT NULL AND $categoryParentId = ?',
      whereArgs: [parentId],
      orderBy: "$categoryOrder ASC",
    );
    for (var map in listMap) {
      categoryList.add(Category.fromMap(map));
    }

    return categoryList;
  }

  //insert
  static Future<void> insertCategory(Category category) async {
    await _database.insert(categoryTable, category.toMap());
  }

  //idは一意のため一件のみ返す
  static Future<Category?> getCategoryFromId(int id) async {
    List<Map> maps = await _database.query(
      categoryTable,
      where: '$categoryId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //対象のカテゴリーとサブカテゴリーを全て削除（整合性のために先にregisterを削除）
  static Future<void> deleteCategoryFromId(int deleteId) async {
    try {
      await _database.transaction((txn) async {
        //register削除  :「registerCategoryId」が「c1.$categoryId（カテゴリーかサブカテゴリーが対象と一致）」と一致するものを削除
        await txn.rawDelete(
          '''
        DELETE FROM $registerTable
        WHERE $registerCategoryId
        IN (
          SELECT c1.$categoryId
          FROM $categoryTable AS c1
          WHERE c1.$categoryParentId = ? OR c1.$categoryId = ?
        )
        ''',
          [deleteId, deleteId],
        );

        //recurring register削除
        await txn.rawDelete(
          '''
        DELETE FROM $registerRecurringTable
        WHERE $registerRecurringCategoryId 
        IN (
          SELECT c1.$categoryId
          FROM $categoryTable AS c1
          WHERE c1.$categoryParentId = ? OR c1.$categoryId = ?
        )
        ''',
          [deleteId, deleteId],
        );

        //category削除
        await txn.delete(
          categoryTable,
          where: '$categoryId = ? OR $categoryParentId = ?',
          whereArgs: [deleteId, deleteId],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  //カテゴリーの移行（registerのcategory移行→カテゴリー削除）
  //前提：mergeFromIdにサブカテゴリーが無いこと
  static Future<void> mergeCategoryFromId(
      int mergeFromId, int margeToId) async {
    try {
      await _database.transaction((txn) async {
        //registerカテゴリ変更
        await txn.update(
          registerTable, // 更新対象のテーブル名
          {registerCategoryId: margeToId}, // 更新するカラムと新しい値
          where: '$registerCategoryId = ?', // 条件を指定
          whereArgs: [mergeFromId], // 条件に一致する値
        );

        //registerRecuuringカテゴリ変更
        await txn.update(
          registerRecurringTable, // 更新対象のテーブル名
          {registerRecurringCategoryId: margeToId}, // 更新するカラムと新しい値
          where: '$registerRecurringCategoryId = ?', // 条件を指定
          whereArgs: [mergeFromId], // 条件に一致する値
        );

        //カテゴリ削除
        await txn.delete(
          categoryTable,
          where: '$categoryId = ? OR $categoryParentId = ?',
          whereArgs: [mergeFromId, mergeFromId],
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateCategory(Category category) async {
    await _database.update(
      categoryTable,
      category.toMap(),
      where: '$categoryId = ?',
      whereArgs: [category.id],
    );
  }
}
