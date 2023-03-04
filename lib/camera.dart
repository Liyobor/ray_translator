import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'translation_camera_page/logic.dart';




/// CameraApp is the Main Application.
class Camera extends StatefulWidget {
  /// Default Constructor
  const Camera({Key? key,this.child}) : super(key: key);

  final Widget? child;

  @override
  State<Camera> createState() => _CameraAppState();
}

class _CameraAppState extends State<Camera> {


  @override
  void dispose() {
    final logic = Get.put(TranslationCameraLogic());
    logic.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final logic = Get.put(TranslationCameraLogic());
    logic.init();
    logic.controller = CameraController(cameras[0], ResolutionPreset.high,enableAudio: false);
    logic.controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      // logic.startImageStream();

      logic.detectText();

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
    final logic = Get.put(TranslationCameraLogic());
    if (!logic.controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(
        logic.controller,
        child: widget.child,
      ),
    );
  }
}