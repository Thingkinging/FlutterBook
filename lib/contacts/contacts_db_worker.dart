import 'package:flutter_book/contacts/contracts_model.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ContactsDBWorker {
  ContactsDBWorker._();

  static final ContactsDBWorker db = ContactsDBWorker._();

  Database? _db;

  Future get database async {
    _db ??= await init();

    print("## ContactsDBWorker.get-database(): _db = $_db}");

    return _db;
  }

  Future<Database> init() async {
    print("## ContactsDBWorker.init()");

    String path = join(utils.docsDir!.path, "contacts.db");
    print("## ContactsDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS contacts ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "email TEXT,"
          "phone TEXT,"
          "birthday TEXT"
          ")");
    });
    return db;
  }

  Contact contactFromMap(Map inMap) {
    print("## ContactsDBWorker.contactToFrom(): inMap = $inMap");

    Contact contact = Contact();
    contact.id = inMap["id"];
    contact.name = inMap["name"];
    contact.phone = inMap["phone"];
    contact.email = inMap["email"];
    contact.birthday = inMap["birthday"];

    return contact;
  }

  Map<String, dynamic> contactToMap(Contact inContact) {
    print("## ContactsDBWorker.contactToFrom(): inContact = $inContact");

    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inContact.id;
    map["name"] = inContact.name;
    map["phone"] = inContact.phone;
    map["email"] = inContact.email;
    map["birthday"] = inContact.birthday;

    return map;
  }

  Future create(Contact inContact) async {
    print("## ContactsDBWorker.create(): inContact = $inContact");

    Database db = await database;

    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    dynamic id = val.first["id"];
    id ??= 1;

    await db.rawInsert(
        "INSERT INTO contacts (id, name, email, phone, birthday) VALUES(?, ?, ?, ?, ?)",
        [
          id,
          inContact.name,
          inContact.email,
          inContact.phone,
          inContact.birthday,
        ]);
  }

  Future<Contact> get(int inID) async {
    print("## ContactsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("contacts", where: "id = ?", whereArgs: [inID]);
    print("## ContactsDBWorker.rec(): rec.first = ${rec.first}");

    return contactFromMap(rec.first);
  }

  Future<List> getAll() async {
    print("## ContactsDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("contacts");
    var list =
        recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [];
    print("## ContactsDBWorker.getAll(): list = $list");

    return list;
  }

  Future update(Contact inContact) async {
    print("## ContactsDBWorker.update(): inContact = $inContact");

    Database db = await database;
    return await db.update("contacts", contactToMap(inContact),
        where: "id = ?", whereArgs: [inContact.id]);
  }

  Future delete(int inID) async {
    print("## ContactsDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("contacts", where: "id = ?", whereArgs: [inID]);
  }
}
