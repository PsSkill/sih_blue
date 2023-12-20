import 'package:flutter/material.dart';
import 'package:voice_talkie/pages/contact_screen.dart';
import 'package:voice_talkie/theme/color.dart';
// import 'package:permission_handler/permission_handler.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Request permission to access contacts
  // var status = await Permission.contacts.request();

  // if (status.isGranted) {
  //   runApp(MyApp());
  // } else {
  //   print("Permission denied");
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme:
              AppBarTheme(color: primaryColor, foregroundColor: Colors.white),
          primaryColor: primaryColor,
          colorScheme: ColorScheme(
              onBackground: backgroundColor,
              onSurface: Colors.black,
              surface: backgroundColor,
              brightness: Brightness.light,
              primary: primaryColor,
              secondary: primaryColor,
              error: Colors.red,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onError: Colors.red,
              background: backgroundColor)),
      home: const ContactScreen(),
    );
  }
}
