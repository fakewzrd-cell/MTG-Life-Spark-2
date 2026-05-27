import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/network/local_ip_utils.dart';

void main() {
  test('prefers Wi-Fi interface private IPv4', () {
    final ip = pickBestLanIpv4([
      (name: 'pdp_ip0', addresses: ['10.0.0.1']),
      (name: 'en0', addresses: ['192.168.1.42']),
    ]);
    expect(ip, '192.168.1.42');
  });

  test('falls back to any private IPv4', () {
    final ip = pickBestLanIpv4([
      (name: 'random0', addresses: ['172.16.0.8']),
    ]);
    expect(ip, '172.16.0.8');
  });

  test('returns null when no usable IPv4', () {
    final ip = pickBestLanIpv4([
      (name: 'lo', addresses: ['not-an-ip']),
    ]);
    expect(ip, isNull);
  });
}
