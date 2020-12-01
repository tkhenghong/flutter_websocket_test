import 'dart:io';

import 'package:flutter/services.dart';

class CustomHttpOverrides extends HttpOverrides {
  List<String> allowedHost = [];

  ByteData byteData;

  CustomHttpOverrides(ByteData byteData) {
    this.byteData = byteData;
  }

  @override
  HttpClient createHttpClient(SecurityContext context) {
    context = new SecurityContext();
    context.setTrustedCertificatesBytes(this.byteData.buffer.asUint8List()); // If your cert has password (Eg. .p12 files), you may type password as optional parameter.
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (allowedHost.contains(host)) {
          return true;
        }
        return false;
      };
  }
}
