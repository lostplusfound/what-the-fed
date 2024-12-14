import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', useConstantCase: true, obfuscate: true)
abstract class Env {
  @EnviedField()
  static String congressApiKey = _Env.congressApiKey;
  @EnviedField()
  static String corsProxyKey = _Env.corsProxyKey;
  @EnviedField()
  static String geocodioKey = _Env.geocodioKey;
  @EnviedField()
  static String geminiKey = _Env.geminiKey;
}
