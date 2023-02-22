import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'home/logic.dart';

class CustomDialogBox extends StatefulWidget {
  final String text,asset;
  final Function onAccept;

  const CustomDialogBox({Key? key, required this.text,this.asset = "assets/doge2.png",required this.onAccept}) : super(key: key);

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  static const double avatarRadius =45;
  static const double padding =20;
  static const mainTiffanyGreen = Color(0xff5DC7AA);
  static const typeTextColor = Color(0xff595757);





  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print("CustomDialogBox dispose");
    }
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 只允許垂直方向
    ]);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    final logic = Get.put(HomeLogic());
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: padding,top: avatarRadius
              + padding, right: padding,bottom: padding
          ),
          margin: const EdgeInsets.only(top: avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: const [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AutoSizeText(widget.text,style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: typeTextColor),),
                      DropdownButton(
                        value: logic.selectedLanguage,
                        items: logic.languages.map((Languages option) {
                          return DropdownMenuItem<Languages>(
                            value: option,
                            child: AutoSizeText(option.value,style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: typeTextColor)),
                          );
                        }).toList(),
                        onChanged: (Languages? newValue) async {
                          setState(() {
                            logic.selectedLanguage = newValue!;
                          });
                          final modelManager = OnDeviceTranslatorModelManager();
                          EasyLoading.dismiss();
                          EasyLoading.show(status: '確認有無下載模型...');
                          await logic.checkIfModelDownloaded(modelManager).then((value) async {
                            if(!value){
                              EasyLoading.dismiss();
                              EasyLoading.show(status: '開始下載模型...');
                              switch(logic.selectedLanguage){
                                case Languages.english:
                                  await modelManager.downloadModel(TranslateLanguage.english.bcpCode).whenComplete((){
                                    if (kDebugMode) {
                                      print("download competlete");
                                    }
                                    EasyLoading.dismiss();

                                  });
                                  break;
                                case Languages.japanese:
                                  await modelManager.downloadModel(TranslateLanguage.japanese.bcpCode).whenComplete((){
                                    if (kDebugMode) {
                                      print("download competlete");
                                    }
                                    EasyLoading.dismiss();

                                  });
                                  break;
                                case Languages.korean:
                                  await modelManager.downloadModel(TranslateLanguage.korean.bcpCode).whenComplete((){
                                    if (kDebugMode) {
                                      print("download competlete");
                                    }
                                    EasyLoading.dismiss();

                                  });
                                  break;
                              }
                            }
                            EasyLoading.dismiss();

                          });




                        },),
                    ],),
                ],
              ),
              const SizedBox(height: 52,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                            foregroundColor: MaterialStateProperty.all<Color>(mainTiffanyGreen),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: const BorderSide(color: mainTiffanyGreen)
                                )
                            )
                        ),
                        onPressed: (){
                          Navigator.of(context).pop();
                          widget.onAccept();

                        },
                        child: const Text(
                          "接受",
                          style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 8.0,
                              fontWeight: FontWeight.w400,
                              color: typeTextColor),
                        )),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: const MaterialStatePropertyAll<Color>(mainTiffanyGreen),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: const BorderSide(color: mainTiffanyGreen)
                                )
                            )
                        ),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: const Text("取消",
                          style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 8.0,
                            fontWeight: FontWeight.w400,),)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: padding,
          right: padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: avatarRadius,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(avatarRadius)),
                child: Image.asset(widget.asset)
            ),
          ),
        ),
      ],
    );
  }
}