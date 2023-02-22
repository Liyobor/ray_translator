import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import '../home/logic.dart';
late List<CameraDescription> cameras;

enum Status {
  running,
  available,
}


enum DetectType{
  block,
  line
}
class TranslationCameraLogic extends GetxController {

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late CameraController controller;


  var status = Status.available.obs;

  // var blockText = "".obs;
  var lineList = <TextLine>[];
  var blockList = <TextBlock>[];
  var textList = [].obs;
  var rectList = [];
  dynamic height,width;
  var orientation = NativeDeviceOrientation.portraitUp;
  var mobileWidth = 0.0,mobileHeight = 0.0;

  var isTerminate = false;

  late TextRecognizer recognizer;
  late OnDeviceTranslator onDeviceTranslator;


  void stop(){
    controller.stopImageStream().then((value) => controller.dispose());
    recognizer.close();
    onDeviceTranslator.close();
  }



  Future<void> orientationChange() async {
    final newOrientation = await NativeDeviceOrientationCommunicator().orientation(useSensor: false);

    if (kDebugMode) {
      print("newOrientation = $newOrientation");
    }
    mobileWidth = 0.0;
    mobileHeight = 0.0;
    orientation = newOrientation;
    clearText();
  }

  void setMobileSize(){
    if(navigatorKey.currentContext!=null){
      mobileWidth = MediaQuery.of(navigatorKey.currentContext!).size.width ;
      mobileHeight = MediaQuery.of(navigatorKey.currentContext!).size.height;
    }
  }


