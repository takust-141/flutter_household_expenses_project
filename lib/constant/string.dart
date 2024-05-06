//register_page

const String currencyUnit = "円";

const String labelOutgo = "支出";
const String labelIncome = "収入";

//四則演算
enum MathSymbol {
  sum(value: "+"),
  diff(value: "-"),
  multiplication(value: "x");

  final String value;
  const MathSymbol({required this.value});
}
