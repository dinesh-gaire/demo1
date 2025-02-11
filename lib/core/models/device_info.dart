import 'dart:convert';

class DeviceInfo {
  final String ipAddress;
  final String? name;
  final String? uniqueId;
  final String? publicKey;
  final String? base64Image;

  DeviceInfo({
    required this.ipAddress,
    this.name,
    this.uniqueId,
    this.publicKey,
    this.base64Image,
  });

  factory DeviceInfo.fromJson(String jsonStr) {
    final Map<String, dynamic> json = jsonDecode(jsonStr);
    return DeviceInfo(
      ipAddress: json['ipAddress'] ?? '',
      name: json['name'],
      uniqueId: json['uniqueId'],
      publicKey: json['publicKey'],
      base64Image: json['base64Image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ipAddress': ipAddress,
    'name': name,
    'uniqueId': uniqueId,
    'publicKey': publicKey,
    'base64Image': base64Image,
  };
}
