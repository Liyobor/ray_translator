import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home/logic.dart';
import 'home/view.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: HomeLogic.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: HomePage(),
    );
  }
}

