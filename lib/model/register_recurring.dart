import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';

//DBのパラメーター名
const String registerRecurringTable = 'register_recurring';
const String registerRecurringPrimaryId = '_id';
const String registerRecurringAmount = 'amount';
const String registerRecurringCategoryId = 'category_id';
const String registerRecurringMemo = 'memo';
const String registerRecurringDateStart = 'start_date';
const String registerRecurringDateEnd = 'end_date';
const String registerRecurringOrder = '_order';
const String registerRecurringSetting = 'recurring_setting';
const String registerRescheduleSetting = 'reschedule_setting';

//繰り返し設定
//クラス自体がnull非許容、対象外の時はnullではなく0で埋める
class RecurringSetting {
  int selectRecurring;
  List<int> recurringMonth;
  int criteria;
  List<int> recurringOrdinalWeek;
  List<int> recurringWeek;
  int recurringDate;
  int recurringInterval;
  RecurringSetting({
    required this.selectRecurring,
    required this.recurringMonth,
    required this.criteria,
    this.recurringOrdinalWeek = const <int>[0, 0, 0, 0, 0, 0], //第N週
    this.recurringWeek = const <int>[0, 0, 0, 0, 0, 0, 0], //1週間
    this.recurringDate = 0, //00~30
    this.recurringInterval = 0, //00~30
  });

  RecurringSetting.defaultState()
      : selectRecurring = 0,
        recurringMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        criteria = 0,
        recurringOrdinalWeek = [0, 0, 0, 0, 0, 0],
        recurringWeek = [0, 0, 0, 0, 0, 0, 0],
        recurringDate = 0,
        recurringInterval = 0;

  //31桁の数値(String)　→　RecurringSettingクラス　変換
  RecurringSetting.fromString(String requrringSettingString)
      : selectRecurring = int.parse(requrringSettingString.substring(0, 1)),
        recurringMonth = requrringSettingString
            .substring(1, 13)
            .split('')
            .map((item) => int.parse(item))
            .toList(),
        criteria = int.parse(requrringSettingString.substring(13, 14)),
        recurringOrdinalWeek = requrringSettingString
            .substring(14, 20)
            .split('')
            .map((item) => int.parse(item))
            .toList(),
        recurringWeek = requrringSettingString
            .substring(20, 27)
            .split('')
            .map((item) => int.parse(item))
            .toList(),
        recurringDate = int.parse(requrringSettingString.substring(27, 29)),
        recurringInterval = int.parse(requrringSettingString.substring(29, 31));

  //RecurringSettingクラス　→　31桁の数値(String)　変換
  String recurringSettingtoString() {
    return selectRecurring.toString().padLeft(1, '0') +
        recurringMonth.map((e) => e.toString()).join() +
        criteria.toString().padLeft(1, '0') +
        recurringOrdinalWeek.map((e) => e.toString()).join() +
        recurringWeek.map((e) => e.toString()).join() +
        recurringDate.toString().padLeft(2, '0') +
        recurringInterval.toString().padLeft(2, '0');
  }

  RecurringSetting copyWith({
    int? selectRecurring,
    List<int>? recurringMonth,
    int? criteria,
    List<int>? recurringOrdinalWeek,
    List<int>? recurringWeek,
    int? recurringDate,
    int? recurringInterval,
  }) {
    return RecurringSetting(
      selectRecurring: selectRecurring ?? this.selectRecurring,
      recurringMonth: recurringMonth ?? this.recurringMonth,
      criteria: criteria ?? this.criteria,
      recurringOrdinalWeek: recurringOrdinalWeek ?? this.recurringOrdinalWeek,
      recurringWeek: recurringWeek ?? this.recurringWeek,
      recurringDate: recurringDate ?? this.recurringDate,
      recurringInterval: recurringInterval ?? this.recurringInterval,
    );
  }

  RecurringSetting copyWithRecurringMonthChange({
    required int index,
  }) {
    List<int> newList = List.from(recurringMonth);
    //逆の値を取得（0→1,1→1）
    newList[index] = 1 - newList[index];
    return RecurringSetting(
      selectRecurring: selectRecurring,
      recurringMonth: newList,
      criteria: criteria,
      recurringOrdinalWeek: recurringOrdinalWeek,
      recurringWeek: recurringWeek,
      recurringDate: recurringDate,
      recurringInterval: recurringInterval,
    );
  }

  RecurringSetting copyWithRecurringOrdinalWeekChange({
    required int index,
  }) {
    List<int> newList = List.from(recurringOrdinalWeek);
    //逆の値を取得（0→1,1→1）
    newList[index] = 1 - newList[index];
    return RecurringSetting(
      selectRecurring: selectRecurring,
      recurringMonth: recurringMonth,
      criteria: criteria,
      recurringOrdinalWeek: newList,
      recurringWeek: recurringWeek,
      recurringDate: recurringDate,
      recurringInterval: recurringInterval,
    );
  }

  RecurringSetting copyWithRecurringWeekChange({
    required int week,
  }) {
    List<int> newList = List.from(recurringWeek);
    //逆の値を取得（0→1,1→1）
    newList[week] = 1 - newList[week];
    return RecurringSetting(
      selectRecurring: selectRecurring,
      recurringMonth: recurringMonth,
      criteria: criteria,
      recurringOrdinalWeek: recurringOrdinalWeek,
      recurringWeek: newList,
      recurringDate: recurringDate,
      recurringInterval: recurringInterval,
    );
  }
}

