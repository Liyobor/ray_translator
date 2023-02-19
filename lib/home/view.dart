import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_ai_translator/camera.dart';

import 'logic.dart';

class HomePage extends StatelessWidget {
  final logic = Get.put(HomeLogic());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder:(BuildContext context,Orientation orientation) {
        logic.orientationChange(orientation);
        return Scaffold(
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
              child: Obx(() {
                return Stack(children: [
                  const Camera(),
                  for (var i = 0; i < logic.textList.length; i++)
                    Positioned.fromRect(
                        rect: logic.rectList[i],
                        child: Opacity(
                          opacity: 0.4,
                          child: Container(
                              color: Colors.green,
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(logic.textList[i].text,style: const TextStyle(fontSize: 500),))),
                        )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.blueAccent,
                      child: TextButton(
                        onPressed: () {
                          logic.detectText();
                        },
                        child: const Text(
                          "辨識文字",
                          textScaleFactor: 1.15,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ]);
              }),
            ),
          ),
        );
      },
    );
  }
}
