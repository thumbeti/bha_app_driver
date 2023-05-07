import 'dart:convert';
import 'dart:io';

import 'package:bha_app_driver/common/constants/colors.dart';
import 'package:bha_app_driver/common/widgets/black_button.dart';
import 'package:bha_app_driver/order/model/orderStatusModel.dart';
import 'package:bha_app_driver/order/widget/order_detail_product_tile.dart';
import 'package:bha_app_driver/order/widget/order_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/widgets/appBar.dart';
import '../common/widgets/loading_indicator.dart';

class OrderDetail extends StatefulWidget {
  String orderid;
  List<String>sku=[];
  List<String>quqntity=[];
  String shopContact;
  String orderStatus;
  String orderStatusDate;
  String deliveryAddress;
  String customerContact;
  String shopName;
  String deliveryTime;
  String orderTotal;
  String exeId;
  String shopAddress;

   OrderDetail({Key? key,required this.orderid,required this.sku,required this.quqntity,
     required this.shopContact,required this.orderStatus,required this.orderStatusDate,
     required this.deliveryAddress,required this.customerContact,required this.shopName,required this.deliveryTime,
   required this.orderTotal,required this.exeId,required this.shopAddress}) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  bool loaded=false;
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
    setState(() {
      loaded=true;
    });
  }


  File ? _image; // Used only if you need a single picture

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              color: Color(0xff2E3138),
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library,color: Colors.yellow,),
                      title: new Text('Photo Library',style: TextStyle(color: Colors.white),),
                      onTap: () {
                        Navigator.of(context).pop();
                        getImage(true);

                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera,color: Colors.yellow,),
                    title: new Text('Camera',style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                      getImage(false);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  Future getImage(bool gallery) async {
    showLoadingIndicator(context);

    ImagePicker picker = ImagePicker();
    PickedFile? pickedFile;
    // Let user select photo from gallery
    if(gallery) {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery,
          imageQuality: 50);
    }
    // Otherwise open camera to get new photo
    else{
      pickedFile = await picker.getImage(
          source: ImageSource.camera,
          imageQuality: 50);

    }

    setState(() {
      if (pickedFile != null) {
        //_images.add(File(pickedFile.path));
        setState(() {
          _image = File(pickedFile!.path);
          uploadFile(_image!);
        });
        // Use if you only need a single picture
      } else {

        print('No image selected.');
        Navigator.of(context).pop();
      }
    });
  }


  String returnURL='';
  uploadFile(File _image) async {
    /*  StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('sightings/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;*/
    await FirebaseStorage.instance
        .ref()
        .child('deliveryImage/${_image.path}').putFile(_image);
    print('File Uploaded');

    await FirebaseStorage.instance
        .ref()
        .child('deliveryImage/${_image.path}').getDownloadURL().then((fileURL) {
      setState(() {
        returnURL =  fileURL;
        if(satatusList[satatusList.length-2].status==false){
          satatusList[satatusList.length-2].image=returnURL;
        }
        if(satatusList[satatusList.length-2].status==true && satatusList[satatusList.length-1].status==false){
          satatusList[satatusList.length-1].image=returnURL;
        }

        Navigator.of(context).pop();
      });
    });

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
          [/*Padding(
            padding: const EdgeInsets.only(right:18.0),
            child: Row(
              children: [

                Image.asset('assets/home/search.png',
                  height: 24,color: Colors.black,),
              ],
            ),
          )*/],true),
      body: loaded?
      Container(
        height: screenHeight,
        width: screenWidth,

        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: screenWidth,
                      //height: screenHeight*0.065,
                      color: splashBlue.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05,vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Order ID : ',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black
                                ),) ,
                              Expanded(
                                child: Text(widget.orderid,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: splashBlue
                                  ),),
                              )
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Shop Name : ',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black
                                ),) ,
                              Expanded(
                                child: Text(widget.shopName,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: splashBlue
                                  ),),
                              )
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shop Address : ',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black
                                ),) ,
                              Expanded(
                                child: Text(widget.shopAddress,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: splashBlue
                                  ),),
                              )
                            ],
                          ),
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
                          ListView.builder(
                            itemCount: widget.sku.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return orderDetailProductListTile(screenWidth, screenHeight,widget.sku[index],widget.quqntity[index]);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.8)
                                ),),
                              Text('₹${widget.orderTotal}',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.8)
                                ),)
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Expected Delivery Time',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.8)
                                ),),
                              Text("${widget.deliveryTime.toString()}",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.8)
                                ),)
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Address',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.8)
                                ),),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text(widget.deliveryAddress,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.8)
                            ),textAlign: TextAlign.left,),
                          SizedBox(height: 30,),
                          Row(
                            children: [
                              Text('Contact',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.8)
                                ),)
                            ],
                          ),

                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text("Shop           ",style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                              ),),
                              InkWell(
                                onTap: (){
                                  launchUrl(Uri(
                                    scheme: 'tel',
                                    path: widget.shopContact,
                                  ));
                                },
                                child: Container(
                                  width: 56,
                                  height: 19.6,
                                  color: Color(0xff28B446).withOpacity(0.2),
                                  child: Center(
                                    child: Text('Call',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          color: Color(0xff28B446)
                                      ),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text("Customer  ",style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black
                              ),),
                              InkWell(
                                onTap: (){
                                  launchUrl(Uri(
                                    scheme: 'tel',
                                    path: widget.customerContact,
                                  ));
                                },
                                child: Container(
                                  width: 56,
                                  height: 19.6,
                                  color: Color(0xff28B446).withOpacity(0.2),
                                  child: Center(
                                    child: Text('Call',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          color: Color(0xff28B446)
                                      ),),
                                  ),
                                ),
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
                    ),
                  ],
                ),
              ),
            ),
            satatusList[satatusList.length-2].status==false?
            Column(
              children: [


                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.07,
                      vertical: screenHeight*0.01
                  ),
                  child: InkWell(
                    onTap: (){
                      _showPicker(context);
                    },
                    child: Container(
                      width: screenWidth,
                      height: screenHeight*0.05,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      child: Center(
                        child: Text(satatusList[satatusList.length-2].image.isEmpty?'Add Image':'Change Image',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black
                          ),),
                      ),
                    ),
                  )
                ),


                Padding(
                   padding: EdgeInsets.symmetric(
                     horizontal: screenWidth*0.07,
                     vertical: screenHeight*0.01
                   ),
                  child: blackButton("Accept Order", (){
                    if(satatusList[satatusList.length-2].image.isEmpty){
                      Fluttertoast.showToast(msg: 'Add Image to Continue');
                    }else{
                      showCancelDialog(context);
                    }

                  }, screenWidth, screenHeight*0.05),
                ),
              ],
            ):SizedBox.shrink(),
            satatusList[satatusList.length-2].status==true && satatusList[satatusList.length-1].status==false?
            Column(
              children: [


                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.07,
                        vertical: screenHeight*0.01
                    ),
                    child: InkWell(
                      onTap: (){
                        _showPicker(context);
                      },
                      child: Container(
                        width: screenWidth,
                        height: screenHeight*0.05,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        child: Center(
                          child: Text(satatusList[satatusList.length-1].image.isEmpty?'Add Image':'Change Image',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black
                            ),),
                        ),
                      ),
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.07,
                      vertical: screenHeight*0.01
                  ),
                  child: blackButton("Make Order Delivered", (){
                    if(satatusList[satatusList.length-1].image.isEmpty){
                      Fluttertoast.showToast(msg: 'Add Image to Continue');
                    }else{
                      showDeliveredDialog(context);
                    }

                  }, screenWidth, screenHeight*0.05),
                ),
              ],
            ):SizedBox.shrink()

          ],
        ),
      ):Center(child: Text("Loading..."),),
    );
  }
  acceptOrder()async{
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderid).set({
      'status':'${satatusList[satatusList.length-2].name}',
      'deliveringBy':widget.exeId
    },
      SetOptions(merge: true),
    ).then((value) async{
      for(var i=0;i<satatusList.length;i++){
        if(i != satatusList.length-1){
          setState(() {
            satatusList[i].status=true;
          });
        }
        if(i == satatusList.length-2){
          setState(() {
            satatusList[i].date=DateTime.now().toString();
            satatusList[i].image=returnURL;
          });
        }
      }
      String encoded = jsonEncode(satatusList);
      print(encoded);
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderid).set({
        'DeliveryStatus':encoded
      },SetOptions(merge: true),).then((value) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'Order accepted successfully');
      });

    });
  }
  showCancelDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {

        Navigator.of(context).pop();
        acceptOrder();

      },
    );
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {

        Navigator.of(context).pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      title: Text("Are you sure,you want to accept this order?"),

      actions: [
        cancelButton,
        okButton
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  showDeliveredDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {

        Navigator.of(context).pop();
        deliveredOrder();

      },
    );
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {

        Navigator.of(context).pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      title: Text("Are you sure,you delivered this order?"),

      actions: [
        cancelButton,
        okButton
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  deliveredOrder()async{
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderid).set({
      'status':'${satatusList[satatusList.length-1].name}'
    },
      SetOptions(merge: true),
    ).then((value) async{
      for(var i=0;i<satatusList.length;i++){

          setState(() {
            satatusList[i].status=true;
          });

        if(i == satatusList.length-1){
          setState(() {
            satatusList[i].date=DateTime.now().toString();
            satatusList[i].image=returnURL;
          });
        }
      }
      String encoded = jsonEncode(satatusList);
      print(encoded);
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderid).set({
        'DeliveryStatus':encoded
      },SetOptions(merge: true),).then((value) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'Order completed successfully');
      });

    });
  }
}
