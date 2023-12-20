import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:record/record.dart';
import 'package:voice_talkie/pages/contact_screen.dart';
import 'package:voice_talkie/theme/color.dart';

class CallScreen extends StatefulWidget {
  Contact contact;
  BluetoothConnection? connection;
  CallScreen(this.contact, this.connection, {super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMute = false;
  bool isSpeaker = false;
  String filePath = '';
  final record = Record();
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  void sendAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File file = File(result.files.single.path.toString());
      filePath = result.files.single.path.toString();

      // Set chunk size according to your requirements
      final chunkSize = 1024; // 1 KB chunks

      // Open the file
      final fileStream = file.openRead();

      // Read and send file in chunks
      await for (List<int> chunk in fileStream) {
        final uint8ListChunk = Uint8List.fromList(chunk);
        widget.connection!.output.add(uint8ListChunk);
        print(uint8ListChunk);
        await widget.connection!.output.allSent;
      }

      _listenForData();
      // Close the connection after sending the entire file
      // widget.connection!.finish();
    } else {
      // User canceled the file picking
      print('File picking canceled');
    }
  }

  void getVoice(String filePath) async {
    File file = File(filePath);

    // Set chunk size according to your requirements
    final chunkSize = 1024; // 1 KB chunks

    // Open the file
    final fileStream = file.openRead();

    // Read and send file in chunks
    await for (List<int> chunk in fileStream) {
      final uint8ListChunk = Uint8List.fromList(chunk);
      print(uint8ListChunk);
    }
  }

  void _listenForData() async {
    try {
      int i = 0;

      await audioPlayer.play(AssetSource("sample.mp3"));
      widget.connection!.input!.listen((List<int> data) async {
        // Process the received data, assuming it's audio data
        print(data);
        if (i == 0) {
          i++;
        }
        // _addToAudioSource(data);
      }).onDone(() {
        // Handle the disconnection event
        print('Bluetooth connection closed');
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> startRecording() async {
    try {
      if (await record.hasPermission()) {
        await record.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await record.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> playSound() async {
    try {
      Source source = UrlSource(audioPath);
      await audioPlayer.play(source);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    widget.connection?.dispose();
    audioPlayer.dispose();
    record.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    audioPlayer = AudioPlayer();
    super.initState();
    // initalizeMicrophone();
    // startStreaming();
  }

  // void playAudio() async {
  //   List<int> rawAudioData = [44, 32, 51]; // Replace ... with your actual data
  //   String tempFilePath = await _writeTempWavFile(rawAudioData);
  //   int result = await audioPlayer.play(tempFilePath, isLocal: true);

  //   if (result == 1) {
  //     print('Audio is playing');
  //   } else {
  //     print('Error playing audio');
  //   }
  // }

  // Future<String> _writeTempWavFile(List<int> rawAudioData) async {
  //   final tempDir = await getTemporaryDirectory();
  //   final tempFilePath = '${tempDir.path}/temp.wav';

  //   // Simple WAV file header for 16-bit PCM
  //   final header = Uint8List.fromList([
  //     82, 73, 70, 70, // 'RIFF'
  //     0, 0, 0, 0, // File size (to be filled later)
  //     87, 65, 86, 69, // 'WAVE'
  //     102, 109, 116, 32, // 'fmt '
  //     16, 0, 0, 0, // Subchunk1Size
  //     1, 0, // AudioFormat (PCM)
  //     1, 0, // NumChannels
  //     44, 172, 0, 0, // SampleRate (44.1 kHz)
  //     176, 163, 2, 0, // ByteRate
  //     4, 0, // BlockAlign
  //     16, 0, // BitsPerSample
  //     100, 97, 116, 97, // 'data'
  //     0, 0, 0, 0, // Subchunk2Size (to be filled later)
  //   ]);

  //   // Calculate and fill in the actual sizes
  //   final fileSize =
  //       36 + rawAudioData.length * 2; // 36 is the size of the header
  //   header[4] = (fileSize & 0xFF);
  //   header[5] = ((fileSize >> 8) & 0xFF);
  //   header[6] = ((fileSize >> 16) & 0xFF);
  //   header[7] = ((fileSize >> 24) & 0xFF);

  //   final dataSize = rawAudioData.length * 2;
  //   header[40] = (dataSize & 0xFF);
  //   header[41] = ((dataSize >> 8) & 0xFF);
  //   header[42] = ((dataSize >> 16) & 0xFF);
  //   header[43] = ((dataSize >> 24) & 0xFF);

  //   // Write the header and audio data to the temporary WAV file
  //   final file = File(tempFilePath);
  //   await file.writeAsBytes(header, mode: FileMode.write);
  //   await file.writeAsBytes(rawAudioData, mode: FileMode.append);

  //   return tempFilePath;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AdvancedAvatar(
              size: 100,
              name: widget.contact.displayName,
              autoTextSize: true,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.contact.displayName.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 28),
            ),
            Text(
              widget.contact.phones![0].value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          sendAudioFile();
                          setState(() {
                            isMute = !isMute;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isMute
                                  ? const Color.fromARGB(255, 227, 227, 227)
                                  : null),
                          child: Column(
                            children: [
                              Icon(isMute
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_outlined),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(isMute ? "Unmute" : "Mute")
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          startRecording();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 227, 227, 227)),
                          child: const Column(
                            children: [
                              Icon(Icons.volume_up_rounded),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Speaker")
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          stopRecording();
                          playSound();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 227, 227, 227)),
                          child: const Column(
                            children: [
                              Icon(Icons.notes_rounded),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Notes")
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const ContactScreen(),
                    ),
                    (route) => false);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color.fromARGB(255, 190, 16, 3)),
                child: const Icon(
                  Icons.call_end_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
