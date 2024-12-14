import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)

abstract class Env {
  @EnviedField(varName: 'CONGRESS_API_KEY')
  static String congressApiKey = _Env.congressApiKey;
  @EnviedField(varName: 'CORS_PROXY_KEY')
  static String corsProxyKey = _Env.corsProxyKey;
  @EnviedField(varName: 'GEOCODIO_KEY')
  static String geocodioKey = _Env.geocodioKey;
}
