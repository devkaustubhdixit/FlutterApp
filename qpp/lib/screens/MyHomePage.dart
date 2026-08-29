import 'package:flutter/material.dart';
import 'package:qpp/screens/reminder.dart';
import 'package:qpp/screens/playgames.dart';
import 'package:qpp/screens/Listen_Music.dart';
import 'package:qpp/screens/call_doctor.dart';


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
            child: ElevatedButton(onPressed:() => { Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const reminder()))}, child:Row(children: [Image.asset('assets/images/a.jpg'),Text("Reminders",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold))])),
          height: 150.0,
          width: 500.0,),
              
              SizedBox(
                child: ElevatedButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const playgames()))} , child:Row(children: [Image.asset('assets/images/b.jpg')  ,Text("Play Games",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold),)] )),height: 150.0,
          width: 500.0,
              ),
              SizedBox(
                child: ElevatedButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const ListenMusic()))}, child:Row(children: [Image.asset('assets/images/c.jpg')  ,Text("Listen Music",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold))])),height: 150.0,
          width: 500.0,
              ),
              SizedBox(
                child: ElevatedButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const CallDoctor()))}, child:Row(children: [Image.asset('assets/images/d.jpg')  ,Text("Call Docs",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold))])),height: 150.0,
          width: 500.0,
              )
              
              
          ]
        )
      ),
      
    );
    
    
  }
}