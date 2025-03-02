import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class NoteEditor extends StatefulWidget {
  final String? noteId;
  final String? title;
  final String? content;
  final Color? color;

  const NoteEditor({super.key, this.noteId, this.title, this.content, this.color});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Color _backgroundColor;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title ?? "";
    _contentController.text = widget.content ?? "";
    _backgroundColor = widget.color ?? _generateRandomColor();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Faster but smooth
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  /// ✅ **Fix: Ensure `_generateRandomColor` is inside `_NoteEditorState`**
  Color _generateRandomColor() {
    final List<Color> colors = [
      Colors.white,
      Colors.red.shade300,
      Colors.orange.shade200,
      Colors.yellow.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
      Colors.blueGrey.shade200,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  /// ✅ **Fix: `_saveNote` is properly defined inside `_NoteEditorState`**
  void _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Content cannot be empty")),
      );
      return;
    }

    if (widget.noteId == null) {
      // Create new note
      await FirebaseFirestore.instance.collection("Notez").add({
        "title": _titleController.text,
        "content": _contentController.text,
        "timestamp": Timestamp.now(),
        "color": _backgroundColor.value,
      });
    } else {
      // Update existing note
      await FirebaseFirestore.instance.collection("Notez").doc(widget.noteId).update({
        "title": _titleController.text,
        "content": _contentController.text,
        "color": _backgroundColor.value,
      });
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.noteId ?? "new_note",
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Scaffold(
              backgroundColor: _backgroundColor,
              appBar: AppBar(
                title: Text(widget.noteId == null ? "New Note" : "Edit Note"),
                backgroundColor: _backgroundColor,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: "Enter Note Title",
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: "Write your note here...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveNote, // ✅ Now properly referenced
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Save Note",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
