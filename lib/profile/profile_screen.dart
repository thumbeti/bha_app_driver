import 'package:bha_app_driver/login/view/login_screen.dart';
import 'package:bha_app_driver/profile/model/profileModel.dart';
import 'package:bha_app_driver/profile/widget/profile_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../common/constants/colors.dart';
import '../common/widgets/appBar.dart';
import '../common/widgets/loading_indicator.dart';
import '../dashboard/dash_board_screen.dart';
import 'editProfile.dart';
final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel ? profileModel;

  bool loaded=false;
  getProfileDetails()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String ? uid= preferences.getString('uid');
   await FirebaseFirestore.instance
        .collection('executives')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          profileModel = ProfileModel(
          name: documentSnapshot['name'],
              email: documentSnapshot['email'], phone: documentSnapshot['mobile'],
         address: documentSnapshot['address'],
          zipcodes: List.from(documentSnapshot['activeAreas']));
        });
      } else {
        print('Document does not exist on the database');
      }
    });
   setState(() {
     loaded=true;
   });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileDetails();
  }
  @override
  Widget build(BuildContext context) {
    var screenHeight=MediaQuery.of(context).size.height;
    var screenWidth=MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar("My Profile",
            [],false),
        body:loaded? Container(
          height: screenHeight,
          width: screenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth*0.08
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight*0.02,),
                Container(
                  height: 88,
                    width: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black
                  ),
                  child: Center(
                    child: Icon(Icons.person,color: Colors.white,size: 30,),
                  ),
                ),
                SizedBox(height: screenHeight*0.02,),
                Text(profileModel!.name,style:
                  GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xff030303)
                  ),),
                SizedBox(height: screenHeight*0.01,),
                Text(profileModel!.email,style:
                GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xff030303)
                ),),
                SizedBox(height: screenHeight*0.03,),
                SizedBox(height: screenHeight*0.02,),

                profileTile(
                    'Active Areas',
                        (){
                          if(loaded && profileModel != null){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfileScreen(
                              zippList: profileModel!.zipcodes,
                            ))).then((value) {
                              setState(() {
                                getProfileDetails();
                              });
                            });
                          }
                    }
                ),
                SizedBox(height: screenHeight*0.01,),
                profileTile(
                    'Notifications',
                        (){
                    }
                ),
                SizedBox(height: screenHeight*0.01,),
                profileTile(
                    'Logout',
                        (){
                          showLogoutDialog(context);
                    }
                ),
              ],
            ),
          ),
        ):
            Center(child: Text('Loading..'),)
    );
  }

  showLogoutDialog(BuildContext context) {

    Widget cancelButton = TextButton(
      child:const Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child:const Text("Continue"),
      onPressed:  () {
        Navigator.of(context).pop();
        _signOut(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title:const Text("Are you sure you want to logout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isphone=preferences.getBool('isPhone')??false;
    if(isphone){
      await FirebaseAuth.instance.signOut();
    }else{
      await _googleSignIn.signOut();
    }
    preferences.remove('isLoggedIn');
    pageIndex = 0;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:
        (context)=>LoginScreen()), (route) => false);
  }
  Future<void> _getCurrentPosition() async {
    showLocationLoadingIndicator(context);
    var hasPermission = await _handlePermission().then((value) {
      print("ERRRRRR  $value");
      if(value==false){
        Navigator.of(context, rootNavigator: true).pop();
        infoDialog(context);
      }
      return value;
    });
    print(hasPermission);
    if (hasPermission==false) {

      return;
    }

    try{
      final position = await _geolocatorPlatform.getCurrentPosition();

        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude,position.longitude);
        Navigator.of(context, rootNavigator: true).pop();
        updateCurrentPosition(position.latitude.toString(),position.longitude.toString(),"${placemarks[0].postalCode}");

    }catch(e){
      Navigator.of(context, rootNavigator: true).pop();
      infoDialog(context);
    }
  }
  Future<bool> _handlePermission() async {

    late LocationPermission permission;

    await _geolocatorPlatform.checkPermission().then((value) {
      print("PEERRRRRR $value");
      setState(() {
        permission =value;
      });
    });
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {

        return false;
      }

    }

    if (permission == LocationPermission.deniedForever) {

      return false;
    }

    return true;
  }
  void showLocationLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      backgroundColor: Colors.white,
                      title: Text("Fetching Your location info.......",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14
                        ),),
                      content: SpinKitWave(color: Colors.black)
                  ),
                ],
              ),
            )
        );
      },
    );
  }
  infoDialog(BuildContext context) {

    AlertDialog alert = AlertDialog(
      title:Text("The location service on the device is disabled",
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18
        ),),
      actions: [
        TextButton(
          child: Text("Cancel",style: TextStyle(color: Colors.blue),),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();

          },
        ),
        TextButton(
          child: Text("Enable",style: TextStyle(color: Colors.red),),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            _getCurrentPosition();

          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  updateCurrentPosition(String lat,String long,String pin)async{
    print("LLLL $lat,$long");
    showLoadingIndicator(context);
    CollectionReference users = await FirebaseFirestore.instance.collection('executives');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String uid=preferences.getString('uid')??'';
      return users
              .doc(uid)
              .update({
            'latitude': lat,
            'longitude': long,
        'pin':pin
          },
          ).then((value) {
            Navigator.of(context).pop();
            Fluttertoast.showToast(msg: 'location updated successfully');
          });

  }

}
