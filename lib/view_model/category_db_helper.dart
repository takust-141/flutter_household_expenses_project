import 'package:household_expenses_project/view_model/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:household_expenses_project/model/category.dart';

//DBHelper
class CategoryDBHelper {
  //シングルトンパターン（インスタンスが1つで静的）
  static final CategoryDBHelper _instance = CategoryDBHelper._();
  factory CategoryDBHelper() => _instance;
  CategoryDBHelper._();

  late final Database _database;

  Future openDataBase() async {
    final dbpass = await DbHelper.getDbPath();
    _database = await openDatabase(
      dbpass,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $categoryTable ( 
          $categoryId INTEGER PRIMARY KEY, 
          $categoryName TEXT NOT NULL,
          $categoryIcon TEXT NOT NULL,
          $categoryColor TEXT NOT NULL,
          $categotyParentId INTEGER,
          $categoryOrder INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Category>> getAllCategory() async {
    List<Category> categoryList = [];
    List<Map> listMap = await _database.query(
      categoryTable,
      where: "$categotyParentId IS NULL",
      orderBy: "$categoryOrder ASC",
    );
    for (var map in listMap) {
      categoryList.add(Category.fromMap(map));
    }
    return categoryList;
  }

  Future<List<Category>> getAllSubCategory(int? parentId) async {
    List<Category> categoryList = [];
    if (parentId != null) {
      List<Map> listMap = await _database.query(
        categoryTable,
        where: '$categotyParentId IS NOT NULL AND $categotyParentId = ?',
        whereArgs: [parentId],
        orderBy: "$categoryOrder ASC",
      );
      for (var map in listMap) {
        categoryList.add(Category.fromMap(map));
      }
    }
    return categoryList;
  }

  Future<void> insertCategory(Category category) async {
    await _database.insert(categoryTable, category.toMap());
  }

  //idは一意のため一件のみ返す
  Future<Category?> getCategoryFromId(int id) async {
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

  Future<void> deleteCategoryFromId(int id) async {
    await _database.delete(
      categoryTable,
      where: '$categoryId = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCategory(Category category) async {
    await _database.update(
      categoryTable,
      category.toMap(),
      where: '$categoryId = ?',
      whereArgs: [category.id],
    );
  }

  Future close() async => _database.close();
}
