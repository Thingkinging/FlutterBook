import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:scoped_model/scoped_model.dart";

import "notes_db_worker.dart";
import "notes_model.dart" show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {

  Widget build(BuildContext inContext) {
    print("## NotesList.build()");

    // Return widget.
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(builder:
                (BuildContext inContext, Widget? inChild, NotesModel inModel) {
          return Scaffold(
              // Add note.
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    notesModel.entityBeingEdited = Note();
                    notesModel.setColor('');
                    notesModel.setStackIndex(1);
                  }),
              body: ListView.builder(
                  itemCount: notesModel.entityList.length,
                  itemBuilder: (BuildContext inBuildContext, int inIndex) {
                    Note note = notesModel.entityList[inIndex];
                    // Determine note background color (default to white if none was selected).
                    Color color = Colors.white;
                    switch (note.color) {
                      case "red":
                        color = Colors.red;
                        break;
                      case "green":
                        color = Colors.green;
                        break;
                      case "blue":
                        color = Colors.blue;
                        break;
                      case "yellow":
                        color = Colors.yellow;
                        break;
                      case "grey":
                        color = Colors.grey;
                        break;
                      case "purple":
                        color = Colors.purple;
                        break;
                    }
                    return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Slidable(
                            endActionPane: ActionPane(
                              extentRatio: .25,
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  label: "Delete",
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  onPressed: (BuildContext context) {
                                    _deleteNote(inContext, note);
                                  },
                                ),
                              ],
                            ),
                            child: Card(
                                elevation: 8,
                                color: color,
                                child: ListTile(
                                    title: Text("${note.title}"),
                                    subtitle: Text("${note.content}"),
                                    // Edit existing note.
                                    onTap: () async {
                                      // Get the data from the database and send to the edit view.
                                      notesModel.entityBeingEdited =
                                          await NotesDBWorker.db.get(note.id as int);
                                      notesModel.setColor(
                                          notesModel.entityBeingEdited.color);
                                      notesModel.setStackIndex(1);
                                    })) /* End Card. */
                            ) /* End Slidable. */
                        ); /* End Container. */
                  } /* End itemBuilder. */
                  ) /* End End ListView.builder. */
              ); /* End Scaffold. */
        } /* End ScopedModelDescendant builder. */
            ) /* End ScopedModelDescendant. */
        ); /* End ScopedModel. */
  }

  Future _deleteNote(BuildContext inContext, Note inNote) async {
    print("## NotestList._deleteNote(): inNote = $inNote");

    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
              title: Text("Delete Note"),
              content: Text("Are you sure you want to delete ${inNote.title}?"),
              actions: [
                ElevatedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }),
                ElevatedButton(
                    child: Text("Delete"),
                    onPressed: () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      await NotesDBWorker.db.delete(inNote.id as int);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Note deleted")));
                      // Reload data from database to update list.
                      notesModel.loadData("notes", NotesDBWorker.db);
                    })
              ]);
        });
  }
/* End _deleteNote(). */
} /* End class. */
