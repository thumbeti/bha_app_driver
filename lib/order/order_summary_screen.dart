import 'dart:convert';

import 'package:bha_app_driver/order/widget/order_summary_tile.dart';
import 'package:bha_app_driver/order/widget/order_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../common/constants/colors.dart';
import '../common/widgets/appBar.dart';
import '../common/widgets/black_button.dart';
import 'model/orderStatusModel.dart';

class OrderSummary extends StatefulWidget {
  String orderid;
  List<String>sku=[];
  List<String>quqntity=[];
  String shopContact;
  String shopName;
  String shopAddress;
  String orderStatus;
  String orderStatusDate;
  OrderSummary({Key? key,required this.orderid,required this.sku,required this.quqntity,required this.shopContact,required this.orderStatus,required this.orderStatusDate,
  required this.shopName,required this.shopAddress}) : super(key: key);

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {

  List<OrderStatusModel> satatusList=[];
  getStatusList()async{
    String stsList=  await FirebaseFirestore.instance.collection('orders').doc(widget.orderid).get().then((value) {
      return value['DeliveryStatus'].toString();
    });
    setState(() {
      var convert=json.decode(stsList);
      print(convert);
      print(convert[0]['name']);
      for(var i=0;i<convert.length;i++){
        satatusList.add(OrderStatusModel(name: convert[i]['name'], status: convert[i]['status'], date: convert[i]['date'],image: convert[i]['image']));
      }
    });

    /* await FirebaseFirestore.instance.collection('orders').doc(widget.orderid).collection('DeliveryStatus').get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((doc) {
        setState(() {
          satatusList.add(OrderStatusModel(name: doc['name'], status: doc['status'], date: doc['date']));
        });
      });
    });*/

  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatusList();
  }



  @override
  Widget build(BuildContext context) {
    var screenHeight=MediaQuery.of(context).size.height;
    var screenWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar("Order Details",
          [],true),
      body: Container(
        height: screenHeight,
        width: screenWidth,

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').where('orderId',isEqualTo: widget.orderid).snapshots(),
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
            return  Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth,
                          height: screenHeight*0.065,
                          color: Color(0xff28B446).withOpacity(0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/home/Group 78.png',
                                color: Color(0xff28B446),
                                height: 13.5,width: 24,) ,
                              Text('  The Order was delivered',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xff28B446)
                                ),)
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight*0.03,),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth*0.07,

                          ),
                          child: Column(
                            children: [
                              orderSummaryTile(
                                  screenWidth,
                                  screenHeight,
                                  widget.sku,
                                  widget.quqntity,
                                  widget.shopName,
                                  widget.shopAddress,
                                  snapshot.data!.docs[0]['orderAmount']

                              ),
                              SizedBox(height: screenHeight*0.03,),
                              Row(
                                children: [
                                  Text('Order Details',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black.withOpacity(0.8)
                                    ),)
                                ],
                              ),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order ID:',style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),),
                                  Text(snapshot.data!.docs[0]['orderId'],style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: splashBlue
                                  ),),

                                ],
                              ),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Payment',style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),),
                                  Text(snapshot.data!.docs[0]['paymentMode'],style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),),

                                ],
                              ),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Delivery Date',style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),),
                                  Text(snapshot.data!.docs[0]['deliveryTime'].toString().split(',')[0],style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black
                                  ),),

                                ],
                              ),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Delivery Address',style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),),
                                  Container(
                                    width: screenWidth*0.4,
                                    child: Text(snapshot.data!.docs[0]['deliveryAddress'],style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black.withOpacity(0.6)
                                    ),textAlign: TextAlign.right,),
                                  ),

                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Text('Tracking Details',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black.withOpacity(0.8)
                                    ),)
                                ],
                              ),

                              SizedBox(height: 10,),

                              widget.orderStatus.toLowerCase()=='order cancelled'?
                              Text("Order Cancelled",style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red
                              ),):
                              OrderTracker(orderStatus: widget.orderStatus,orderStatusDate: widget.orderStatusDate,statusList: satatusList,)
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                ),
                /*Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.07,
                      vertical: screenHeight*0.01
                  ),
                  child: blackButton("Repeat Order", (){}, screenWidth, screenHeight*0.05),
                )*/

              ],
            );
          },
        )

      ),
    );
  }
}
