import 'package:flutter/foundation.dart';

class CorsProxy {
  static const String _proxyUrl = 'https://corsproxy.io/?key=2ae3149d&url=';
  static Uri proxyUrl(Uri url) {
    return (kIsWeb) ? Uri.parse('$_proxyUrl${url.toString()}') : url;
  }

  static String proxyUrlString(String url) {
    return (kIsWeb) ? '$_proxyUrl$url' : url;
  }
}
