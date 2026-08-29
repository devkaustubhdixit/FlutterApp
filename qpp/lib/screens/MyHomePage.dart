import 'package:flutter/material.dart';
import 'package:qpp/screens/reminder.dart';
import 'package:qpp/screens/playgames.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("Welcome "))
      
      ,
      body: Center(
        child:Column(
          children: [SizedBox(
            child: FilledButton(onPressed:() => {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const reminder()))}, child:Text("Reminders")),
          height: 150.0,
          width: 500.0,),
              
              SizedBox(
                child: FilledButton(onPressed:() => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const playgames()))}, child:Text("Play Games")),height: 150.0,
          width: 500.0,
              )
          ]
        )
      ),
      
    );
    
    
  }
}