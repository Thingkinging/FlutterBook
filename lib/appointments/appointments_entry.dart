import "package:flutter/material.dart";
import "package:flutter_book/appointments/appointments_db_worker.dart";
import 'package:flutter_book/utils.dart' as utils;
import "package:scoped_model/scoped_model.dart";

import "appointments_model.dart" show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    print("## AppointmentsEntry.constructor");

    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
      appointmentsModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext inContext) {
    print("## AppointmentsEntry.build()");

    if (appointmentsModel.entityBeingEdited != null) {
      _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      _descriptionEditingController.text =
          appointmentsModel.entityBeingEdited.description;
    }

    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild,
            AppointmentsModel inModel) {
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
                    child: Text("Saved"),
                    onPressed: () {
                      _save(inContext, appointmentsModel);
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
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Title"),
                      controller: _titleEditingController,
                      validator: (inValue) {
                        if (inValue!.length == 0) {
                          return "Please enter a title";
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Description"),
                      controller: _descriptionEditingController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    subtitle: Text(appointmentsModel.choseDate ?? ""),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                            inContext,
                            appointmentsModel,
                            appointmentsModel.entityBeingEdited.apptDate);
                        if (chosenDate != null) {
                          appointmentsModel.entityBeingEdited.apptDate =
                              chosenDate;
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text("Time"),
                    subtitle: Text(appointmentsModel.apptTime ??= ""),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectTime(inContext),
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

  Future _selectTime(BuildContext inContext) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
    TimeOfDay? picked = await showTimePicker(
      context: inContext,
      initialTime: initialTime,
    );

    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime =
          "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(inContext));
    }
  }

  void _save(BuildContext inContext, AppointmentsModel inModel) async {
    print("## AppointmentsEntry._save()");

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (inModel.entityBeingEdited.id == null) {
      print(
          "## AppointmentsEntry._save(): Creating : ${inModel.entityBeingEdited}");
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      print(
          "## AppointmentsEntry._save(): Updating : ${inModel.entityBeingEdited}");
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

    inModel.setStackIndex(0);

    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Appointment saved"),
      ),
    );
  }
}
