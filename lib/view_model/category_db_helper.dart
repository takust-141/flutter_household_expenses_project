import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:household_expenses_project/model/category.dart';

//DBHelper
class CategoryDBHelper {
  static final Database _database = DbHelper.database;

  static Future<List<Category>> getAllCategory(SelectExpenses expenses) async {
    List<Category> categoryList = [];
    List<Map> listMap = await _database.query(
      categoryTable,
      where: "$categoryParentId IS NULL AND $categoryExpenses = ?",
      whereArgs: [expenses.name],
      orderBy: "$categoryOrder ASC",
    );
    for (var map in listMap) {
      categoryList.add(Category.fromMap(map));
    }
    return categoryList;
  }

  static Future<List<Category>> getAllSubCategory(int? parentId) async {
    List<Category> categoryList = [];
    if (parentId != null) {
      List<Map> listMap = await _database.query(
        categoryTable,
        where: '$categoryParentId IS NOT NULL AND $categoryParentId = ?',
        whereArgs: [parentId],
        orderBy: "$categoryOrder ASC",
      );
      for (var map in listMap) {
        categoryList.add(Category.fromMap(map));
      }
    }
    return categoryList;
  }

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

  static Future<void> deleteCategoryFromId(int id) async {
    await _database.delete(
      categoryTable,
      where: '$categoryId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateCategory(Category category) async {
    await _database.update(
      categoryTable,
      category.toMap(),
      where: '$categoryId = ?',
      whereArgs: [category.id],
    );
  }

  static Future close() async => _database.close();
}
