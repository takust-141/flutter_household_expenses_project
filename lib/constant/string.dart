//register_page

const String currencyUnit = "円";

const String labelOutgo = "支出";
const String labelIncome = "収入";

//四則演算
enum MathSymbol {
  sum(value: "+"),
  diff(value: "-"),
  multiplication(value: "x"),
  division(value: "÷");

  final String value;
  const MathSymbol({required this.value});
}

//エラーメッセージ
const String dbError = "データの読み込みに失敗しました。開発者に問い合わせしてください。";

//カテゴリー削除
const String moveCategoryTitle = "移行";
const String delCategoryTitle = "削除";

const String moveDialogText =
    "に登録されているデータを別のカテゴリーに移行します。\n（サブカテゴリーがある場合はサブカテゴリーも移行されます）\n移行先のカテゴリーを選択してください。";
const String delSubDialogText = "に紐づくデータは全て削除されます。（定期収支も含む）\nよろしいですか？";
const String delDialogText =
    "に紐づくデータは全て削除されます。（サブカテゴリーに紐づくデータ、定期収支を含む）\nよろしいですか？";
