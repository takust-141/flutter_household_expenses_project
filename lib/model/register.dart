import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/keyboard_components.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/select_expenses_provider.dart';
import 'package:household_expenses_project/view_model/category_db_helper.dart';

const String registerTable = 'register';
const String registerId = '_id';
const String registerAmount = 'amount';
const String registerCategoryId = 'category_id';
const String registerMemo = 'memo';
const String registerDate = 'date';

final List<String> registerCategory1KeyList =
    categoryKeyList.map((key) => 'category_1$key').toList();
final List<String> registerCategory2KeyList =
    categoryKeyList.map((key) => 'category_2$key').toList();

class Register {
  int? id;
  int amount;
  Category? category; /*カテゴリーは後から必ずセットする*/
  Category? subCategory;
  String? memo;
  DateTime date;

  Register({
    this.id,
    required this.amount,
    required this.category,
    this.subCategory,
    this.memo,
    required this.date,
  });

  //dbデータからmodelへ変換
  Register.fromMap(Map map)
      : id = map[registerId],
        amount = map[registerAmount]!,
        category = Category.fromMap(Map.fromEntries(map.entries.where((entry) =>
            ((map[registerCategory2KeyList[0]] != null)
                    ? registerCategory2KeyList
                    : registerCategory1KeyList)
                .contains(entry.key)))),
        subCategory = (map[registerCategory2KeyList[0]] != null)
            ? Category.fromMap(Map.fromEntries(map.entries.where(
                (entry) => registerCategory1KeyList.contains(entry.key))))
            : null,
        memo = map[registerMemo],
        date = map[registerDate];

  Map<String, Object?> toMap() {
    int categoryId = (subCategory == null) ? category!.id! : subCategory!.id!;
    return {
      registerAmount: amount,
      registerCategoryId: categoryId,
      registerMemo: memo,
      registerDate: date.millisecondsSinceEpoch,
    };
  }

  Register copyWith(
      {int? amount,
      Category? category,
      Category? subCategory,
      String? memo,
      DateTime? date}) {
    return Register(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      memo: memo ?? this.memo,
      date: date ?? this.date,
    );
  }
}
