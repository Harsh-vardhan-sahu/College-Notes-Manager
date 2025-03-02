import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppStyle {
  static const Color mainColor = Color(0xFF000028);// Primary color
  static const Color secondaryColor = Color(0xFF000633); // Another shade
  static const Color accentColor = Color(0xFF0065FF);

  static List<Color> cardsColor=[
    Colors.white,
    Colors.red.shade300,
    Colors.orange.shade200,
    Colors.yellow.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.blueGrey.shade200,
  ];
  static TextStyle mainTitle= GoogleFonts.roboto(fontSize:18.0,fontWeight
          :FontWeight.bold);
  static TextStyle mainContent= GoogleFonts.roboto(fontSize:16.0,fontWeight
      :FontWeight.normal);
  static TextStyle dateTitle= GoogleFonts.roboto(fontSize:13.0,fontWeight
      :FontWeight.w500);


}
