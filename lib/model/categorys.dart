import 'package:flutter/material.dart';

class Category {
  final int id;
  final String name;
  final Icon icon;
  final int? parentId;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.parentId,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
    };
  }
}
