import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:voice_talkie/pages/call.dart';
import 'package:voice_talkie/theme/color.dart';

class DetailScreen extends StatefulWidget {
  Contact contact;
  DetailScreen(this.contact, {super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isConnected = false;
  BluetoothConnection? connection;


  showCallDialogy() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (!isConnected) const CircularProgressIndicator(),
                  if (isConnected) const Icon(Icons.done_rounded),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                      "${isConnected ? 'Connected' : 'Connecting'} to Bluetooth")
                ],
              ),
            );
          }),
        );
      },
    );
  }

  sendData() async {
    try {
      connection!.output.add(Uint8List.fromList(
          utf8.encode("Calling to ${widget.contact.phones![0].value} \r\n")));
      await connection!.output.allSent;
    } catch (e) {
      print(e.toString());
    }
  }

  connectToDevice() async {
    try {
      // await FlutterBluetoothSerial.instance.connect("24:6F:28:16:7F:DA" as BluetoothDevice);

      // if (phoneNumberText.text == "956666139") {
      // BluetoothConnection.toAddress("3C:71:BF:F9:48:1A").then((value) async {
      BluetoothConnection.toAddress("24:6F:28:16:7F:DA").then((value) async {
        // BluetoothConnection.toAddress("  =").then((value) async {
        setState(() {
          connection = value;
          isConnected = true;
        });
        sendData();
        Navigator.of(context).pop();
        showCallDialogy();
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CallScreen(Contact(displayName: widget.contact.displayName ,phones: [Item(label: "mobile",value: widget.contact.phones![0].value)]),connection),
          ));
        });
      });
      // }

      // if (connection.isConnected) {
      //   setState(() {
      //     isConnected = true;
      //     Timer(const Duration(seconds: 2), () {
      //       Navigator.of(context).pop();
      //     });
      //   });
      // }

      // connection.input!.listen((Uint8List data) {
      //   print('Data incoming: ${ascii.decode(data)}');
      //   connection.output.add(data);

      //   if (ascii.decode(data).contains('!')) {
      //     connection.finish();
      //     print('Disconnecting by local host');
      //   }
      // }).onDone(() {
      // });
    } catch (e) {
      print(e.toString());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.displayName.toString()),
      ),
      bottomSheet: BottomSheet(
        backgroundColor: Colors.transparent,
        onClosing: () {},
        builder: (context) {
          return InkWell(
            onTap: () {
              setState(() {
                isConnected = false;
              });
                      showCallDialogy();
                      connectToDevice();
            },
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: const Center(
                  child: Text(
                "Make a Call",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1),
              )),
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Username"),
            Text(
              widget.contact.displayName.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Phone Number"),
            Text(
              widget.contact.phones![0].value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
