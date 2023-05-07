import 'package:bha_app_driver/dashboard/widget/bottombar_icon.dart';
import 'package:bha_app_driver/login/service/loginService.dart';
import 'package:bha_app_driver/order/order_history_screen.dart';
import 'package:bha_app_driver/profile/profile_screen.dart';
import 'package:bha_app_driver/register/services/registerService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants/colors.dart';
import '../order/my_orders_screen.dart';


int pageIndex = 0;

class DashBoardScreen extends StatefulWidget {

const DashBoardScreen({Key? key}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final pages = [
    OrderScreen(),
    ProfileScreen(),
    OrderHistoryScreen(),
  ];
  DateTime ? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press back again to exit');
      return Future.value(false);
    }
    return Future.value(true);

  }

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
     appBar: PreferredSize(
       preferredSize: Size.fromHeight(0),
       child: AppBar(
         elevation: 0,
         backgroundColor: Colors.transparent,
         systemOverlayStyle: SystemUiOverlayStyle.dark,
       ),
     ),
      backgroundColor: Colors.white,
      body: WillPopScope(
          onWillPop: onWillPop,
          child: pages[pageIndex]),
      bottomNavigationBar: buildMyNavBar(context,screenHeight,screenWidth),
    );
  }
  Container buildMyNavBar(BuildContext context,double height,double width) {
    return Container(
      height: height*0.095,
      decoration: BoxDecoration(
        color: Colors.black,
        /*borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),*/
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            BottomIcon(
                    (){
                  setState(() {
                    pageIndex = 0;
                  });
                }
                ,0, 'package',height,'Orders'),
            BottomIcon(
                    (){
                  setState(() {
                    pageIndex = 1;
                  });
                }
                ,1, 'user-check-2',height,'Profile'),
            BottomIcon(
                    (){
                  setState(() {
                    pageIndex = 2;
                  });
                }
                ,2, 'shopping-bag',height,'History'),

          ],
        ),
      ),
    );
  }

}
