import 'package:flutter_book/appointments/appointments_model.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentsDBWorker {
  AppointmentsDBWorker._();

  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database? _db;

  Future get database async {
    _db ??= await init();

    print("## AppointmentsDBWorker.get-database(): _db = $_db}");
    return _db;
  }

  Future<Database> init() async {
    print("## AppointmentsDBWorker.init()");

    String path = join(utils.docsDir!.path, "appointments.db");
    print("## AppointmentsDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS appointments ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "title TEXT,"
          "description TEXT,"
          "apptDate TEXT,"
          "apptTime TEXT"
          ")");
    });
    return db;
  }

  Appointment appointmentFromMap(Map inMap) {
    print("## AppointmentsDBWorker.appointmentFromMap(): inMap = $inMap");

    Appointment appointment = Appointment();
    appointment.id = inMap["id"];
    appointment.title = inMap["title"];
    appointment.description = inMap["description"];
    appointment.apptDate = inMap["apptDate"];
    appointment.apptTime = inMap["apptTime"];
    print(
        "## AppointmentsDBWorker.appointmentFromMap(): appointment = $appointment");

    return appointment;
  }

  Map<String, dynamic> appointmentToMap(Appointment inAppointment) {
    print(
        "## AppointmentsDBWorker.appointmentFromMap(): inAppointment = $inAppointment");

    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inAppointment.id;
    map["title"] = inAppointment.title;
    map["description"] = inAppointment.description;
    map["apptDate"] = inAppointment.apptDate;
    map["apptTime"] = inAppointment.apptTime;
    print("## AppointmentsDBWorker.map(): map = $map");

    return map;
  }

  Future create(Appointment inAppointment) async {
    print("## AppointmentsDBWorker.create(): inAppointment = $inAppointment");

    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    dynamic id = val.first["id"];
    id ??= 1;

    return await db.rawInsert(
      "INSERT INTO appointments (id, title, description, apptDate, apptTime) VALUES (?, ?, ?, ?, ?)",
      [
        id,
        inAppointment.title,
        inAppointment.description,
        inAppointment.apptDate,
        inAppointment.apptTime,
      ],
    );
  }

  Future<Appointment> get(int inID) async {
    print("## AppointmentsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec =
        await db.query("appointments", where: "id = ?", whereArgs: [inID]);
    print("## AppointmentsDBWorker.get(): rec = ${rec.first}");

    return appointmentFromMap(rec.first);
  }

  Future<List> getAll() async {
    print("## AppointmentsDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("appointments");
    var list =
        recs.isNotEmpty ? recs.map((m) => appointmentFromMap(m)).toList() : [];
    print("## AppointmentsDBWorker.getAll(): list = $list");

    return list;
  }

  Future update(Appointment inAppointment) async {
    print("## AppointmentsDBWorker.update()");

    Database db = await database;
    return await db
        .update("appointments" ,appointmentToMap(inAppointment), where: "id = ?", whereArgs: [inAppointment.id]);
  }

  Future delete(int inID) async {
    print("## AppointmentsDBWorker.delete()");

    Database db = await database;
    return await db.delete("appointments", where: "id = ?", whereArgs: [inID]);
  }
}
