import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
class Home extends StatelessWidget {
   Home({super.key});
  final textcontroller=TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Center(
            child: SizedBox(child: TextField(controller:textcontroller),width: 120.0,height: 60.0,)
            ,
          ),ElevatedButton(onPressed: (){print(textcontroller.text);}, child: Text("add"))
        ],
      ),
      
    );
  }
}