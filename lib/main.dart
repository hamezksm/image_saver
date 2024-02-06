import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class JournalEntry {
  final int id;
  final String title;
  final Uint8List imageBytes; // This will store the image as bytes

  JournalEntry({
    required this.id,
    required this.title,
    required this.imageBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageBytes': imageBytes,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'journal.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY,
        title TEXT,
        imageBytes BLOB
      )
    ''');
  }

  Future<int> insertJournalEntry(JournalEntry entry) async {
    Database db = await instance.database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> getAllEntries() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('journal_entries');

    return List.generate(maps.length, (index) {
      return JournalEntry(
        id: maps[index]['id'],
        title: maps[index]['title'],
        imageBytes: maps[index]['imageBytes'],
      );
    });
  }
}

// Image widget
class ImageWidget extends StatelessWidget {
  final Uint8List imageBytes;

  const ImageWidget(this.imageBytes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Image.memory(imageBytes);
  }
}

// Image form widget


class ImageFormWidget extends StatefulWidget {
  const ImageFormWidget({super.key});

  @override
 State<ImageFormWidget> createState() => _ImageFormWidgetState();
}

class _ImageFormWidgetState extends State<ImageFormWidget> {
  Uint8List? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path).readAsBytesSync();
      });
    }
  }

  Future<void> _persistImage() async {
    if (_selectedImage != null) {
      // Create a JournalEntry and insert it into the database
      JournalEntry entry = JournalEntry(id: 0, title: 'Sample Entry', imageBytes: _selectedImage!);
      await DatabaseHelper.instance.insertJournalEntry(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _selectedImage != null ? ImageWidget(_selectedImage!) : Container(),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Pick Image'),
        ),
        ElevatedButton(
          onPressed: _persistImage,
          child: const Text('Persist Image'),
        ),
      ],
    );
  }
}

// App widget
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image Persistence Example'),
        ),
        body: const ImageFormWidget(),
      ),
    );
  }
}
