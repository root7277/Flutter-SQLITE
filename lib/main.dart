import 'package:flutter/material.dart';
import 'note_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQFLite FFI uchun zarur bo‘lgan sozlama (desktopda ishlashi uchun)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: NotesPage(), debugShowCheckedModeBanner: false);
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> _notes = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _refreshNotes() async {
    final data = await NoteDatabase.instance.readAll();
    setState(() {
      _notes = data;
    });
  }

  void _showForm({int? id}) async {
    if (id != null) {
      final existingNote = _notes.firstWhere((note) => note['id'] == id);
      _titleController.text = existingNote['title'];
      _contentController.text = existingNote['content'];
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    showModalBottomSheet(
      context: context,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text(id == null ? 'Add Note' : 'Update Note'),
                  onPressed: () async {
                    final note = {
                      'title': _titleController.text,
                      'content': _contentController.text,
                      if (id != null) 'id': id,
                    };
                    if (id == null) {
                      await NoteDatabase.instance.create(note);
                    } else {
                      await NoteDatabase.instance.update(note);
                    }
                    Navigator.of(context).pop();
                    _refreshNotes();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _deleteNote(int id) async {
    await NoteDatabase.instance.delete(id);
    _refreshNotes();
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Notes App')),
    body: ListView.builder(
      itemCount: _notes.length,
      itemBuilder:
          (_, index) => Card(
            child: ListTile(
              title: Text(_notes[index]['title']),
              subtitle: Text(_notes[index]['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showForm(id: _notes[index]['id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteNote(_notes[index]['id']),
                  ),
                ],
              ),
            ),
          ),
    ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => _showForm(),
    ),
  );
}
