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
            SizedBox(
              width: 120,
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
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => TranslationCameraPage()));
                    logic.showCustomDialog(context,"要翻譯的語言",() async {


                      logic.enterCameraPage();

                      Navigator.pushNamed(context, "/CameraPage");

                    });
                  },
                  child: const AutoSizeText("相機動態翻譯",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,),)),
            ),
          ],
        ),
      ),
    );
  }
}
