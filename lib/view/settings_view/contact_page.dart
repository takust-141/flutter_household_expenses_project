import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/interface/send_mail_helper.dart';

//-------問い合わせページ---------------------------
class ContactFormPage extends HookConsumerWidget {
  const ContactFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final textController = useTextEditingController();
    final textFocusNode = useFocusNode();
    final isActiveButton = useState<bool>(false);

    isActiveButtonChange() =>
        {isActiveButton.value = textController.text.isNotEmpty};

    useEffect(() {
      textController.addListener(isActiveButtonChange);
      return () {
        textController.removeListener(isActiveButtonChange);
      };
    }, []);

    return SafeArea(
      child: GestureDetector(
        onTap: () => textFocusNode.unfocus(),
        child: Container(
          padding: mediumEdgeInsets,
          color: theme.colorScheme.surfaceContainer,
          child: Form(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "アプリに対するご意見、ご要望、ご感想など\nお気軽にご記入ください",
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: medium),
                TextField(
                  focusNode: textFocusNode,
                  controller: textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: large + large),
                Padding(
                  padding: EdgeInsets.zero,
                  child: TextButton(
                    onPressed: isActiveButton.value
                        ? () {
                            bool isError = false;
                            textFocusNode.unfocus();
                            try {
                              SendMailHelper().call(
                                subject: "家計簿アプリ_問い合わせ",
                                text: textController.text,
                              );
                            } catch (e) {
                              isError = true;
                              debugPrint(e.toString());
                            } finally {
                              //スナックバー表示
                              if (context.mounted) {
                                updateSnackBarCallBack(
                                  text: isError
                                      ? '問い合わせを送信に失敗しました'
                                      : '問い合わせを送信しました',
                                  context: context,
                                  isError: isError,
                                  ref: ref,
                                );
                              }
                              Navigator.of(context).pop();
                            }
                          }
                        : null,
                    style: TextButton.styleFrom(
                      fixedSize:
                          const Size(double.maxFinite, registerButtonHeight),
                      padding: smallEdgeInsets,
                      overlayColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: Color.lerp(
                          theme.colorScheme.primary,
                          theme.colorScheme.surface,
                          0.7),
                      disabledForegroundColor: Color.lerp(
                          theme.colorScheme.onPrimary,
                          theme.colorScheme.surface,
                          0.7),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: registerButtomRadius,
                      ),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontSize:
                              (theme.textTheme.titleMedium?.fontSize ?? 0) + 2),
                    ),
                    child: const AutoSizeText(
                      "送　　信",
                      maxLines: 1,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
