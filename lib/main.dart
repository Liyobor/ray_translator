import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ray_translator/home/view.dart';


import 'translation_camera_page/logic.dart';
import 'translation_camera_page/view.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  if (kDebugMode) {
    print("camera count = ${cameras.length}");
  }
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: TranslationCameraLogic.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      initialRoute: "/HomePage",
      // home: HomePage(),
      routes: {
        "/HomePage":(context) => HomePage(),
        "/CameraPage":(context) => TranslationCameraPage(),
      },
      builder: EasyLoading.init(),
    );
  }
}

