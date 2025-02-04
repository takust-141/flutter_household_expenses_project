import 'package:intl/intl.dart';

//汎用ロジック

//汎用年月比較
class LogicComponent {
  static bool matchDates(DateTime? date1, DateTime? date2) {
    if (date1?.year == date2?.year &&
        date1?.month == date2?.month &&
        date1?.day == date2?.day) {
      return true;
    }
    return false;
  }

  static bool isBeforeDate(DateTime date1, DateTime date2) {
    return (date1.year < date2.year ||
        (date1.year == date2.year && date1.month < date2.month) ||
        (date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day < date2.day));
  }

  static bool matchMonth(DateTime date1, DateTime date2) {
    return (date1.year == date2.year && date1.month == date2.month);
  }

  static bool isBeforeMonth(DateTime date1, DateTime date2) {
    return (date1.year < date2.year ||
        (date1.year == date2.year && date1.month < date2.month));
  }

  //0：一致、1：<、2：>
  static int compMonth(DateTime date1, DateTime date2) {
    if (date1.year == date2.year && date1.month == date2.month) {
      return 0;
    } else if (isBeforeMonth(date1, date2)) {
      return 1;
    } else {
      return 2;
    }
  }

  static int compYear(DateTime date1, DateTime date2) {
    if (date1.year == date2.year) {
      return 0;
    } else if (isBeforeMonth(date1, date2)) {
      return 1;
    } else {
      return 2;
    }
  }

  //0：範囲内、1：startDateより前、2：endDateより後
  static int isDateInRange(
      DateTime targetDate, DateTime startDate, DateTime endDate) {
    if (targetDate.isBefore(startDate)) {
      return 1;
    } else if (targetDate.isAfter(endDate)) {
      return 2;
    } else {
      return 0;
    }
  }

  //カンマ付与
  static final formatter = NumberFormat("#,###");
  static String addCommaToNum(int? num) {
    if (num == null) {
      return "";
    }
    final numWithComma = formatter.format(num);
    return numWithComma;
  }
}
