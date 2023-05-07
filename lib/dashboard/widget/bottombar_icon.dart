import 'dart:async';

import 'package:bha_app_driver/common/constants/colors.dart';
import 'package:bha_app_driver/dashboard/dash_board_screen.dart';
import 'package:bha_app_driver/dashboard/widget/bottombar_dot_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final stream_controller = StreamController<bool>();
Column BottomIcon(VoidCallback onTap,int index,String image,double height,String title){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
     /* pageIndex == index ?
      BottomDotBlue():BottomDotTransparent(),*/
      Stack(
        children: [

          IconButton(
              enableFeedback: false,
              onPressed:onTap,
              icon:  Image.asset(
                'assets/dashboard/$image.png',
                color:pageIndex == index ?  Colors.white:bottom_grey,
                height: height*0.035,
                width: height*0.035,
              )
          ),


        ],
      ),
      Text(title,
        style: GoogleFonts.inter(
            color:pageIndex == index ?  Colors.white:bottom_grey,
            fontSize: 10
        ),)
    ],
  );
}