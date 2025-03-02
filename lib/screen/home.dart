import 'package:flutter/material.dart';
import 'package:notez/styles/app_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/note_editor.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(
          "Notes",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make text bold
            fontSize: 32,
            color: Colors.white// Increase text size
          ),
        ),
        centerTitle: true,
        backgroundColor: AppStyle.mainColor,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: const NoteEditor(),
                );
              },
            ),
          );
        },
        backgroundColor: Colors.white70,
        label: const Text("Add notes", style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Recent Notes",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("Notez").orderBy("timestamp", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading notes",
                        style: GoogleFonts.nunito(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "There's no Notes",
                        style: GoogleFonts.nunito(color: Colors.white),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var note = snapshot.data!.docs[index];
                      return Dismissible(
                        key: Key(note.id),
                        direction: DismissDirection.none, // Prevent swipe
                        confirmDismiss: (direction) async {
                          return await _showDeleteDialog(context, note.id);
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                      child: NoteEditor(
                                        noteId: note.id,
                                        title: note['title'],
                                        content: note['content'],
                                        color: Color(note['color']),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          onLongPress: () async {
                            bool delete = await _showDeleteDialog(context, note.id);
                            if (delete) {
                              _deleteNote(note.id);
                            }
                          },
                          child: Hero(
                            tag: note.id,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Color(note['color']),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note['title'],
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      note['content'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, String noteId) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm delete
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ??
        false; // Default to false if dismissed
  }

  /// Deletes a note from Firestore and triggers animation
  void _deleteNote(String noteId) async {
    await _firestore.collection("Notez").doc(noteId).delete();
    setState(() {}); // Refresh UI
  }
}
