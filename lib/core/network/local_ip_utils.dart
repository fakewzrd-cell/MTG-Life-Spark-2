/// Picks the best LAN IPv4 from [NetworkInterface]-like name + address pairs.
String? pickBestLanIpv4(
  Iterable<({String name, Iterable<String> addresses})> interfaces,
) {
  String? best;
  var bestScore = -1;

  for (final iface in interfaces) {
    final name = iface.name.toLowerCase();
    final nameScore = _interfaceNameScore(name);
    for (final address in iface.addresses) {
      if (!_looksLikeIpv4(address)) continue;
      final ipScore = _privateLanScore(address);
      if (ipScore < 0) continue;
      final score = nameScore + ipScore;
      if (score > bestScore) {
        bestScore = score;
        best = address;
      }
    }
  }
  return best;
}

int _interfaceNameScore(String name) {
  if (name.startsWith('wlan') || name.startsWith('wifi')) return 40;
  if (name.startsWith('en')) return 30;
  if (name.startsWith('eth')) return 25;
  if (name.contains('wifi')) return 20;
  return 0;
}

int _privateLanScore(String ip) {
  final parts = ip.split('.');
  if (parts.length != 4) return -1;
  final octets = parts.map(int.tryParse).toList();
  if (octets.any((o) => o == null || o! < 0 || o > 255)) return -1;
  final a = octets[0]!;
  final b = octets[1]!;
  if (a == 10) return 30;
  if (a == 172 && b >= 16 && b <= 31) return 30;
  if (a == 192 && b == 168) return 30;
  // Non-private IPv4 is a last resort (e.g. hotspot quirks).
  return 5;
}

bool _looksLikeIpv4(String ip) => RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(ip);
