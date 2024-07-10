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
