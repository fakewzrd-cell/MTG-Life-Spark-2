import 'dart:async';
import 'dart:io';

import '../debug/app_log.dart';
import 'local_ip_utils.dart';

/// Returns the device's local WiFi/LAN IPv4 address, or null if unavailable.
Future<String?> getLocalIpAddress() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    ).timeout(const Duration(seconds: 4));

    return pickBestLanIpv4(
      interfaces.map(
        (iface) => (
          name: iface.name,
          addresses: iface.addresses
              .where((a) => !a.isLoopback)
              .map((a) => a.address),
        ),
      ),
    );
  } on TimeoutException {
    return null;
  } catch (e, st) {
    appLog('getLocalIpAddress failed', error: e, stackTrace: st);
    return null;
  }
}
