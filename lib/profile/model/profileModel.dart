// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  ProfileModel({

    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.zipcodes,

  });

  String name;
  String email;
  String phone;
  String address;
  List<String> zipcodes;


  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(

    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    zipcodes: json["zipcodes"],

  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "zipcodes": zipcodes,
  };
}
