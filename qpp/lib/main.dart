import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:qpp/screens/MyHomePage.dart';
import 'package:qpp/model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  

  @override
  Widget build(BuildContext context) {
  final double screenWidth = MediaQuery.of(context as BuildContext).size.width;
  final double screenHeight = MediaQuery.of(context as BuildContext).size.height; 
    return  ScreenUtilInit(
      designSize:  Size(screenWidth, screenHeight), // Target base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const HomePage());}
      
    );

  }
}