

import 'package:flutter/material.dart';
import 'package:qpp/screens/data/local/db_helper.dart';

class db_check extends StatefulWidget {


  const db_check({super.key});

  @override
  State<db_check> createState() => _MyWidgetState();

}
Future<bool> add_to_db(myid,D,b)async{
DBhelper dBhelper=DBhelper.getInstance();
return await dBhelper.add_entry(myid: myid, D: D, b: b);


}




 



class _MyWidgetState extends State<db_check> {
  TextEditingController textcontroller_id = TextEditingController();
  TextEditingController textcontroller_D = TextEditingController();
  TextEditingController textcontroller_B = TextEditingController();

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textcontroller_id,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ID'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: textcontroller_D,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: textcontroller_B,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'B'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async{
              // Extract text cleanly using .text instead of casting .value
              int myid = int.parse(textcontroller_id.text);
              String D = textcontroller_D.text;
              int B = int.parse(textcontroller_B.text);

              if  (await add_to_db(myid, D, B)==true){
                textcontroller_B.clear();
                textcontroller_D.clear();
                textcontroller_id.clear();


              }
              

            },
            child: const Text("Submit"),
          ),
        ],
      ),
    ),
  );
}}