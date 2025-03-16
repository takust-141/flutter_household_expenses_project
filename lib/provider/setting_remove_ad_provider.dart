import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/ad_helper.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/env/env.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

//Provider
final settingRemoveAdProvider =
    AsyncNotifierProvider<SettingRemoveAdNotifier, SettingRemoveAdState>(
        SettingRemoveAdNotifier.new);

//productの状態
enum ProductState { purchased, availablePurchase, notAvailablePurchase }

//状態管理
@immutable
class SettingRemoveAdState {
  final ProductState removedAdProductState;
  final Package? package;

  const SettingRemoveAdState({
    required this.removedAdProductState,
    required this.package,
  });

  SettingRemoveAdState copyWith({
    ProductState? removedAdProductState,
    Package? package,
  }) {
    return SettingRemoveAdState(
      removedAdProductState:
          removedAdProductState ?? this.removedAdProductState,
      package: package ?? this.package,
    );
  }

  const SettingRemoveAdState.defaultState()
      : removedAdProductState = ProductState.notAvailablePurchase,
        package = null;
}

//Notifier
class SettingRemoveAdNotifier extends AsyncNotifier<SettingRemoveAdState> {
  @override
  Future<SettingRemoveAdState> build() async {
    //初期化
    //consoleへのdebug log設定
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration? configuration;
    Package? package;
    ProductState removedAdProductState = ProductState.notAvailablePurchase;

    if (Platform.isAndroid) {
      //Android用のRevenuecat APIキーをセット
      configuration = PurchasesConfiguration(Env.revenuecatPlayStoreKey);
    } else if (Platform.isIOS) {
      //ios用のRevenuecat APIキーをセット
      configuration = PurchasesConfiguration(Env.revenuecatAppleStoreKey);
    }
    if (configuration != null) {
      //初期設定
      await Purchases.configure(configuration);

      //オファリング→パッケージ取得
      try {
        final Offerings offerings = await Purchases.getOfferings();
        if (offerings.current?.availablePackages.isNotEmpty == true &&
            offerings.current!.lifetime != null) {
          //デフォルトオファリングのパッケージ取得成功
          package = offerings.current!.lifetime!;
          final isPurchased = await getPurchasesStatus();
          if (isPurchased) {
            removedAdProductState = ProductState.purchased;
          } else {
            removedAdProductState = ProductState.availablePurchase;
          }
        }
      } on PlatformException catch (e) {
        debugPrint(e.message);
      }
    }

    return SettingRemoveAdState(
      removedAdProductState: removedAdProductState,
      package: package,
    );
  }

  //購入ステータスの確認
  Future<bool> getPurchasesStatus() async {
    bool isPurchased = false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all["default"]?.isActive ?? false) {
        isPurchased = true;
      }
    } on PlatformException catch (e) {
      // Error fetching customer info
      debugPrint(e.toString());
    }
    return isPurchased;
  }

  //購入
  Future<void> purchase(BuildContext context) async {
    final Package? package = state.valueOrNull?.package;
    if (state.valueOrNull?.removedAdProductState == ProductState.purchased) {
      //購入済みの場合
      if (context.mounted) {
        updateSnackBarCallBack(
          text: '購入済みです',
          context: context,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
      return;
    }

    state = const AsyncLoading<SettingRemoveAdState>().copyWithPrevious(state);
    final preState = state.valueOrNull ?? SettingRemoveAdState.defaultState();

    if (package != null &&
        state.valueOrNull?.removedAdProductState ==
            ProductState.availablePurchase) {
      //購入処理
      try {
        CustomerInfo customerInfo = await Purchases.purchasePackage(package);
        if (customerInfo.entitlements.all["default"]?.isActive ?? false) {
          //購入の正常終了時
          state = AsyncData(
              (state.valueOrNull ?? SettingRemoveAdState.defaultState())
                  .copyWith(removedAdProductState: ProductState.purchased));
          ref.read(adNotifierProvider.notifier).removeAd();
        }
      } on PlatformException catch (e) {
        var errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          //キャンセルした時
          state = AsyncData(preState);
          if (context.mounted) {
            updateSnackBarCallBack(
              text: '購入がキャンセルされました',
              context: context,
              ref: ref,
              isNotNeedBottomHeight: true,
            );
          }
        } else if (errorCode == PurchasesErrorCode.networkError) {
          //ネットワークエラー
          state = AsyncData(preState);
          if (context.mounted) {
            updateSnackBarCallBack(
              text: 'ネットワークエラーが発生しました',
              context: context,
              ref: ref,
              isNotNeedBottomHeight: true,
            );
          }
        } else {
          //それ以外のエラー
          debugPrint(e.toString());
          state = AsyncData(SettingRemoveAdState.defaultState());
          if (context.mounted) {
            updateSnackBarCallBack(
              text: 'エラーが発生しました',
              context: context,
              ref: ref,
              isNotNeedBottomHeight: true,
            );
          }
        }
      }
    } else {
      debugPrint("対象の商品が見つかりませんでした");
      state = AsyncData(SettingRemoveAdState.defaultState());
      if (context.mounted) {
        updateSnackBarCallBack(
          text: 'ストアに接続できませんでした',
          context: context,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //リストア
  Future<void> restore(BuildContext context) async {
    if (state.valueOrNull?.removedAdProductState == ProductState.purchased) {
      //購入済みの場合
      if (context.mounted) {
        updateSnackBarCallBack(
          text: '購入済みです',
          context: context,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
      return;
    }

    state = const AsyncLoading<SettingRemoveAdState>().copyWithPrevious(state);
    final preState = state.valueOrNull ?? SettingRemoveAdState.defaultState();

    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      //購入情報の確認
      if (customerInfo.entitlements.all["default"]?.isActive ?? false) {
        state = AsyncData(
            preState.copyWith(removedAdProductState: ProductState.purchased));
        ref.read(adNotifierProvider.notifier).removeAd();
      } else {
        //未購入
        state = AsyncData(preState);
      }
      if (context.mounted) {
        updateSnackBarCallBack(
          text: '復元が完了しました',
          context: context,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        //キャンセルした時
        state = AsyncData(preState);
        if (context.mounted) {
          updateSnackBarCallBack(
            text: '購入をキャンセルしました',
            context: context,
            ref: ref,
            isNotNeedBottomHeight: true,
          );
        }
      } else if (errorCode == PurchasesErrorCode.networkError) {
        //ネットワークエラー
        state = AsyncData(preState);
        if (context.mounted) {
          updateSnackBarCallBack(
            text: 'ネットワークエラーが発生しました',
            context: context,
            ref: ref,
            isNotNeedBottomHeight: true,
          );
        }
      } else {
        //それ以外のエラー
        debugPrint(e.toString());
        state = AsyncData(SettingRemoveAdState.defaultState());
        if (context.mounted) {
          updateSnackBarCallBack(
            text: 'エラーが発生しました',
            context: context,
            ref: ref,
            isNotNeedBottomHeight: true,
          );
        }
      }
    }
  }
}
