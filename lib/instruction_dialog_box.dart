import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'home/logic.dart';

class InstructionDialogBox extends StatefulWidget {
  final String text,asset;

  const InstructionDialogBox({Key? key, required this.text,this.asset = "assets/doge2.png"}) : super(key: key);

  @override
  State<InstructionDialogBox> createState() => _InstructionBoxState();
}

class _InstructionBoxState extends State<InstructionDialogBox> {
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
              Text(
                widget.text,
                // style: const TextStyle(
                //   fontSize: 18,
                //   fontWeight: FontWeight.w400,
                //   color: typeTextColor,),
                style: Theme.of(context).textTheme.bodyText1?.apply(fontSizeFactor: 1.25),
              textAlign: TextAlign.center,),
              const SizedBox(height: 52,),
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
                    },
                    child: const Text(
                      "確定",
                      style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 8.0,
                          fontWeight: FontWeight.w400,
                          color: typeTextColor),
                    )),
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