  void init(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 允許垂直方向
      DeviceOrientation.landscapeLeft, // 允許左橫向
      DeviceOrientation.landscapeRight, // 允許右橫向
    ]);
    recognizer = chooseRecognizer();
    onDeviceTranslator = chooseTranslator();
  }

  void detectText(){

    controller.setFocusMode(FocusMode.auto);
    controller.startImageStream((image){

      if(status.value==Status.running) return;
        height = image.height;
        width = image.width;
        setMobileSize();
        status.value = Status.running;
        _scanText(image,DetectType.block);

    });
  }

  Future<void> getResult(TextRecognizer recognizer,RecognizedText text) async {

    clearTemp();
    for (TextBlock block in text.blocks) {

      switch(orientation){
        case NativeDeviceOrientation.portraitUp:
          final blockRect = block.boundingBox;
          final scaleOfX = mobileWidth/height;
          final scaleOfY = mobileHeight/width;

          final scaledRect = Rect.fromLTRB(blockRect.left*scaleOfX, blockRect.top*scaleOfY,blockRect.right*scaleOfX, blockRect.bottom*scaleOfY);
          rectList.add(scaledRect);
          blockList.add(block);
          break;
        case NativeDeviceOrientation.portraitDown:
          final blockRect = block.boundingBox;
          final scaleOfX = mobileWidth/height;
          final scaleOfY = mobileHeight/width;

          final scaledRect = Rect.fromLTRB(blockRect.left*scaleOfX, blockRect.top*scaleOfY,blockRect.right*scaleOfX, blockRect.bottom*scaleOfY);
          rectList.add(scaledRect);
          blockList.add(block);
          break;
        case NativeDeviceOrientation.landscapeLeft:
          final blockRect = block.boundingBox;
          final bottom = (height-blockRect.left)/height*mobileHeight;
          final top = (height-blockRect.right)/height*mobileHeight;
          final left = (blockRect.top)/width*mobileWidth;
          final right = (blockRect.bottom)/width*mobileWidth;
          final scaledRect = Rect.fromLTRB(left,top,right,bottom);
          rectList.add(scaledRect);
          blockList.add(block);
          break;
        case NativeDeviceOrientation.landscapeRight:
          final blockRect = block.boundingBox;
          final top = blockRect.left/height*mobileHeight;
          final bottom = blockRect.right/height*mobileHeight;
          final right = (width-blockRect.top)/width*mobileWidth;
          final left = (width-blockRect.bottom)/width*mobileWidth;
          final scaledRect = Rect.fromLTRB(left,top,right,bottom);
          rectList.add(scaledRect);
          blockList.add(block);
          break;
        case NativeDeviceOrientation.unknown:
          final blockRect = block.boundingBox;
          final scaleOfX = mobileWidth/height;
          final scaleOfY = mobileHeight/width;

          final scaledRect = Rect.fromLTRB(blockRect.left*scaleOfX, blockRect.top*scaleOfY,blockRect.right*scaleOfX, blockRect.bottom*scaleOfY);
          rectList.add(scaledRect);
          blockList.add(block);
          break;
      }

    }
  }
  OnDeviceTranslator chooseTranslator(){
    final homeLogic = Get.put(HomeLogic());
    switch(homeLogic.selectedLanguage){
      case Languages.english:
        return OnDeviceTranslator(sourceLanguage: TranslateLanguage.english, targetLanguage: TranslateLanguage.chinese);
      case Languages.japanese:
        return OnDeviceTranslator(sourceLanguage: TranslateLanguage.japanese, targetLanguage: TranslateLanguage.chinese);
      case Languages.korean:
        return OnDeviceTranslator(sourceLanguage: TranslateLanguage.korean, targetLanguage: TranslateLanguage.chinese);
    }
  }

  TextRecognizer chooseRecognizer(){
    final homeLogic = Get.put(HomeLogic());
    switch(homeLogic.selectedLanguage){
      case Languages.korean:
        final recognizer = TextRecognizer(script: TextRecognitionScript.korean);
        return recognizer;
      case Languages.english:
        final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
        return recognizer;
      case Languages.japanese:
        final recognizer = TextRecognizer(script: TextRecognitionScript.japanese);
        return recognizer;
    }
  }

  Future<void> _scanText(CameraImage availableImage,DetectType type) async {



    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in availableImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: availableImage.toInputImageData());

    final RecognizedText recognizedText = await recognizer.processImage(inputImage);
    await getResult(recognizer, recognizedText).then((value) async {
      if(type == DetectType.line) {
        await _refreshTextByLine();
      } else if(type == DetectType.block) {
        await _refreshTextByBlock();
      }
    });
    await Future.delayed(const Duration(milliseconds: 3500));
    status.value = Status.available;

  }

  Future<void> _refreshTextByBlock () async {
    var temp = [];

    for(var i=0;i<blockList.length;i++){
      if(checkIfBlockHaveToTranslate(blockList[i])){
        temp.add(await onDeviceTranslator.translateText(blockList[i].text));
      }else{
        temp.add(blockList[i].text);
      }
    }
    clearText();
    textList.addAll(temp);

  }

  bool checkIfBlockHaveToTranslate(TextBlock block){

    final homeLogic = Get.put(HomeLogic());


    switch(homeLogic.selectedLanguage){

      case Languages.english:
        for(var lines in block.lines){
          if(lines.recognizedLanguages.contains("en")) return true;
        }
        return false;

      case Languages.japanese:
        for(var lines in block.lines){
          if(lines.recognizedLanguages.contains("ja")) return true;
        }
        return false;
      case Languages.korean:
        for(var lines in block.lines){
          if(lines.recognizedLanguages.contains("ko")) return true;
        }
        return false;
    }

  }

  Future<void> _refreshTextByLine () async {
    var temp = [];


    for(var i=0;i<lineList.length;i++){
      if (kDebugMode) {
        print("lineList text = ${lineList[i].text}");
      }
      if(lineList[i].recognizedLanguages[0].contains("en")){
        temp.add(await onDeviceTranslator.translateText(lineList[i].text));
      }else{
        temp.add(lineList[i].text);
      }
    }
    clearText();
    textList.addAll(temp);

  }

  void clearText(){
    textList.clear();
  }
  void clearTemp(){
    blockList.clear();
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
