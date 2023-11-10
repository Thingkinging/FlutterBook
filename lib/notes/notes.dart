import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "notes_db_worker.dart";
import "notes_entry.dart";
import "notes_list.dart";
import "notes_model.dart" show NotesModel, notesModel;


/// ********************************************************************************************************************
/// The Notes screen.
/// ********************************************************************************************************************
class Notes extends StatelessWidget {


  /// Constructor.
  Notes() {

    print("## Notes.constructor");

    // Initial load of data.
    notesModel.loadData("notes", NotesDBWorker.db);

  } /* End constructor. */

  Widget build(BuildContext inContext) {

    print("## Notes.build()");

    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (BuildContext inContext, Widget? inChild, NotesModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    NotesList(),
                    NotesEntry(),
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */