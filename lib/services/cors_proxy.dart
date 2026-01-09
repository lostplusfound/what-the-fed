import 'package:civic_project/env/env.dart';
import 'package:flutter/foundation.dart';

class CorsProxy {
  static final String _proxyUrl =
      'https://corsproxy.io/?key=${Env.corsProxyKey}&url=';
  static Uri proxyUrl(Uri url) {
    return (kIsWeb) ? Uri.parse('$_proxyUrl${Uri.encodeComponent(url.toString())}') : url;
  }

  static String proxyUrlString(String url) {
    return (kIsWeb) ? '$_proxyUrl${Uri.encodeComponent(url)}' : url;
  }
}
