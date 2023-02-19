import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
late List<CameraDescription> cameras;
class HomeLogic extends GetxController {

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late CameraController controller;



  // var blockText = "".obs;
  var textList = [].obs;
  var rectList = [];
  var height,width;
  var orientation = Orientation.portrait;
  var mobileWidth = 0.0,mobileHeight = 0.0;


  @override
  void onInit() {
    super.onInit();



    // Timer.periodic(const Duration(seconds: 7), (timer) async {
    //   if (kDebugMode) {
    //     print("tick");
    //   }
    //   detectText();
    //
    //
    // });
  }

  @override
  void dispose() {
    super.dispose();
    controller.stopImageStream();
  }

  void orientationChange(Orientation newOrientation){
    mobileWidth = 0.0;
    mobileHeight = 0.0;
    orientation = newOrientation;
    textList.clear();
    rectList.clear();
  }

  void detectText(){


    if(navigatorKey.currentContext!=null && mobileHeight == 0.0){

      if (kDebugMode) {
        print("get screen width and height");
        print("screen width = ${MediaQuery.of(navigatorKey.currentContext!).size.width}");
        print("screen height = ${MediaQuery.of(navigatorKey.currentContext!).size.height}");
      }
      orientation = MediaQuery.of(navigatorKey.currentContext!).orientation;
      mobileWidth = MediaQuery.of(navigatorKey.currentContext!).size.width ;
      mobileHeight = MediaQuery.of(navigatorKey.currentContext!).size.height;
    }


    var c = 0;
    controller.setFocusMode(FocusMode.auto);
    controller.startImageStream((image) async {

      controller.stopImageStream();
      // c++;
      // if(c==5){

        if (kDebugMode) {
          print("height = ${image.height}");
          print("width = ${image.width}");
        }

        height = image.height;
        width = image.width;

        await _scanText(image);


      // }
    });
  }

  final List<String> languageList = ["zh","en","am"];

  Future<void> getResult(TextRecognizer recognizer,RecognizedText text) async {
    // String lineString = "";
    for (TextBlock block in text.blocks) {
      // final Rect rect = block.boundingBox;
      // final List<Point<int>> cornerPoints = block.cornerPoints;
      // final String text = block.text;
      //
      //
      //
      // final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {






        if (kDebugMode) {
          print("boundingBox = ${line.boundingBox}");
          print("cornerPoints = ${line.cornerPoints}");
          print("recognizedLanguages = ${line.recognizedLanguages}");
          print("text = ${line.text}");
          // print(languageList.contains(line.recognizedLanguages[0]));
          // print(recognizer.script);
        }


        // switch(recognizer.script){
        //   case TextRecognitionScript.chinese:
        //     if(line.recognizedLanguages[0]!="zh"){
        //       continue;
        //     }
        //     break;
        //   case TextRecognitionScript.latin:
        //     if(line.recognizedLanguages[0]!="en"){
        //       continue;
        //     }
        //     break;
        //   case TextRecognitionScript.devanagiri:
        //     // TODO: Handle this case.
        //     break;
        //   case TextRecognitionScript.japanese:
        //     // TODO: Handle this case.
        //     break;
        //   case TextRecognitionScript.korean:
        //     // TODO: Handle this case.
        //     break;
        // }


        switch(orientation){
          case Orientation.portrait:
            final lineRect = line.boundingBox;
            final scaleOfX = mobileWidth/height;
            final scaleOfY = mobileHeight/width;

            final scaledRect = Rect.fromLTRB(lineRect.left*scaleOfX, lineRect.top*scaleOfY,lineRect.right*scaleOfX, lineRect.bottom*scaleOfY);
            rectList.add(scaledRect);
            textList.add(line);
            break;
          case Orientation.landscape:
            final lineRect = line.boundingBox;
            final top = lineRect.left/height*mobileHeight;
            final bottom = lineRect.right/height*mobileHeight;
            final right = (width-lineRect.top)/width*mobileWidth;
            final left = (width-lineRect.bottom)/width*mobileWidth;
            // final scaledRect = Rect.fromLTRB(lineRect.left*scaleOfX, lineRect.top*scaleOfY,lineRect.right*scaleOfX, lineRect.bottom*scaleOfY);
            // final scaledRect = Rect.fromLTRB(lineRect.bottom*scaleOfY,lineRect.left*scaleOfX,lineRect.top*scaleOfY,lineRect.right*scaleOfX);
            final scaledRect = Rect.fromLTRB(left,top,right,bottom);

            if (kDebugMode) {
              print("scaledRect = $scaledRect");
            }
            rectList.add(scaledRect);
            textList.add(line);
            break;
        }


        // if(lineString.isEmpty){
        //   lineString = line.text;
        // }else{
        //   lineString+="\n${line.text}";
        // }
        // for (TextElement element in line.elements) {
        //   if (kDebugMode) {
        //     print("element = ${element.text}");
        //   }
        // }
      }
    }
    // return lineString;
  }




  Future<void> _scanText(CameraImage availableImage) async {

    // final latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final chineseRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    // final japaneseRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
    // final koreanRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final recognizers = [chineseRecognizer];


    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in availableImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: availableImage.toInputImageData());

    // blockText.value = "";
    // String temp = "";
    textList.clear();
    rectList.clear();
    for(var recognizer in recognizers){
      final RecognizedText recognizedText = await recognizer.processImage(inputImage);
      getResult(recognizer,recognizedText);
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
