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

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});



  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
bool loaded=false;
String ? userId;
List<String> zipCodeList=[];
List<String> sattuusList=[

  'Out For Delivery'
];
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
    print('hi hello testing '+value['activeAreas'].toString());
    setState(() {
      zipCodeList=List.from(value['activeAreas']);
      exid=value['ID'];
      loaded=true;
    });
  });
  print("ZZZZZZZZZZZZ  ${zipCodeList.toString()}");
}
String orderType='new_orders';
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
      appBar: appBar("My Orders",
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
            SizedBox(height: screenHeight*0.01,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      orderType='new_orders';
                    });
                  },
                  child: Container(
                    height: screenHeight*0.055,
                    width: screenWidth*0.39,
                    decoration: BoxDecoration(
                        color: orderType=='new_orders'?splashBlue.withOpacity(0.2):Colors.white,
                        border: Border.all(
                            color: orderType=='new_orders'?splashBlue:Colors.black)
                    ),
                    child: Center(
                      child: Text('New Orders',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: orderType=='new_orders'?splashBlue:Colors.black
                        ),),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      orderType='ongoing_orders';
                    });
                  },
                  child: Container(
                    height: screenHeight*0.055,
                    width: screenWidth*0.39,
                    decoration: BoxDecoration(
                        color: orderType=='ongoing_orders'?splashBlue.withOpacity(0.2):Colors.white,
                        border: Border.all(
                            color: orderType=='ongoing_orders'?splashBlue:Colors.black)
                    ),
                    child: Center(
                      child: Text('Ongoing Orders',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: orderType=='ongoing_orders'?splashBlue:Colors.black
                        ),),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight*0.03,),
            Expanded(child:
            orderType=='ongoing_orders'?
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').where('status',isEqualTo:'Out For Delivery').where('deliveringBy',isEqualTo: exid).snapshots(),
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
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom:14.0),
                      child: orderTile(screenWidth, screenHeight,
                          snapshot.data!.docs[index],context,exid),
                    );
                  },
                );
              },
            ):
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').where('DeliveringService',isEqualTo:'BhaApp').where('${'deliveryPincode'}',whereIn: zipCodeList).where('status',isEqualTo:'Ready For Pickup').where('deliveringBy',isEqualTo: '').snapshots(),

              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {



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
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom:14.0),
                      child: orderTile(screenWidth, screenHeight,
                          snapshot.data!.docs[index],context,exid),
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
