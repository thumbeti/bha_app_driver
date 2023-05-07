import 'package:bha_app_driver/common/constants/colors.dart';
import 'package:bha_app_driver/order/service/getOrder.dart';
import 'package:bha_app_driver/order/widget/order_history_tile.dart';
import 'package:bha_app_driver/order/widget/order_tile.dart';
import 'package:bha_app_driver/order/widget/product_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widgets/appBar.dart';
import '../dashboard/dash_board_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});



  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool loaded=false;
  String ? userId;
  String exid='';
  getUid()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId=prefs.getString('uid');
      saveDatas();
    });
  }
  saveDatas()async{
    await FirebaseFirestore.instance.collection('executives').doc(userId).get().then((value) {
      setState(() {
        exid=value['ID'];
        loaded=true;
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUid();
  }
  @override
  Widget build(BuildContext context) {
    var screenHeight=MediaQuery.of(context).size.height;
    var screenWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar("Order History",
          [/*Padding(
            padding: const EdgeInsets.only(right:18.0),
            child: Row(
             children: [
               Image.asset('assets/home/Vector-4.png',
               height: 20,),
               SizedBox(width: 10,),
               Image.asset('assets/home/search.png',
               height: 24,color: Colors.black,),
             ],
            ),
          )*/],false),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth*0.07,
        ),
        child:loaded? Column(
          children: [

            SizedBox(height: screenHeight*0.03,),
            Expanded(child:
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').where('${'deliveringBy'}',isEqualTo: exid).where('status',isEqualTo: 'Delivered').orderBy('txTime',descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return SizedBox.shrink();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding:  EdgeInsets.only(top: 0),
                    child: Center(child: Text('Loading...')),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding:  EdgeInsets.only(top: 0),
                    child: Center(child: Text('Nothing Found!')),
                  );
                }
                return  ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom:14.0),
                      child: orderHistoryTile(screenWidth, screenHeight,
                          snapshot.data!.docs[index],context),
                    );
                  },
                );
              },
            )
            )
          ],
        ):Center(child: Text('Loading...')),
      ),
    );
  }

}
