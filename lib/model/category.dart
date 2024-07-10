const String categoryTable = 'category';
const String categoryId = '_id';
const String categoryName = 'name';
const String categoryIconName = 'icon_name';
const String categoryColor = 'color';
const String categotyParentId = 'parent_id';
const String categoryOrder = 'order';

class Category {
  int? id;
  String name;
  String? iconName;
  String? color;
  int? parentId;
  int? order;

  Category({
    required this.name,
    this.iconName,
    this.color,
    this.parentId,
    this.order,
  });

  Category.fromMap(Map map)
      : id = map[categoryId],
        name = map[categoryName]!,
        iconName = map[categoryIconName]!,
        color = map[categoryColor]!,
        parentId = map[categotyParentId],
        order = map[categoryOrder];

  Map<String, Object?> toMap() {
    return {
      categoryName: name,
      categoryIconName: iconName,
      categotyParentId: parentId,
      categoryOrder: order,
    };
  }
}
