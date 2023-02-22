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
                  child:
                  Obx(() {
                    return Stack(children: [
                      const Camera(),
                      for (var i = 0; i < logic.textList.length; i++)
                        Positioned.fromRect(
                            rect: logic.rectList[i],
                            child: Opacity(
                              opacity: 0.7,
                              child: Container(
                                  color: Colors.green,
                                  child: AutoSizeText(logic.textList[i],style: const TextStyle(fontSize: 500,fontWeight: FontWeight.bold),)),
                            )),

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
