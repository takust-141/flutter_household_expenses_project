import 'package:household_expense_project/model/category.dart';

const String registerTable = 'register';
const String registerId = '_id';
const String registerAmount = 'amount';
const String registerCategoryId = 'category_id';
const String registerMemo = 'memo';
const String registerDate = 'date';
const String registerRecurringId = 'recurring_id';
const String registerRegistrationDate = 'registration_date';
const String registerUpdateDate = 'update_date';

final List<String> registerCategory1KeyList =
    categoryKeyList.map((key) => 'category_1_$key').toList();
final List<String> registerCategory2KeyList =
    categoryKeyList.map((key) => 'category_2_$key').toList();

class Register {
  int? id;
  int amount;
  Category? category; /*カテゴリーは後から必ずセットする 親カテゴリーのみはサブカテゴリーなし*/
  Category? subCategory;
  String? memo;
  DateTime date;
  int? recurringId;
  DateTime registrationDate;
  DateTime? updateDate;

  Register({
    this.id,
    required this.amount,
    required this.category,
    this.subCategory,
    this.memo,
    required this.date,
    this.recurringId,
    required this.registrationDate,
    this.updateDate,
  });

  //dbデータからmodelへ変換
  Register.fromMap(Map map)
      : id = map[registerId],
        amount = map[registerAmount]!,
        category = Category.fromMap(
            Map.fromEntries(map.entries.where((entry) =>
                ((map[registerCategory2KeyList[0]] != null)
                        ? registerCategory2KeyList
                        : registerCategory1KeyList)
                    .contains(entry.key))),
            mapKeyList: (map[registerCategory2KeyList[0]] != null)
                ? registerCategory2KeyList
                : registerCategory1KeyList),
        subCategory = (map[registerCategory2KeyList[0]] != null)
            ? Category.fromMap(
                Map.fromEntries(map.entries.where(
                    (entry) => registerCategory1KeyList.contains(entry.key))),
                mapKeyList: registerCategory1KeyList)
            : null,
        memo = map[registerMemo],
        date = DateTime.fromMillisecondsSinceEpoch(map[registerDate]),
        recurringId = map[registerRecurringId],
        registrationDate =
            DateTime.fromMillisecondsSinceEpoch(map[registerRegistrationDate]),
        updateDate = (map[registerUpdateDate] != null)
            ? DateTime.fromMillisecondsSinceEpoch(map[registerUpdateDate])
            : null;

  Map<String, Object?> toMap() {
    int categoryId = (subCategory == null) ? category!.id! : subCategory!.id!;
    return {
      registerAmount: amount,
      registerCategoryId: categoryId,
      registerMemo: memo,
      registerDate: date.millisecondsSinceEpoch,
      registerRecurringId: recurringId,
      registerRegistrationDate: registrationDate.millisecondsSinceEpoch,
      registerUpdateDate: updateDate?.millisecondsSinceEpoch,
    };
  }

  Register copyWith({
    int? amount,
    Category? category,
    Category? subCategory,
    String? memo,
    DateTime? date,
  }) {
    return Register(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      recurringId: recurringId,
      registrationDate: registrationDate,
      updateDate: updateDate,
    );
  }
}
