import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/appointments_list.dart';
import 'package:flutter_book/appointments/appointments_model.dart';
import 'package:scoped_model/scoped_model.dart';

import 'appointments_db_worker.dart';
import 'appointments_entry.dart';

class Appointments extends StatelessWidget {
  Appointments() {
    print("## Appointments.constructor");

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel){
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              AppointmentsList(),
              AppointmentsEntry(),
            ],
          );
        },
      ),
    );
  }
}
