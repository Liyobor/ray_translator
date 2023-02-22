import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../custom_dialog_box.dart';
import '../translation_camera_page/logic.dart';

enum Languages {
  english("英文"),
  japanese("日文"),
  korean("韓文");

  const Languages(this.value);
  final String value;
}


class HomeLogic extends GetxController {

  final List<Languages> languages = [Languages.english, Languages.japanese, Languages.korean];
  Languages selectedLanguage = Languages.english;

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
  showCustomDialog(BuildContext context,String text,Function() acceptActions){
    return showDialog(context: context, builder: (BuildContext context){
      isDialogShowing = true;
      return CustomDialogBox(
        text: text,
        onAccept: (){
          acceptActions();
        },
      );
    }).then((value) => isDialogShowing = false);
  }

  Future<bool> checkIfModelDownloaded(OnDeviceTranslatorModelManager modelManager) async {
    switch(selectedLanguage){
      case Languages.english:
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
