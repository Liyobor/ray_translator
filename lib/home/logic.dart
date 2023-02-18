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



  var blockText = "".obs;

  @override
  void onInit() {
    super.onInit();


    Timer.periodic(const Duration(seconds: 7), (timer) async {
      if (kDebugMode) {
        print("tick");
      }
      detectText();


    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.stopImageStream();
  }

  void detectText(){
    var c = 0;
    controller.setFocusMode(FocusMode.auto);
    controller.startImageStream((image) {
      c++;
      if(c==5){
        controller.stopImageStream();
        _scanText(image);
      }
    });
  }

  final List<String> languageList = ["zh","en"];

  Future<String> getResult(TextRecognizer recognizer,RecognizedText text) async {
    String lineString = "";
    for (TextBlock block in text.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;



      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {





        if (kDebugMode) {
          print("recognizedLanguages = ${line.recognizedLanguages}");
          print(languageList.contains(line.recognizedLanguages[0]));
          print(recognizer.script);
        }


        switch(recognizer.script){
          case TextRecognitionScript.chinese:
            if(line.recognizedLanguages[0]!="zh"){
              continue;
            }
            break;
          case TextRecognitionScript.latin:
            if(line.recognizedLanguages[0]!="en"){
              continue;
            }
            break;
          case TextRecognitionScript.devanagiri:
            // TODO: Handle this case.
            break;
          case TextRecognitionScript.japanese:
            // TODO: Handle this case.
            break;
          case TextRecognitionScript.korean:
            // TODO: Handle this case.
            break;
        }


        if(lineString.isEmpty){
          lineString = line.text;
        }else{
          lineString+="\n${line.text}";
        }
        // for (TextElement element in line.elements) {
        //   if (kDebugMode) {
        //     print("element = ${element.text}");
        //   }
        // }
      }
    }
    return lineString;
  }

  void _scanText(CameraImage availableImage) async {

    final latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final chineseRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    // final japaneseRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
    // final koreanRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final recognizers = [latinRecognizer,chineseRecognizer];


    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in availableImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: availableImage.toInputImageData());

    blockText.value = "";
    String temp = "";
    for(var recognizer in recognizers){
      final RecognizedText recognizedText = await recognizer.processImage(inputImage);
      getResult(recognizer,recognizedText).then((value) => temp+=value).whenComplete(() => blockText.value = temp);
      recognizer.close();
    }


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
