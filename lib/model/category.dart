import 'package:flutter/material.dart';
import 'package:household_expense_project/constant/keyboard_components.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';

const String categoryTable = 'category';
const String categoryId = '_id';
const String categoryName = 'name';
const String categoryIcon = 'icon';
const String categoryColor = 'color';
const String categoryParentId = 'parent_id';
const String categoryOrder = '_order';
const String categoryExpense = 'expense';

const List<String> categoryKeyList = [
  categoryId,
  categoryName,
  categoryIcon,
  categoryColor,
  categoryParentId,
  categoryOrder,
  categoryExpense
];

class Category {
  int? id;
  String name;
  IconData icon;
  Color color;
  int? parentId;
  int order;
  SelectExpense expense;

  Category({
    required this.name,
    required this.icon,
    required this.color,
    this.id,
    this.parentId,
    required this.order,
    required this.expense,
  });

  Category.fromMap(Map map, {List<String>? mapKeyList})
      : id = map[mapKeyList?[0] ?? categoryKeyList[0]],
        name = map[mapKeyList?[1] ?? categoryKeyList[1]]!,
        icon = getCategoryIcon(map[mapKeyList?[2] ?? categoryKeyList[2]]),
        color = getCategoryColor(map[mapKeyList?[3] ?? categoryKeyList[3]]),
        parentId = map[mapKeyList?[4] ?? categoryKeyList[4]],
        order = map[mapKeyList?[5] ?? categoryKeyList[5]],
        expense = SelectExpense.values
            .byName(map[mapKeyList?[6] ?? categoryKeyList[6]]);

  Map<String, Object?> toMap() {
    return {
      categoryName: name,
      categoryIcon: icon.codePoint.toString(),
      categoryColor: color.toARGB32().toString(),
      categoryParentId: parentId,
      categoryOrder: order,
      categoryExpense: expense.name,
    };
  }

  static IconData getCategoryIcon(String value) {
    return categoryIcons[value] ?? categoryIcons['default']!;
  }

  static Color getCategoryColor(String value) {
    return categoryColors[value] ?? categoryColors['default']!;
  }

  Category copyWith(
      {String? name,
      IconData? icon,
      Color? color,
      int? order,
      SelectExpense? expense}) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId,
      order: order ?? this.order,
      expense: expense ?? this.expense,
    );
  }
}
