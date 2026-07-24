import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/network/session_link_status.dart';

void main() {
  test('reconnect grace covers typical app-switch duration', () {
    expect(kSessionReconnectGrace.inSeconds, greaterThanOrEqualTo(60));
    expect(kSessionReconnectGrace.inSeconds, lessThanOrEqualTo(180));
  });
}
