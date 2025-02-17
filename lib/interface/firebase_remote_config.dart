import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String configPubAppVersion = "publish_app_version";

class CheckVersionHelper {
  //シングルトンパターン（インスタンスが1つで静的）
  static final CheckVersionHelper _instance = CheckVersionHelper._();
  factory CheckVersionHelper() => _instance;
  CheckVersionHelper._();

  static late final List<int> currentVersionList;
  static late final List<int> pubAppVersionList;

  static Future<bool> checkAppVersion() async {
    //現在のバージョン
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    debugPrint("version :${packageInfo.version}");

    // remote configから最新バージョン取得
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 12),
    ));
    await remoteConfig.setDefaults(const {
      configPubAppVersion: "1.0.0",
    });
    await remoteConfig.fetchAndActivate();

    String pubAppVersion = remoteConfig.getString(configPubAppVersion);

    debugPrint("pubAppVer : $pubAppVersion");

    currentVersionList =
        currentVersion.split('.').map((e) => int.parse(e)).toList();
    pubAppVersionList =
        pubAppVersion.split('.').map((e) => int.parse(e)).toList();

    bool needUpdate = false;
    for (int i = 0;
        i < currentVersionList.length || i < pubAppVersionList.length;
        i++) {
      if (currentVersionList[i] < pubAppVersionList[i]) {
        debugPrint('更新してください');
        needUpdate = true;
        break;
      }
    }
    return needUpdate;
  }
}
