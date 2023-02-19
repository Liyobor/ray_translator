import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:synchronized/synchronized.dart';
late List<CameraDescription> cameras;


enum Status {
  running,
  available,
}
class HomeLogic extends GetxController {

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late CameraController controller;


  var status = Status.available.obs;

  // var blockText = "".obs;
  var lineList = <TextLine>[];
  var textList = [].obs;
  var textListEver;
  var rectList = [];
  var height,width;
  var orientation = Orientation.portrait;
  var mobileWidth = 0.0,mobileHeight = 0.0;

  var isTerminate = false;



  @override
  void dispose() {
    super.dispose();
    controller.stopImageStream();
  }

  void orientationChange(Orientation newOrientation){
    mobileWidth = 0.0;
    mobileHeight = 0.0;
    orientation = newOrientation;
    clearText();
    setMobileSize();
  }

  void setMobileSize(){
    if(navigatorKey.currentContext!=null){
      orientation = MediaQuery.of(navigatorKey.currentContext!).orientation;
      mobileWidth = MediaQuery.of(navigatorKey.currentContext!).size.width ;
      mobileHeight = MediaQuery.of(navigatorKey.currentContext!).size.height;
    }
  }

  void detectText(){

    controller.setFocusMode(FocusMode.auto);
    controller.startImageStream((image) async {

      if(status.value==Status.running) return;


        height = image.height;
        width = image.width;
        setMobileSize();

        status.value = Status.running;
        _scanText(image);


      // }
    });
  }

  final List<String> languageList = ["zh","en"];

  Future<void> getResult(TextRecognizer recognizer,RecognizedText text) async {
    // String lineString = "";
    clearTemp();
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
            lineList.add(line);

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
            lineList.add(line);

            break;
        }


        // if (kDebugMode) {
        //   print("lineList size = ${lineList.length}");
        //   print("rectList size = ${rectList.length}");
        // }




        // for(var item in lineList){
        //   if(item.recognizedLanguages[0]=="en"){
        //     _translate(item.text).then((value) {
        //       if (kDebugMode) {
        //         print("translate value = $value}");
        //       }
        //       temp.add(value);
        //     });
        //   }else{
        //     temp.add(item.text);
        //   }
        // }




      }
    }
  }

  Future<String> _translate(
      String text,
      {TranslateLanguage sourceLanguage = TranslateLanguage.english,
      TranslateLanguage targetLanguage = TranslateLanguage.chinese}) async {
    final onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
    final String response = await onDeviceTranslator.translateText(text);
    onDeviceTranslator.close();
    return response;
  }



  Future<void> _scanText(CameraImage availableImage) async {


    // final latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final chineseRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    // final japaneseRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
    // final koreanRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    // final recognizers = [chineseRecognizer];


    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in availableImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: availableImage.toInputImageData());

    // blockText.value = "";
    // String temp = "";


    // for(var recognizer in recognizers){
      final RecognizedText recognizedText = await chineseRecognizer.processImage(inputImage);
      await getResult(chineseRecognizer, recognizedText).then((value) async {
        chineseRecognizer.close();
        await _refreshText();
      });
      // await getResult(recognizer,recognizedText);
      // recognizer.close();
      // await _translateOperation();
    // }


    status.value = Status.available;


  }

  Future<void> _refreshText () async {
    var temp = [];


    for(var i=0;i<lineList.length;i++){
      if (kDebugMode) {
        print("lineList text = ${lineList[i].text}");
      }
      if(lineList[i].recognizedLanguages[0].contains("en")){
        temp.add(await _translate(lineList[i].text));
        // textList.add(await _translate(lineList[i].text));

      }else{
        temp.add(lineList[i].text);
        // textList.add(lineList[i].text);
      }
    }
    clearText();
    textList.addAll(temp);

  }

  void clearText(){
    textList.clear();
  }
  void clearTemp(){
    lineList.clear();
    rectList.clear();
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
