import 'package:flutter/material.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/router.dart';
import 'package:offnet/core/services/service_locator.dart';
import 'dart:isolate';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final objectBox = await ObjectBox.create();
  
  runApp(
    Provider<ObjectBox>.value(
      value: objectBox,
      child: MyApp(objectBox: objectBox),
    ),
  );

  // Setup services after UI is running
  setupServices(objectBox).catchError((e) {
    debugPrint('Failed to initialize services: $e');
  });
}

Future<void> _startBackgroundServices() async {
  await Isolate.spawn(
    (message) async {
      // Keep the isolate running
      while (true) {
        await Future.delayed(const Duration(seconds: 1));
      }
    },
    null,
  );
}

class MyApp extends StatelessWidget {
  final ObjectBox objectBox;

  const MyApp({Key? key, required this.objectBox}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Offnet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: createRouter(objectBox),
    );
  }
}
