import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

InkWell blackButton(String text,VoidCallback onTap,double width,double height){
  return InkWell(
    onTap: onTap,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(4))
      ),
      child: Center(
        child: Text(text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white
        ),),
      ),
    ),
  );
}
/* MD5:  DD:01:71:BE:E9:B9:7D:C4:D3:04:82:FC:8E:A8:30:92
         SHA1: 8A:67:76:AD:04:E1:0C:B6:8D:DE:36:D6:A1:E0:7A:B7:B0:87:1F:B0
         SHA256: 10:4E:13:F4:A6:4D:46:41:3A:3C:57:9A:03:EC:3A:F6:26:E1:09:9C:5E:28:53:DB:E2:78:31:B5:53:B0:D5:8E
         Signature algorithm name: SHA256withRSA
         Version: 3
*/