
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_ai_translator/camera.dart';

import 'logic.dart';

class HomePage extends StatelessWidget {
  final logic = Get.put(HomeLogic());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          await logic.controller.dispose();
          return true;
        },
        child: Stack(
            children: [
              Camera(),
              Center(
                child: Obx((){
                  return Text(logic.blockText.value);
                }),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: TextButton(
              //     onPressed: () {
              //     logic.detectText();},
              //     child: const Text("辨識文字",textScaleFactor: 1.15),),
              // )
            ]),
      ),
    );
  }
}
