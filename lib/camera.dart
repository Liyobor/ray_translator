import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home/logic.dart';



/// CameraApp is the Main Application.
class Camera extends StatefulWidget {
  /// Default Constructor
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _CameraAppState();
}

class _CameraAppState extends State<Camera> {
  final logic = Get.put(HomeLogic());

  @override
  void initState() {
    super.initState();
    logic.controller = CameraController(cameras[0], ResolutionPreset.max);
    logic.controller.initialize().then((_) {

      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    if (!logic.controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(logic.controller),
    );
  }
}