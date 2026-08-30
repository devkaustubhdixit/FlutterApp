import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallDoctor extends StatelessWidget {
  const CallDoctor({super.key});
  Future<void> CallDoctorScreen(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch dialer for $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    const String doctorNumber = "+1234567890";
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: ElevatedButton(onPressed: ()=> CallDoctorScreen(doctorNumber),
          
                child: Text("call")),
        height: 150,
        width: 300,),
      ),
    );
  }
}