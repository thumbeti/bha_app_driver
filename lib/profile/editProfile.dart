import 'dart:io';

import 'package:bha_app_driver/common/widgets/appBar.dart';
import 'package:bha_app_driver/common/widgets/black_button.dart';
import 'package:bha_app_driver/register/services/registerService.dart';
import 'package:bha_app_driver/register/view/widget/country_picker.dart';
import 'package:bha_app_driver/register/view/widget/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../login/view/login_screen.dart';
import '../common/widgets/loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  List<String> zippList;
   EditProfileScreen({Key? key,required this.zippList}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
TextEditingController newCodeController=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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


  String  ? returnURL;
  uploadFile(File _image) async {
    /*  StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('sightings/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;*/
    await FirebaseStorage.instance
        .ref()
        .child('driverImage/${_image.path}').putFile(_image);
    print('File Uploaded');

    await FirebaseStorage.instance
        .ref()
        .child('driverImage/${_image.path}').getDownloadURL().then((fileURL) {
      setState(() {
        returnURL =  fileURL;
        Navigator.of(context).pop();
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    var screenHeight=MediaQuery.of(context).size.height;
    var screenWidth=MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar('Active Areas', [InkWell(
        onTap: (){
          newCodeController.clear();
          showAlertDialog(context,screenHeight,screenWidth);
        },
        child: Padding(
          padding: const EdgeInsets.only(right:18.0),
          child: Icon(Icons.add),
        ),
      )],true),
      body:
      Container(
        height: screenHeight,
        width: screenWidth,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth*0.1,
            vertical: screenHeight*0.04
        ),
        child: SingleChildScrollView(
          child: Column(

            children: [
              ListView.builder(
                padding: EdgeInsets.zero,
                  itemCount: widget.zippList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,i){
                return ListTile(
                  onTap: (){},
                  contentPadding: EdgeInsets.all(0),
                  title: Text(widget.zippList[i],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 14
                    ),),
                  trailing: InkWell(
                    onTap: (){
                     setState(() {
                       widget.zippList.remove(widget.zippList[i]);
                     });
                    },
                    child: Icon(Icons.delete,color: Colors.black,
                      size: 15,),
                  ),
                  shape: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.1))
                  ),
                );
              }),
              SizedBox(height: screenHeight*0.15,),
              blackButton('Save Changes', (){

                  updateProfile();

              }, screenWidth, screenHeight*0.05
              )

            ],
          ),
        ),
      )
    );
  }

showAlertDialog(BuildContext context,var screenHeight,var screenWidth) {


  // set up the AlertDialog
  AlertDialog alert = AlertDialog(

    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: newCodeController,
          keyboardType: TextInputType.number,
          onChanged:(value){} ,
          readOnly: false,
          maxLength: 6,
          enabled: true,
          decoration: InputDecoration(
              counterText: '',
              label:Text('Enter New Code') ,
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                //color: label_blue
              )
          ),
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black
          ),
        ),
        SizedBox(height: screenHeight*0.055,),
        blackButton('Add New', (){
          if(newCodeController.text.isEmpty){
            Fluttertoast.showToast(msg: 'enter code');
          }else if(widget.zippList.contains(newCodeController.text)){
            Fluttertoast.showToast(msg: 'already added');
          }else{
            setState(() {
              widget.zippList.add(newCodeController.text);
            });
            Navigator.of(context).pop();
          }




        }, screenWidth, screenHeight*0.05
        )
      ],
    ),

  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}





  updateProfile()async{
    showLoadingIndicator(context);
    CollectionReference users = await FirebaseFirestore.instance.collection('executives');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String uid=preferences.getString('uid')??'';
    if(returnURL==null){
      setState(() {
       // returnURL=widget.image;
      });
    }
    return users
        .doc(uid)
        .update({
      'activeAreas': widget.zippList,


    },
    ).then((value) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: 'active areas updated successfully');
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        Navigator.of(context).pop();
      });
    });
  }
}
