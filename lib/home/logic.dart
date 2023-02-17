import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
late List<CameraDescription> cameras;
class HomeLogic extends GetxController {

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late CameraController controller;





  @override
  void onInit() {
    super.onInit();


    Timer.periodic(const Duration(seconds: 8), (timer) async {
      if (kDebugMode) {
        print("tick");
      }
      controller.startImageStream((image){

        controller.stopImageStream();
        _scanText(image);
      });



    });
  }

  Future<void> printResult(RecognizedText text) async {
    for (TextBlock block in text.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        if (kDebugMode) {
          print("line = ${line.text}");
        }
        for (TextElement element in line.elements) {
          if (kDebugMode) {
            print("element = ${element.text}");
          }
        }
      }
    }
  }

  void _scanText(CameraImage availableImage) async {

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);


    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in availableImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: availableImage.toInputImageData());
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    printResult(recognizedText);
    textRecognizer.close();

  }




}
extension ChangeType on CameraImage{
  InputImageData toInputImageData(){


    final Size imageSize = Size(width.toDouble(), height.toDouble());

    final InputImageRotation imageRotation = InputImageRotationValue.fromRawValue(cameras[0].sensorOrientation) ?? InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(format.raw) ?? InputImageFormat.yuv_420_888;

    final planeData = planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();


    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    return inputImageData;
  }
}
