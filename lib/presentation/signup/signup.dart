import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/data/models.dart';
import 'package:pointycastle/export.dart' as pc;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  final ObjectBox objectBox;

  SignupPage({required this.objectBox});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  File? _image;
  String _uniqueId = '';

  @override
  void initState() {
    super.initState();
    _generateUniqueId();
  }

  Future<void> _generateUniqueId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      _uniqueId = androidInfo.id;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<Map<String, String>> _generateKeyPair() async {
    final secureRandom = pc.FortunaRandom();
    final seedSource = math.Random.secure();
    final seeds = List<int>.generate(32, (i) => seedSource.nextInt(256));
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(
          pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12),
          secureRandom));

    final pair = keyGen.generateKeyPair();

    final privateKey = pair.privateKey as pc.RSAPrivateKey;
    final publicKey = pair.publicKey as pc.RSAPublicKey;

    return {
      'private':
          base64.encode(utf8.encode(privateKey.modulus!.toRadixString(16))),
      'public':
          base64.encode(utf8.encode(publicKey.modulus!.toRadixString(16))),
    };
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        final keyPair = await _generateKeyPair();

        final selfUser = SelfUserEntity(
          id: 0, // ObjectBox will assign proper ID
          name: _name,
          uniqueId: _uniqueId,
          pathToImage: _image?.path,
          privateKey: keyPair['private']!,
          publicKey: keyPair['public']!,
        );

        widget.objectBox.initializeSelf(selfUser);

        if (mounted) {
          context.go('/'); // Navigate using GoRouter
        }
      } catch (e) {
        Navigator.of(context).pop(); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during signup: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? Center(child: Text('No image selected.'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo_library),
                  label: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
