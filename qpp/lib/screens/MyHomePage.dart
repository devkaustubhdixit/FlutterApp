import 'package:flutter/material.dart';

import 'package:qpp/screens/reminder.dart';

import 'package:qpp/screens/playgames.dart';

import 'package:qpp/screens/Listen_Music.dart';

import 'package:qpp/screens/call_doctor.dart';

import 'package:qpp/screens/chatbot.dart';

import 'package:qpp/screens/data/local/db_helper.dart';

import 'package:qpp/screens/LOGINPAGE.dart';



class HomePage extends StatelessWidget {

  const HomePage( {super.key});

 






    // First check authentication status

    



 Future< String> name()async{
  DBhelper dbh=DBhelper.getInstance();


   String Username=await dbh.getname() ;
   return Username;
}


      // Re-verify login status (reassigning existing 'vh', not declaring 'bool vh')

     



  @override

  Widget build(BuildContext context) {

    // Schedule gotopage to run after initial frame render

   


    final double screenWidth = MediaQuery.of(context).size.width;

    final double screenHeight = MediaQuery.of(context).size.height;



    // Dynamic size for button content to maintain proportions

    final double buttonHeight = screenHeight * 0.13;

    final double buttonWidth = screenWidth * 0.85;

    final double avatarRadius = buttonHeight * 0.35;



    return Scaffold(

      appBar: AppBar(

        title: FutureBuilder<String>(
          future: name(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Welcome...',
                style: TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            
            final username = snapshot.data ?? '';
            return Text(
              'Welcome $username',
              style: const TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
              ),

        );

    }  ),)

      ,body: Center(

        child: SingleChildScrollView(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // 1. Reminders

              SizedBox(

                height: buttonHeight,

                width: buttonWidth,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) => const NotificationBanners(),

                      ),

                    );

                  },

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Expanded(

                        child: FittedBox(

                          fit: BoxFit.scaleDown,

                          alignment: Alignment.centerLeft,

                          child: const Text(

                            "Reminders",

                            style: TextStyle(

                              fontSize: 24.0,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ),

                      ),

                      CircleAvatar(

                        radius: avatarRadius,

                        backgroundImage:

                            const AssetImage('assets/images/a.jpg'),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 15.0),



              // 2. Play Games

              SizedBox(

                height: buttonHeight,

                width: buttonWidth,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) => const GameScreen(),

                      ),

                    );

                  },

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      CircleAvatar(

                        radius: avatarRadius,

                        backgroundImage:

                            const AssetImage('assets/images/b.jpg'),

                      ),

                      Expanded(

                        child: FittedBox(

                          fit: BoxFit.scaleDown,

                          alignment: Alignment.centerRight,

                          child: const Text(

                            "Play Games",

                            style: TextStyle(

                              fontSize: 24.0,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 15.0),



              // 3. Listen Music

              SizedBox(

                height: buttonHeight,

                width: buttonWidth,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) => LocalAudioPlayer(

                          source:

                              LocalAudioSource.asset('audio/dope_shope.mp3'),

                        ),

                      ),

                    );

                  },

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Expanded(

                        child: FittedBox(

                          fit: BoxFit.scaleDown,

                          alignment: Alignment.centerLeft,

                          child: const Text(

                            "Listen Music",

                            style: TextStyle(

                              fontSize: 24.0,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ),

                      ),

                      CircleAvatar(

                        radius: avatarRadius,

                        backgroundImage:

                            const AssetImage('assets/images/c.jpg'),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 15.0),



              // 4. Call CareTaker

              SizedBox(

                height: buttonHeight,

                width: buttonWidth,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) => const CallDoctor(),

                      ),

                    );

                  },

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      CircleAvatar(

                        radius: avatarRadius,

                        backgroundImage:

                            const AssetImage('assets/images/d.jpg'),

                      ),

                      Expanded(

                        child: FittedBox(

                          fit: BoxFit.scaleDown,

                          alignment: Alignment.centerRight,

                          child: const Text(

                            "Call CareTaker",

                            style: TextStyle(

                              fontSize: 24.0,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 15.0),



              // 5. Talk to AI Sahayak

              SizedBox(

                width: buttonWidth,

                height: buttonHeight * 0.7,

                child: FloatingActionButton.extended(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) => const AiAssistantPage(),

                      ),

                    );

                  },

                  label: const Text(

                    "Talk to AI Sahayak",

                    style: TextStyle(

                        fontSize: 18.0, fontWeight: FontWeight.bold),

                  ),

                  icon: const Icon(Icons.chat),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

} 

