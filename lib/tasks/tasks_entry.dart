import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/tasks_db_worker.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'package:scoped_model/scoped_model.dart';

import "tasks_model.dart" show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry() {
    print("## TasksList.constructor");

    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  /* End constructor. */

  @override
  Widget build(BuildContext inContext) {
    print("## TasksEntry.build()");

    if (tasksModel.entityBeingEdited != null) {
      _descriptionEditingController.text =
          tasksModel.entityBeingEdited.description;
    }

    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  ElevatedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    child: Text("Save"),
                    onPressed: () {
                      _save(inContext, tasksModel);
                    },
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Description"),
                      controller: _descriptionEditingController,
                      validator: (inValue) {
                        if (inValue!.length == 0) {
                          return "Please enter a description";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Due Date"),
                    subtitle: Text(tasksModel.choseDate == null
                        ? ""
                        : tasksModel.choseDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        // Request a date from the user.  If one is returned, store it.
                        String chosenDate = await utils.selectDate(inContext,
                            tasksModel, tasksModel.entityBeingEdited.dueDate);
                        if (chosenDate != null) {
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _save(BuildContext inContext, TasksModel inModel) async {
    print("## TasksEntry._save()");
    print("## TasksEntry._save() : ${inContext.toString()}");
    print("## TasksEntry._save() : ${inModel.toString()}");


    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Creating a new task.
    if (inModel.entityBeingEdited.id == null) {
      print("## TasksEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);

      // Updating an existing task.
    } else {
      print("## TasksEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    // Reload data from database to update list.
    tasksModel.loadData("tasks", TasksDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Task saved")));
  }
/* End _save(). */
} /* End class. */
