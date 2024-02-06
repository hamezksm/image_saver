import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImagePersistenceExample extends StatefulWidget {
  const ImagePersistenceExample({super.key});

  @override
  State<ImagePersistenceExample> createState() =>
      _ImagePersistenceExampleState();
}

class _ImagePersistenceExampleState extends State<ImagePersistenceExample> {
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Persistence Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _imageFile != null
              ? Image.file(_imageFile!)
              : const Text('No image selected'),
          ElevatedButton(
            onPressed: () {
              _pickImage();
            },
            child: const Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: () {
              _persistImage();
            },
            child: const Text('Persist Image'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    // Implement your image picking logic, for example using the image_picker package.
    // This example assumes you already have an image file.
    // Replace this part with your actual image picking code.
    // For simplicity, we'll use an image asset as an example.
    ByteData data = await rootBundle.load('assets/sample_image.jpg');
    Uint8List bytes = data.buffer.asUint8List();

    // Create a temporary file to store the picked image
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(bytes);

    setState(() {
      _imageFile = tempFile;
    });
  }

  Future<void> _persistImage() async {
    if (_imageFile == null) {
      return;
    }

    // Get the documents directory for the app
    Directory appDocDir = await getApplicationDocumentsDirectory();

    // Define the path where you want to store the image in the documents directory
    String imagePath = '${appDocDir.path}/persisted_image.jpg';

    // Copy the image file to the documents directory
    await _imageFile!.copy(imagePath);
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: ImagePersistenceExample(),
    ),
  );
}
