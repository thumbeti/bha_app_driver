import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/widgets/loading_indicator.dart';
import '../../dashboard/dash_board_screen.dart';

class RegisterService{
  CollectionReference users = FirebaseFirestore.instance.collection('executives');

  Future<void> addUser(String name,String email,String phone,String country,String address,BuildContext context,String lattitude,String longitude,String pincode) async{
    showLoadingIndicator(context);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String uid=preferences.getString('uid')??'';
    String img=preferences.getString('img')??'';
    return users
    // existing document in 'users' collection: "ABC123"
        .doc(uid)
        .set({
      'driver_id':uid,
      'active':true,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'image': img,
      'address':'$address',
      'pin':pincode,
      'latitude': lattitude,
      'longitude': longitude
    },
      SetOptions(merge: true),
    )
        .then(
            (value){
              print("data merged with existing data!");
              Navigator.of(context).pop();
              setAsLoggedIn(true);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>DashBoardScreen()), (route) => false);
              Fluttertoast.showToast(msg: 'Registered successfully');
            }
    )
        .catchError((error) {
      print("Failed to merge data: $error");
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: 'Register failed, try again');
    });
  }

  Future<String> checkIfUserExists(String mobile) async {
    String result='';
    try {
      await users.get().then((value) {
        value.docs.forEach((element) {
          if(element['mobile']==mobile){

           result =element.id.toString();
          }
        });
      });
      return result;
    } catch (e) {
      return result;
    }
  }


  Future<bool> checkIfUserActive(String docId) async {
    try {
      var doc = await users.doc(docId).get();
      return doc['active'];
    } catch (e) {
      return false;
    }
  }
  setAsLoggedIn(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', status);
  }
}