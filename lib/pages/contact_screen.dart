import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:voice_talkie/pages/dailler.dart';
import 'package:voice_talkie/pages/details.dart';
import 'package:voice_talkie/theme/color.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactFeild {
  String name;
  String phone;
  Color statusColor;

  ContactFeild(
      {required this.name, required this.phone, required this.statusColor});
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  // List<String> contactList = ["Rishvanth", "Rishvanth"];
  List<ContactFeild> contact = [
    ContactFeild(
        name: "Rishvanth", phone: "9566663139", statusColor: Colors.green),
    ContactFeild(
        name: "Sharmila", phone: "9432424139", statusColor: Colors.green),
    ContactFeild(
        name: "Student", phone: "9566663139", statusColor: Colors.green),
    ContactFeild(
        name: "Rishvanth 2", phone: "95663527648", statusColor: Colors.red),
    ContactFeild(
        name: "Poovarasan", phone: "3243527648", statusColor: Colors.red),
    ContactFeild(
        name: "Student 2", phone: "95663527648", statusColor: Colors.red),
  ];
  List<Contact> contactList = [];

  getContacts() async {
    // Request permission to access contacts if not already granted
    var status = await Permission.contacts.request();
    if (!status.isGranted) {
      print("Permission denied");
      return [];
    }

    // Get contacts
    Iterable<Contact> contacts = await ContactsService.getContacts();
    print(contacts);
    contactList = contacts.toList();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const DaillerScreen(),
          ));
        },
        child: const Icon(Icons.dialpad_rounded),
      ),
      appBar: AppBar(
        title: const Text("My Contacts"),
      ),
      body: ListView.builder(
        itemCount: contactList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DetailScreen(contactList[index]),
              ));
            },
            child: ListTile(
              leading: AdvancedAvatar(
                name: contactList[index].displayName,
              ),
              title: Text(contactList[index].displayName.toString()),
              // subtitle: Text(contact[index].phone.length!=0 ? contactList[index].phones![0].value.toString():""),
            ),
          );
        },
      ),
    );
  }
}
