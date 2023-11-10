import "package:flutter/material.dart";
import "package:flutter_book/appointments/appointments_db_worker.dart";
import "package:flutter_calendar_carousel/classes/event.dart";
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "package:scoped_model/scoped_model.dart";

import "appointments_model.dart"
    show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext inContext) {
    print("## AppointmentsList.build()");

    EventList<Event> _marketDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      _marketDateMap.add(
          apptDate,
          Event(
              date: apptDate,
              icon: Container(
                decoration: BoxDecoration(color: Colors.blue),
              )));
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (inContext, inChild, inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate =
                    "${now.year},${now.month},${now.year}";
                appointmentsModel.setChosenDate(
                    DateFormat.yMMMMd("en_US").format(now.toLocal()));
                appointmentsModel.setApptTime('');
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _marketDateMap,
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, inContext);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    print(
        "## AppointmentsList._showAppointments(): inDate = $inDate (${inDate.year},${inDate.month},${inDate.day})");

    print(
        "## AppointmentsList._showAppointments(): appointmentsModel.entityList.length = "
        "${appointmentsModel.entityList.length}");
    print(
        "## AppointmentsList._showAppointments(): appointmentsModel.entityList = "
        "${appointmentsModel.entityList}");

    showModalBottomSheet(
      context: inContext,
      builder: (BuildContext inContext) {
        return ScopedModel<AppointmentsModel>(
          model: appointmentsModel,
          child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext inContext, Widget? inChild,
                AppointmentsModel inModel) {
              return Scaffold(
                body: Container(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Text(
                            DateFormat.yMMMMd("en_US").format(inDate.toLocal()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color:
                                    Theme.of(inContext).colorScheme.secondary,
                                fontSize: 24),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: appointmentsModel.entityList.length,
                              itemBuilder:
                                  (BuildContext inBuildContext, int inIndex) {
                                Appointment appointment =
                                    appointmentsModel.entityList[inIndex];
                                print(
                                    "## AppointmentsList._showAppointments().ListView.builder(): appointment = $appointment");
                                if (appointment.apptDate !=
                                    "${inDate.year},${inDate.month},${inDate.day}") {
                                  return Container(height: 0);
                                }
                                print(
                                    "## AppointmentsList._showAppointments().ListView.builder(): "
                                    "INCLUDING appointment = $appointment");

                                String apptTime = '';
                                if (appointment.apptTime != null) {
                                  List timeParts =
                                      appointment.apptTime.split(',');
                                  TimeOfDay at = TimeOfDay(
                                    hour: int.parse(timeParts[0]),
                                    minute: int.parse(timeParts[1]),
                                  );
                                  apptTime = " ${at.format(inContext)}";
                                }
                                return Slidable(
                                  endActionPane: ActionPane(
                                    extentRatio: .25,
                                    motion: DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        label: "Delete",
                                        icon: Icons.delete,
                                        backgroundColor: Colors.red,
                                        onPressed: (BuildContext context) {
                                          _deleteAppointment(
                                              inBuildContext, appointment);
                                        },
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    color: Colors.grey.shade300,
                                    child: ListTile(
                                      title:
                                          Text("${appointment.title}$apptTime"),
                                      subtitle: appointment.description == null
                                          ? null
                                          : Text("${appointment.description}"),
                                      onTap: () async {
                                        _editAppointment(
                                            inContext, appointment);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _editAppointment(
      BuildContext inContext, Appointment inAppointment) async {
    print(
        "## AppointmentsList._editAppointment(): inAppointment = $inAppointment");

    appointmentsModel.entityBeingEdited =
        await AppointmentsDBWorker.db.get(inAppointment.id as int);

    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate('');
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      appointmentsModel
          .setChosenDate(DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
    }
    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      appointmentsModel.setApptTime('');
    } else {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      TimeOfDay apptTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }
    appointmentsModel.setStackIndex(1);
    Navigator.pop(inContext);
  }

  Future _deleteAppointment(
      BuildContext inContext, Appointment inAppointment) async {
    print(
        "## AppointmentsList._deleteAppointment(): inAppointment = $inAppointment");

    return showDialog(
      context: inContext,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Delete Appointment"),
          content:
              Text("Are you sure you want to delete ${inAppointment.title}?"),
          actions: [
            ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(inAlertContext).pop();
              },
            ),
            ElevatedButton(
              child: Text("Delete"),
              onPressed: () async {
                await AppointmentsDBWorker.db.delete(inAppointment.id as int);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Appointment deleted"),
                  ),
                );
                appointmentsModel.loadData(
                    "appointments", AppointmentsDBWorker.db);
              },
            ),
          ],
        );
      },
    );
  }
}
