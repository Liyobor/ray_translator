import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../camera.dart';
import 'logic.dart';

class TranslationCameraPage extends StatelessWidget {


  const TranslationCameraPage({super.key});

  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(
      builder:(BuildContext context,Orientation orientation) {
        final logic = Get.put(TranslationCameraLogic());
        logic.orientationChange();
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [

              WillPopScope(
                onWillPop: () async {
                  await logic.controller.dispose();
                  return true;
                },
                child: GestureDetector(
                  onTapDown: (details){
                    if (kDebugMode) {
                      print("globalPosition dx = ${details.globalPosition.dx}");
                      print("globalPosition dy = ${details.globalPosition.dy}");
                    }
                    logic.setMobileSize();
                    logic.controller.setFocusPoint(Offset(details.globalPosition.dx/logic.mobileWidth, details.globalPosition.dy/logic.mobileHeight));
                  },
                  child: Obx(() {
                    return Stack(children: [

                      const Camera(),

                      for (var i = 0; i < logic.textList.length; i++)
                        Positioned.fromRect(
                            rect: logic.rectList[i],
                            child: Container(
                                color: Colors.green.withOpacity(0.35),
                                child: AutoSizeText(logic.textList[i],minFontSize: 5,maxLines: 30,style: const TextStyle(fontSize: 500,fontWeight: FontWeight.bold),))),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextButton(
                                    onPressed: () {
                                      logic.clearText();
                                    },
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                        backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff5DC7AA)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: const BorderSide(color: Color(0xff5DC7AA))
                                            )
                                        )
                                    ),
                                    child: const Text("清除",style: TextStyle(fontSize: 15,letterSpacing: 10),),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextButton(
                                      onPressed: () {
                                        if(logic.status.value == Status.running){
                                          logic.status.value = Status.available;
                                        }else{
                                          if (kDebugMode) {
                                            print("not available!");
                                          }
                                        }
                                      },
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                        backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff5DC7AA)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: const BorderSide(color: Color(0xff5DC7AA))
                                            )
                                        )
                                    ),
                                      child: const Text("翻譯",style: TextStyle(fontSize: 15,letterSpacing: 10),),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ]);
                  }),

                ),
              ),
              Positioned(
                  left: 10,
                  top: 40,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: (){
                      Navigator.of(context).pop();
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp, // 允許垂直方向
                      ]);
                    },
                  )
              ),
            ]
          ),
        );
      },
    );
  }
}
