import 'dart:io';
import '../utils/logger.dart';

class NetworkUtils {
  static Future<List<String>> getNetworkIPs() async {
    final addresses = <String>[];
    try {
      final interfaces = await NetworkInterface.list();
      log.i('Found ${interfaces.length} network interfaces');
      
      for (var interface in interfaces) {
        log.i('Scanning interface: ${interface.name}');
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
              log.i('Found subnet: $subnet.0/24 on ${interface.name}');
              addresses.addAll(await _generateIPsForSubnet(subnet));
            }
          }
        }
      }
    } catch (e) {
      log.e('Error getting network interfaces', error: e);
    }
    
    log.i('Generated ${addresses.length} possible IP addresses to scan');
    return addresses;
  }

  static Future<List<String>> _generateIPsForSubnet(String subnet) async {
    final ips = <String>[];
    for (var i = 1; i < 255; i++) {
      final ip = '$subnet.$i';
      ips.add(ip);
      log.d('Added IP to scan list: $ip');
    }
    return ips;
  }

  static Future<bool> isHostReachable(String ip, {Duration? timeout}) async {
    try {
      log.d('Pinging $ip...');
      final result = await Process.run(
        Platform.isWindows ? 'ping' : '/bin/ping',
        [
          Platform.isWindows ? '-n' : '-c',
          '1',
          Platform.isWindows ? '-w' : '-W',
          '1000',
          ip,
        ],
        stdoutEncoding: null,
        stderrEncoding: null,
      );
      
      final isReachable = result.exitCode == 0;
      if (isReachable) {
        log.i('✓ Host $ip is reachable');
      } else {
        log.d('✗ Host $ip is not reachable');
      }
      return isReachable;
    } catch (e) {
      log.w('Ping failed for $ip: $e');
      return false;
    }
  }
}
