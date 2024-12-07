import 'package:flutter/foundation.dart';

class CorsProxy {
  static Uri proxyUrl(Uri url) {
    return (kIsWeb)
        ? Uri.parse('https://corsproxy.io/?${url.toString()}')
        : url;
  }

  static String proxyUrlString(String url) {
    return (kIsWeb) ? 'https://corsproxy.io/?${url.toString()}' : url;
  }
}
