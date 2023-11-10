import 'package:flutter_book/base_model.dart';

class Note {
  int? id;
  String title = '';
  String content = '';
  late String color;

  @override
  String toString() {
    return "{id = $id, title = $title, content = $content, color = $color";
  }
}

class NotesModel extends BaseModel {
  String color = '';

  void setColor(String inColor) {
    print("## NoteModel.setColor() : inColor = $inColor");

    color = inColor;
    notifyListeners();
  }
}

NotesModel notesModel = NotesModel();