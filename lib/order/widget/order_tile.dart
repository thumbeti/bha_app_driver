import 'package:bha_app_driver/order/order_detail_screen.dart';
import 'package:bha_app_driver/order/widget/product_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'orderProductTile.dart';

StreamBuilder orderTile(double width,double height,DocumentSnapshot snapshot,BuildContext context,String exeId){


  Map<String, dynamic> items=snapshot['items']as Map<String, dynamic>;
  List<String> skuList=[];
  List<String> quantityList=[];
  items.forEach((key, value) {
    skuList.add(key.toString());
    quantityList.add(value.toString());
  });
  DateTime date= DateTime.parse(snapshot['txTime'].toString());

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('vendors').where('vendorId',isEqualTo: snapshot['vendorId']).snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshotShop) {


      if (snapshotShop.connectionState == ConnectionState.waiting) {
        return Padding(
          padding:  EdgeInsets.only(top: height*0.35),
          child: Center(child: Text('Loading...')),
        );
      }
      if (snapshotShop.data!.docs.isEmpty) {
        return SizedBox.shrink();
      }
      return  Container(

        decoration:BoxDecoration(
            border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 2
            )
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Padding(
             padding: const EdgeInsets.only(left:8.0,right: 8,top: 8),
             child: Column(
               children: [
                 Row(
                   children: [
                     Expanded(
                       child: Text("Shop Name : ",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),),
                     ),
                     Expanded(
                       child: Text(snapshotShop.data!.docs[0]['shopName'],
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),overflow: TextOverflow.ellipsis,),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Expanded(
                       child: Text("Order ID : ",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),),
                     ),
                     Expanded(
                       child: Text(snapshot['orderId'],
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),overflow: TextOverflow.ellipsis,),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Expanded(
                       child: Text("Order Date&Time : ",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),),
                     ),
                     Expanded(
                       child: Text(DateFormat('d MMM y, hh:mm a').format(date),
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),overflow: TextOverflow.ellipsis,),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Expanded(
                       child: Text("Expected Delivery : ",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),),
                     ),
                     Expanded(
                       child: Text("${snapshot['deliveryTime'].toString()}",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),overflow: TextOverflow.ellipsis,),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Expanded(
                       child: Text("Order Status : ",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),),
                     ),
                     Expanded(
                       child: Text(snapshot['status'],
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Colors.green
                         ),overflow: TextOverflow.ellipsis,),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Expanded(
                       child: Text("Order Value : ",
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),),
                     ),
                     Expanded(
                       child: Text('₹${snapshot['orderAmount']}',
                         style: GoogleFonts.inter(
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             color: Color(0xff030303).withOpacity(0.7)
                         ),overflow: TextOverflow.ellipsis,),
                     ),
                   ],
                 ),
               ],
             ),
           ),
            Divider(thickness: 2,),
            Padding(
              padding:  EdgeInsets.only(left:8.0,right: 8,bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetail(orderid: snapshot['orderId'], sku: skuList, quqntity: quantityList, shopContact: snapshotShop.data!.docs[0]['mobile'], orderStatus: snapshot['status'],orderStatusDate: snapshot['txTime'],deliveryAddress: snapshot['deliveryAddress'],customerContact: snapshot['customerPhone'],
                            shopName:snapshotShop.data!.docs[0]['shopName'],deliveryTime: snapshot['deliveryTime'],orderTotal: snapshot['orderAmount'],exeId: exeId,shopAddress: snapshotShop.data!.docs[0]['address'],)));
                      },
                      child: Center(
                        child: Text(snapshot['status'].toString()=='Ready For Pickup'?'View Order':'View Order',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                          ),),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}