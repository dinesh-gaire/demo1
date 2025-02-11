import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/device_info.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/data/models.dart';
import '../utils/image_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';

class DeviceDiscovery {
  static const int APP_PORT = 43721; // Uncommon port for app communication
  final ObjectBox objectBox;

  DeviceDiscovery(this.objectBox);

  Future<bool> _checkPermissions() async {
    // Request location permission first
    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      log.w('Location permission denied');
      return false;
    }

    // Only request nearby devices permission on Android 13+ (SDK 33+)
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidVersion();
      if (sdkVersion >= 33) {
        final nearbyDevicesStatus =
            await Permission.nearbyWifiDevices.request();
        if (!nearbyDevicesStatus.isGranted) {
          log.w('Nearby devices permission denied');
          return false;
        }
      }
    }

    log.i('All required permissions granted');
    return true;
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt; // This is already non-nullable
    }
    return 0;
  }

  Future<List<DeviceInfo>> scanNetwork() async {
    final hasPermissions = await _checkPermissions();
    if (!hasPermissions) {
      throw Exception('Required permissions are not granted');
    }

    final List<DeviceInfo> discoveredDevices = [];

    try {
      log.i('Starting network scan...');

      final info = NetworkInfo();
      final ip = await info.getWifiIP();
      if (ip == null) {
        throw Exception('Could not detect device IP address');
      }

      final subnet = ip.substring(0, ip.lastIndexOf('.'));
      log.i('Scanning subnet: $subnet.*');
      final stream = NetworkAnalyzer.i.discover2(
        subnet,
        APP_PORT,
        timeout: const Duration(milliseconds: 400),
      );

      await for (final host in stream) {
        if (host.exists) {
          log.i('Found device at: ${host.ip}');
          final deviceInfo = await _testDevice(host.ip);
          if (deviceInfo != null) {
            discoveredDevices.add(deviceInfo);
          }
        }
      }

      log.i('Scan complete. Found ${discoveredDevices.length} Offnet devices');
    } catch (e, stackTrace) {
      log.e('Error during network scan', error: e, stackTrace: stackTrace);
      rethrow;
    }

    return discoveredDevices;
  }

  Future<DeviceInfo?> _testDevice(String ip) async {
    try {
      // First test TCP connection
      final socket = await Socket.connect(
        ip,
        APP_PORT,
        timeout: const Duration(milliseconds: 300),
      );
      await socket.close();

      // If TCP connection succeeds, try WebSocket connection
      final webSocket = await WebSocket.connect(
        'ws://$ip:$APP_PORT',
      ).timeout(const Duration(seconds: 2));

      log.i('Requesting info from device: $ip');
      webSocket.add('REQUEST_INFO');

      // Wait for response with timeout
      final completer = Completer<DeviceInfo>();

      webSocket.listen((data) {
        if (data is String) {
          Map<String, dynamic> jsonData =
              Map<String, dynamic>.from({...jsonDecode(data), 'ipAddress': ip});
          final deviceInfo = DeviceInfo.fromJson(jsonEncode(jsonData));
          completer.complete(deviceInfo);
          _saveDeviceInfo(deviceInfo);
        }
      }, onError: (e) {
        completer.completeError(e);
      });

      // Add timeout
      Timer(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          completer.complete(DeviceInfo(ipAddress: ip));
        }
      });

      final result = await completer.future;
      webSocket.close();
      return result;
    } catch (e) {
      log.d('No Offnet service at: $ip');
      return null;
    }
  }

  Future<void> requestDeviceInfo(String ipAddress) async {
    try {
      final deviceInfo = await _testDevice(ipAddress);
      if (deviceInfo == null) {
        throw Exception('Failed to get device info');
      }
      log.i('Successfully fetched info from device: $ipAddress');
    } catch (e) {
      log.e('Error fetching device info: $ipAddress', error: e);
      rethrow;
    }
  }

  Future<void> _saveDeviceInfo(DeviceInfo deviceInfo) async {
    final newUser = OtherUserEntity(
      id: 0,
      name: deviceInfo.name ?? 'Unknown Device',
      uniqueId: deviceInfo.uniqueId ?? 'unknown_device_id',
      publicKey: deviceInfo.publicKey ?? '',
      chatEncryptionKey: '', // This should be generated or exchanged securely
    );

    if (deviceInfo.base64Image != null) {
      newUser.pathToImage =
          await ImageUtils.saveBase64Image(deviceInfo.base64Image!);
    }

    objectBox.otherUserBox.put(newUser);
  }
}
