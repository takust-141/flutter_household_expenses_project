import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:household_expenses_project/model/category.dart';

//Provider
final categorListNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
        CategoryNotifier.new);

final subCategorListNotifierProvider =
    AsyncNotifierProvider<SubCategoryNotifier, List<Category>>(
        SubCategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  late Database _database;

  //初期作業・初期値
  @override
  Future<List<Category>> build() async {
    await _open();
    return await getAllCategory();
  }

  Future<String> _getDbPath() async {
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

    final path = join(dbFilePath, 'category.db');
    return path;
  }

  Future _open() async {
    late String path;
    try {
      path = await _getDbPath();
    } catch (e) {
      rethrow;
    }

    _database = await openDatabase(
      path,
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

  Future insertCategory(
      {required String name,
      required IconData icon,
      required Color color}) async {
    final List<Category>? list = state.value;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      int maxOrder = 0;
      if (list != null) {
        for (int i = 0; i < list.length; i++) {
          if (maxOrder < list[i].order) {
            maxOrder = list[i].order;
          }
        }
      }
      Category category = Category(
        name: name,
        icon: icon,
        color: color,
        order: maxOrder + 1,
      );
      await _database.insert(categoryTable, category.toMap());
      List<Category> categoryList = await getAllCategory();
      return categoryList;
    });
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

  Future deleteCategoryFromId(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _database.delete(
        categoryTable,
        where: '$categoryId = ?',
        whereArgs: [id],
      );
      return await getAllCategory();
    });
  }

  Future updateCategory(Category category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _database.update(
        categoryTable,
        category.toMap(),
        where: '$categoryId = ?',
        whereArgs: [category.id],
      );
      return await getAllCategory();
    });
  }

  Future close() async => _database.close();
}

//サブカテゴリー
class SubCategoryNotifier extends CategoryNotifier {
  //初期作業・初期値
  @override
  Future<List<Category>> build() async {
    await _open();
    return await getAllCategory();
  }

  @override
  Future<List<Category>> getAllCategory() async {
    final selectCategoryProvider = ref.watch(selectCategoryNotifierProvider);
    List<Category> categoryList = [];
    if (selectCategoryProvider != null) {
      List<Map> listMap = await _database.query(
        categoryTable,
        where: '$categotyParentId IS NOT NULL AND $categotyParentId = ?',
        whereArgs: [selectCategoryProvider!.id],
        orderBy: "$categoryOrder ASC",
      );
      for (var map in listMap) {
        categoryList.add(Category.fromMap(map));
      }
    }

    return categoryList;
  }

  Future insertSubCategory({
    required String name,
    required IconData icon,
    required Color color,
    required int parentId,
  }) async {
    final List<Category>? list = state.value;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      int maxOrder = 0;
      if (list != null) {
        for (int i = 0; i < list.length; i++) {
          if (maxOrder < list[i].order) {
            maxOrder = list[i].order;
          }
        }
      }
      Category category = Category(
        name: name,
        icon: icon,
        color: color,
        order: maxOrder + 1,
        parentId: parentId,
      );
      await _database.insert(categoryTable, category.toMap());
      List<Category> categoryList = await getAllCategory();
      return categoryList;
    });
  }
}
