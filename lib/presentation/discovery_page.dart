import 'package:flutter/material.dart';
import '../core/network/device_discovery.dart';
import '../core/models/device_info.dart';
import 'package:provider/provider.dart';
import 'package:offnet/data/objectbox.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  late DeviceDiscovery _deviceDiscovery;
  List<DeviceInfo> _devices = [];
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _deviceDiscovery = DeviceDiscovery(context.read<ObjectBox>());
  }

  Future<void> _scanDevices() async {
    setState(() => _isDiscovering = true);
    try {
      final devices = await _deviceDiscovery.scanNetwork();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning devices: $e')),
      );
    } finally {
      setState(() => _isDiscovering = false);
    }
  }

  Future<void> _connectToDevice(DeviceInfo device) async {
    try {
      await _deviceDiscovery.requestDeviceInfo(device.ipAddress);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device info requested successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Discovery'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: _isDiscovering ? null : _scanDevices,
              child: _isDiscovering
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Scan Devices"),
            ),
          ),
          Expanded(
            child: _devices.isEmpty
                ? const Center(child: Text('No devices found.'))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        leading: const Icon(Icons.devices),
                        title: Text(device.name ?? device.ipAddress),
                        subtitle: Text(device.ipAddress),
                        trailing: IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () => _connectToDevice(device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
