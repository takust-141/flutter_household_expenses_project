import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/keyboard_components.dart';

const String categoryTable = 'category';
const String categoryId = '_id';
const String categoryName = 'name';
const String categoryIcon = 'icon';
const String categoryColor = 'color';
const String categotyParentId = 'parent_id';
const String categoryOrder = '_order';

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

  Category({
    required this.name,
    required this.icon,
    required this.color,
    this.id,
    this.parentId,
    required this.order,
  });

  Category.fromMap(Map map)
      : id = map[categoryId],
        name = map[categoryName]!,
        icon = getCategoryIcon(map[categoryIcon]),
        color = getCategoryColor(map[categoryColor]),
        parentId = map[categotyParentId],
        order = map[categoryOrder];

  Map<String, Object?> toMap() {
    return {
      categoryName: name,
      categoryIcon: icon.toString(),
      categoryColor: color.toString(),
      categotyParentId: parentId,
      categoryOrder: order,
    };
  }

  static IconData getCategoryIcon(String value) {
    return categoryIcons[value] ?? categoryIcons['default']!;
  }

  static Color getCategoryColor(String value) {
    return categoryColors[value] ?? categoryColors['default']!;
  }

  Category copyWith({String? name, IconData? icon, Color? color}) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId,
      order: order,
    );
  }
}
