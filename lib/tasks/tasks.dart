import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/tasks_db_worker.dart';
import 'package:flutter_book/tasks/tasks_entry.dart';
import 'package:flutter_book/tasks/tasks_list.dart';
import 'package:flutter_book/tasks/tasks_model.dart';
import 'package:scoped_model/scoped_model.dart';

class Tasks extends StatelessWidget {
  Tasks() {
    print("## Tacks.constructor");
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    print("## Tacks.build()");

    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              TasksList(),
              TasksEntry(),
            ],
          );
        },
      ),
    );
  }
}
