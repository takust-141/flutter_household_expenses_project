import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'REVENUECAT_SDK_API_APPLE_STORE_KEY', obfuscate: true)
  static String revenuecatAppleStoreKey = _Env.revenuecatAppleStoreKey;
  @EnviedField(varName: 'REVENUECAT_SDK_API_PLAY_STORE_KEY', obfuscate: true)
  static String revenuecatPlayStoreKey = _Env.revenuecatPlayStoreKey;
}