//
//振替設定
//クラス自体がnull許容
//9桁の数値(String)
class RescheduleSetting {
  List<int> rescheduleTarget;
  int rescheduleWay;
  RescheduleSetting({
    required this.rescheduleTarget,
    required this.rescheduleWay,
  });

  RescheduleSetting.defaultState()
      : rescheduleTarget = [0, 0, 0, 0, 0, 0, 0, 0],
        rescheduleWay = 0;

  RescheduleSetting copyWith({
    List<int>? rescheduleTarget,
    int? rescheduleWay,
  }) {
    return RescheduleSetting(
        rescheduleTarget: rescheduleTarget ?? this.rescheduleTarget,
        rescheduleWay: rescheduleWay ?? this.rescheduleWay);
  }

  RescheduleSetting copyWithRescheduleTargetChange({
    required int index,
  }) {
    List<int> newList = List.from(rescheduleTarget);
    //逆の値を取得（0→1,1→1）
    newList[index] = 1 - newList[index];
    return RescheduleSetting(
      rescheduleTarget: newList,
      rescheduleWay: rescheduleWay,
    );
  }

  RescheduleSetting.fromString(String requrringSettingString)
      : rescheduleTarget = requrringSettingString
            .substring(0, 8)
            .split('')
            .map((item) => int.parse(item))
            .toList(),
        rescheduleWay = int.parse(requrringSettingString.substring(8, 9));

  String rescheduleSettingtoString() {
    return rescheduleTarget.map((e) => e.toString()).join() +
        rescheduleWay.toString().padLeft(1, '0');
  }
}

//
//主体
class RegisterRecurring {
  int? id;
  int? amount;
  Category? category; /*カテゴリーは後から必ずセットする 親カテゴリーのみはサブカテゴリーなし*/
  Category? subCategory;
  String? memo;
  DateTime startDate;
  DateTime? endDate;
  int? order;
  RecurringSetting recurringSetting;
  RescheduleSetting rescheduleSetting;

  RegisterRecurring({
    this.id,
    required this.amount,
    required this.category,
    this.subCategory,
    required this.memo,
    required this.startDate,
    required this.endDate,
    this.order,
    required this.recurringSetting,
    required this.rescheduleSetting,
  });

  RegisterRecurring.initialState()
      : id = null,
        amount = null,
        category = null,
        subCategory = null,
        memo = null,
        startDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        endDate = null,
        order = null,
        recurringSetting = RecurringSetting.defaultState(),
        rescheduleSetting = RescheduleSetting.defaultState();

  //dbデータからmodelへ変換
  RegisterRecurring.fromMap(Map map)
      : id = map[registerRecurringPrimaryId],
        amount = map[registerRecurringAmount]!,
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
        memo = map[registerRecurringMemo],
        startDate = DateTime.fromMillisecondsSinceEpoch(
            map[registerRecurringDateStart]),
        endDate = (map[registerRecurringDateEnd] != null)
            ? DateTime.fromMillisecondsSinceEpoch(map[registerRecurringDateEnd])
            : null,
        order = map[registerRecurringOrder],
        recurringSetting =
            RecurringSetting.fromString(map[registerRecurringSetting]),
        rescheduleSetting =
            RescheduleSetting.fromString(map[registerRescheduleSetting]);

  Map<String, Object?> toMap() {
    int categoryId = (subCategory == null) ? category!.id! : subCategory!.id!;
    return {
      registerRecurringAmount: amount,
      registerRecurringCategoryId: categoryId,
      registerRecurringMemo: memo,
      registerRecurringDateStart: startDate.millisecondsSinceEpoch,
      registerRecurringDateEnd: endDate?.millisecondsSinceEpoch,
      registerRecurringOrder: order,
      registerRecurringSetting: recurringSetting.recurringSettingtoString(),
      registerRescheduleSetting: rescheduleSetting.rescheduleSettingtoString(),
    };
  }

  RegisterRecurring copyWith({
    int? id,
    int? amount,
    Category? category,
    Category? subCategory,
    String? memo,
    DateTime? startDate,
    DateTime? endDate,
    RecurringSetting? recurringSetting,
    RescheduleSetting? rescheduleSetting,
  }) {
    return RegisterRecurring(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      memo: memo ?? this.memo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      order: order,
      recurringSetting: recurringSetting ?? this.recurringSetting,
      rescheduleSetting: rescheduleSetting ?? this.rescheduleSetting,
    );
  }

  RegisterRecurring copyWithUpdate({
    required int amount,
    required Category category,
    required Category? subCategory,
    required String memo,
    required DateTime startDate,
    required DateTime? endDate,
    required RecurringSetting recurringSetting,
    required RescheduleSetting rescheduleSetting,
  }) {
    return RegisterRecurring(
      id: id,
      amount: amount,
      category: category,
      subCategory: subCategory,
      memo: memo,
      startDate: startDate,
      endDate: endDate,
      order: order,
      recurringSetting: recurringSetting,
      rescheduleSetting: rescheduleSetting,
    );
  }
}
