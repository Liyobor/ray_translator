import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ray_translator/instruction_dialog_box.dart';

import '../drop_down_dialog_box.dart';
import '../translation_camera_page/logic.dart';

enum Languages {
  latin("拉丁文"),
  japanese("日文"),
  korean("韓文");

  const Languages(this.value);
  final String value;
}


class HomeLogic extends GetxController {

  final List<Languages> languages = [Languages.latin, Languages.japanese, Languages.korean];
  Languages selectedLanguage = Languages.latin;

  var isDialogShowing = false;



  @override
  void onInit() {
    if (kDebugMode) {
      print("HomeLogic onInit");
    }
    super.onInit();
  }

  @override
  void onClose(){
    if (kDebugMode) {
      print("HomeLogic onClosed");
    }
    super.onClose();
  }

  showInstructionDialog(BuildContext context,String text){
    return showDialog(context: context, builder: (BuildContext context){
      isDialogShowing = true;
      return InstructionDialogBox(text: text,asset: "assets/doge1.png",);
    }).then((value) => isDialogShowing = false);
  }

  showCustomDialog(BuildContext context,String text,Function() acceptActions){
    return showDialog(context: context, builder: (BuildContext context){
      isDialogShowing = true;
      return DropDownDialogBox(
        text: text,
        onAccept: (){
          acceptActions();
        },
      );
    }).then((value) => isDialogShowing = false);
  }

  Future<bool> checkIfModelDownloaded(OnDeviceTranslatorModelManager modelManager) async {
    switch(selectedLanguage){
      case Languages.latin:
        final bool response = await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
        return response;
      case Languages.japanese:
        final bool response = await modelManager.isModelDownloaded(TranslateLanguage.japanese.bcpCode);
        return response;
      case Languages.korean:
        final bool response = await modelManager.isModelDownloaded(TranslateLanguage.korean.bcpCode);
        return response;
    }
  }

  void enterCameraPage() {
    final translationCameraLogic = Get.put(TranslationCameraLogic());
    translationCameraLogic.init();
  }
}
