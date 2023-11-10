import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "contacts_db_worker.dart";
import "contacts_list.dart";
import "contacts_entry.dart";
import "contracts_model.dart" show ContactsModel, contactsModel;
class Contacts extends StatelessWidget {
  Contacts() {
    print("## Contacts.constructor");

    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext inContext) {
    print("## Contacts.build()");

    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel){
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              ContactsList(),
              ContactsEntry(),
            ],
          );
        },
      ),
    );
  }
}
