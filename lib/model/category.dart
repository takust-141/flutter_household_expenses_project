import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/keyboard_components.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';

const String categoryTable = 'category';
const String categoryId = '_id';
const String categoryName = 'name';
const String categoryIcon = 'icon';
const String categoryColor = 'color';
const String categoryParentId = 'parent_id';
const String categoryOrder = '_order';
const String categoryExpenses = 'expenses';

const List<String> categoryKeyList = [
  categoryId,
  categoryName,
  categoryIcon,
  categoryColor,
  categoryParentId,
  categoryOrder,
  categoryExpenses
];

final Map<String, Color> categoryColors = {
  for (var color in keyboardColors) color.toString(): color,
  'default': keyboardColors[0],
};

final Map<String, IconData> categoryIcons = {
  for (var icon in keyboardIcons) icon.toString(): icon,
  'default': keyboardIcons[0],
};

class Category {
  int? id;
  String name;
  IconData icon;
  Color color;
  int? parentId;
  int order;
  SelectExpenses expenses;

  Category({
    required this.name,
    required this.icon,
    required this.color,
    this.id,
    this.parentId,
    required this.order,
    required this.expenses,
  });

  Category.fromMap(Map map, {List<String>? mapKeyList})
      : id = map[mapKeyList?[0] ?? categoryKeyList[0]],
        name = map[mapKeyList?[1] ?? categoryKeyList[1]]!,
        icon = getCategoryIcon(map[mapKeyList?[2] ?? categoryKeyList[2]]),
        color = getCategoryColor(map[mapKeyList?[3] ?? categoryKeyList[3]]),
        parentId = map[mapKeyList?[4] ?? categoryKeyList[4]],
        order = map[mapKeyList?[5] ?? categoryKeyList[5]],
        expenses = SelectExpenses.values
            .byName(map[mapKeyList?[6] ?? categoryKeyList[6]]);

  Map<String, Object?> toMap() {
    return {
      categoryName: name,
      categoryIcon: icon.toString(),
      categoryColor: color.toString(),
      categoryParentId: parentId,
      categoryOrder: order,
      categoryExpenses: expenses.name,
    };
  }

  static IconData getCategoryIcon(String value) {
    return categoryIcons[value] ?? categoryIcons['default']!;
  }

  static Color getCategoryColor(String value) {
    return categoryColors[value] ?? categoryColors['default']!;
  }

  Category copyWith(
      {String? name, IconData? icon, Color? color, SelectExpenses? expenses}) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId,
      order: order,
      expenses: expenses ?? this.expenses,
    );
  }
}
