import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qpp/screens/reminder.dart';
import 'package:qpp/screens/playgames.dart';
import 'package:qpp/screens/Listen_Music.dart';
import 'package:qpp/screens/call_doctor.dart';
import 'package:qpp/screens/chatbot.dart';




class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
      appBar: AppBar(title: Text("Welcome ",style: TextStyle(
    
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
  ),))
      
      ,
      body: Center(
        child:Column(spacing: 15,
          children: [SizedBox(
            height: 150.0.h,
          width: 500.0.w,
            child: ElevatedButton(onPressed:() => { Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationBanners()))}, child:Row(spacing:25.0.w ,children: [Text("Reminders",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold)),const CircleAvatar(
  radius: 70.0,
  backgroundImage: AssetImage('assets/images/a.jpg'),
)])),),
              
              SizedBox(
                height: 140.0.h,
          width: 500.0.w,
                child: ElevatedButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const GameScreen()))} , child:Row(spacing: 20.0.w ,children: [const CircleAvatar(
  radius: 70.0,
  backgroundImage: AssetImage('assets/images/b.jpg'),
) ,Text("Play Games",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold),)] )),
              ),
              SizedBox(
                height: 140.0.h,
          width: 500.0.w,
                child: ElevatedButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => LocalAudioPlayer(source: LocalAudioSource.asset('audio/dope_shope.mp3'),)))}, child:Row(children: [Text("Listen Music",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold)),const CircleAvatar(
  radius: 70.0,
  backgroundImage: AssetImage('assets/images/c.jpg'),
)])),
              ),
              SizedBox(
                height: 140.0.h,
          width: 500.0.w,
                child: ElevatedButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const CallDoctor()))}, child:Row(children: [const CircleAvatar(
  radius: 70.0,
  backgroundImage: AssetImage('assets/images/d.jpg'),
)  ,Text("Call CareTaker",style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold))])),
              )
          ,SizedBox(child:FloatingActionButton(onPressed: () => {Navigator.push(
                context,MaterialPageRoute(builder: (context) => const AIchatbot()))},child: Text("Talk to AI Sahayak"),),width:250.w)]
        )
      ),
      
    );
    
    
  }
}
