import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../styles/app_style.dart';

class NoteEditor extends StatefulWidget {
  final String? noteId;
  final String? title;
  final String? content;
  final Color? color;
  final Timestamp? timestamp;

  const NoteEditor({super.key, this.noteId, this.title, this.content, this.color, this.timestamp});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Color _backgroundColor;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title ?? "";
    _contentController.text = widget.content ?? "";
    _backgroundColor = widget.color ?? _generateRandomColor();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  Color _generateRandomColor() {
    return AppStyle.cardsColor[Random().nextInt(AppStyle.cardsColor.length)];
  }

  void _saveNote() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    if (widget.noteId == null) {
      await FirebaseFirestore.instance.collection("Notez").add({
        "title": title,
        "content": content,
        "timestamp": Timestamp.now(),
        "color": _backgroundColor.value,
      });
    } else {
      await FirebaseFirestore.instance.collection("Notez").doc(widget.noteId).update({
        "title": title,
        "content": content,
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
    String formattedDate = widget.timestamp != null
        ? "${widget.timestamp!.toDate().day}/${widget.timestamp!.toDate().month}/${widget.timestamp!.toDate().year} "
        "${widget.timestamp!.toDate().hour}:${widget.timestamp!.toDate().minute}"
        : "New Note";

    return Hero(
      tag: widget.noteId ?? "new_note",
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            backgroundColor: _backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: _saveNote,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save, color: Colors.black),
                onPressed: _saveNote,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: AppStyle.dateTitle.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Enter Note Title",
                    hintStyle: AppStyle.mainTitle.copyWith(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  style: AppStyle.mainTitle,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: "Write your note here...",
                        hintStyle: AppStyle.mainContent.copyWith(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                      style: AppStyle.mainContent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
    );
  }
}
