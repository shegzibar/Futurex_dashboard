import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:futuerx_dashboard/Screens/Home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBJGy60CfmJRj3aYrog4a97PC8c0ZraDtk",
        authDomain: "futurex-19db0.firebaseapp.com",
        projectId: "futurex-19db0",
        storageBucket: "futurex-19db0.appspot.com",
        messagingSenderId: "826402051210",
        appId: "1:826402051210:web:2f7a77b6176d5fdff30973",
        measurementId: "G-2HSE9CYSRG",

    ),
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home(),
  )
  );
}

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return  Dashboard();
  }
}