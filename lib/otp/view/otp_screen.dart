import 'package:bha_app_driver/common/constants/colors.dart';
import 'package:bha_app_driver/common/widgets/appBar.dart';
import 'package:bha_app_driver/common/widgets/black_button.dart';
import 'package:bha_app_driver/otp/service/otpService.dart';
import 'package:bha_app_driver/otp/view/widget/otp_text_field.dart';
import 'package:bha_app_driver/otp/view/widget/otp_timer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../login/view/login_screen.dart';
class OtpScreen extends StatefulWidget {
  String verificationId;

   OtpScreen({required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String  enteredOtp='';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    var screenHeight=MediaQuery.of(context).size.height;
    var screenWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar('Login / Register', [],true),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth*0.1,
        ),
        child: SingleChildScrollView(
          child: Column(
           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: screenHeight*0.04,),
              Text("We sent you a code to verify your\nphone number",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.8)
              ),
              textAlign: TextAlign.center,),
              SizedBox(height: screenHeight*0.02,),
              Text("Sent to ${LoginScreen.mobileNumber}",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.3)
              ),
              textAlign: TextAlign.center,),
              SizedBox(height: screenHeight*0.06,),
              otptextfield((value){
                print(value);
                setState(() {
                  enteredOtp=value;
                  print(enteredOtp);
                });
              },screenWidth),
              SizedBox(height: screenHeight*0.02,),
              OtpTimer(),
              SizedBox(height: screenHeight*0.08,),
              Text("I didn’t receive a code",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.3)
                ),
                textAlign: TextAlign.center,),
              SizedBox(height: screenHeight*0.012,),
              InkWell(
                onTap: (){
                  OtpService().resendPhoneAuth(LoginScreen.mobileNumber!, context);
                },
                child: Text(
                  "Resend",
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: splashBlue
                  ),
                ),
              ),
              SizedBox(height: screenHeight*0.05,),
              blackButton('Login Now', (){
                if(enteredOtp.length>=6){
                  OtpService().signInWithPhoneNumber(
                      widget.verificationId,
                      enteredOtp,
                      context
                  );
                }else{
                  Fluttertoast.showToast(msg: 'Enter valid otp');
                }

              }, screenWidth, screenHeight*0.05
              )
            ],
          ),
        ),
      ),
    );
  }
}
