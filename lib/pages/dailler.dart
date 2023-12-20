import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';5
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:voice_talkie/pages/call.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:voice_talkie/theme/color.dart';

class DaillerScreen extends StatefulWidget {
  const DaillerScreen({super.key});

  @override
  State<DaillerScreen> createState() => _DaillerScreenState();
}

class _DaillerScreenState extends State<DaillerScreen> {
  List<String> daillerFields = [
    "*",
    "0",
    "Clear",
    "7",
    "8",
    "9",
    "4",
    "5",
    "6",
    "1",
    "2",
    "3",
  ];

  TextEditingController phoneNumberText = TextEditingController();
  bool isConnected = false;
  //  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;
  late StreamController<Uint8List> audioStreamController;
  BluetoothConnection? connection;

  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady = false;
  Stream<List<int>>? stream;
  List<double> traceDust = [];

//   @override
//   void initState() {
//     super.initState();
//     _recorder = FlutterSoundRecorder();
//     audioStreamController = StreamController<Uint8List>.broadcast();
//     _initRecorder();
//   }

//   void _initRecorder() async {
//     await _recorder.openRecorder();
//   }

//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     audioStreamController.close();
//     super.dispose();
//   }

//   void _startRecording() async {
//   await _recorder.startRecorder(
//     // toStream: audioStreamController,
//   );
//   setState(() {
//     _isRecording = true;
//   });
// }

//   void _stopRecording() async {
//     await _recorder.stopRecorder();
//     setState(() {
//       _isRecording = false;
//     });
  // }

  sendData() async {
    try {
      connection!.output.add(Uint8List.fromList(
          utf8.encode("Calling to ${phoneNumberText.text} \r\n")));
      await connection!.output.allSent;
    } catch (e) {
      print(e.toString());
    }
  }

  addCallText(String value) {
    if (value == "Clear") {
      phoneNumberText.clear();
      return;
    }
    setState(() {
      phoneNumberText.text += value;
    });
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
            builder: (context) => CallScreen(Contact(displayName: "Unknown",phones: [Item(label: "mobile",value: phoneNumberText.text)]),connection),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Dial a Number"),
      ),
      body: Stack(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: TextFormField(
              controller: phoneNumberText,
              textAlign: TextAlign.center,
              readOnly: true,
              style: const TextStyle(fontSize: 30),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 70),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Expanded(
                  child: GridView.builder(
                scrollDirection: Axis.vertical,
                reverse: true,
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: 3),
                itemCount: daillerFields.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => addCallText(daillerFields[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromARGB(255, 213, 213, 213),
                      ),
                      child: Center(
                          child: Text(
                        daillerFields[index],
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      )),
                    ),
                  );
                },
              )),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () {
                      // if (phoneNumberText.text == "9566663139") {
                      // if (isConnected) {
                      //   // sendData();
                      // } else {
                      setState(() {
                        isConnected = false;
                      });
                      showCallDialogy();
                      connectToDevice();
                      // }
                      // }xs
                    },
                    label: const Text(
                      "Call",
                      style: TextStyle(color: Colors.white),
                    ))),
          )
        ],
      ),
    );
  }
}
