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

  static bool matchMonth(DateTime date1, DateTime date2) {
    if (date1.year == date2.year && date1.month == date2.month) {
      return true;
    }
    return false;
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
