import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HomeLogic());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mainPageButton(context,"ChatGPT翻譯器",(){
              logic.showCustomDialog(context,"要翻譯的語言",() async {
                logic.enterCameraPage();
                Navigator.pushNamed(context, "/CameraPage");
              });
            }),

            Container(height: 30,),
            mainPageButton(context,"使用說明",(){
              logic.showInstructionDialog(context, "點擊ChatGPT翻譯器\n對準要翻譯的文字\n點擊畫面可對焦點擊處\n並按下翻譯鍵\n\n拉丁文包含下列語言\n英語, 西班牙語, 法語, 德語, 意大利語, 葡萄牙語, 荷蘭語, 瑞典語, 丹麥語, 挪威語, 芬蘭語, 波蘭語, 捷克語, 斯洛伐克語, 斯洛維尼亞語, 克羅地亞語, 羅馬尼亞語, 匈牙利語, 保加利亞語");
            }),
          ],
        ),
      ),
    );
  }


  Widget mainPageButton(BuildContext context,String text,Function onPressed){
    return SizedBox(
      width: 150,
      height: 60,
      child: TextButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff5DC7AA)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: const BorderSide(color: Color(0xff5DC7AA))
                  )
              )
          ),
          onPressed: (){
            onPressed();
          },
          child: AutoSizeText(text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,),)),
    );
  }
}
