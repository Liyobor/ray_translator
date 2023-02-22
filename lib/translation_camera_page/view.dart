import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../camera.dart';
import 'logic.dart';

class TranslationCameraPage extends StatelessWidget {
  final logic = Get.put(TranslationCameraLogic());

  TranslationCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder:(BuildContext context,Orientation orientation) {
        logic.orientationChange(orientation);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color(0x44000000),
            elevation: 0.0,
            title: const Text("data"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: (){
                logic.controller.dispose();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: WillPopScope(
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
              // Camera(
              //   child: Obx((){
              //     return Stack(
              //       children: [
              //         for (var i = 0; i < logic.textList.length; i++)
              //           Positioned.fromRect(
              //               rect: logic.rectList[i],
              //               child: Opacity(
              //                 opacity: 0.7,
              //                 child: Container(
              //                     color: Colors.green,
              //                     child: FittedBox(
              //                         fit: BoxFit.scaleDown,
              //                         child: Text(logic.textList[i],style: const TextStyle(fontSize: 500),))),
              //               )),
              //       ],
              //     );
              //   }),
              // )

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
                              child: AutoSizeText(logic.textList[i],style: const TextStyle(fontSize: 500),)),
                        )),

                ]);
              }),
            ),
          ),
        );
      },
    );
  }
}
