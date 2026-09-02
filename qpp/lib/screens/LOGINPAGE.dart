import 'package:flutter/material.dart';
import 'package:qpp/screens/MyHomePage.dart';
import 'package:qpp/screens/data/local/db_helper.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  // MUST be declared here outside build() so they persist across rebuilds
  late final TextEditingController textDocId;
  late final TextEditingController textUserName;
  late final FocusNode focusUserName;
  late final FocusNode focusDocId;
  late final DBhelper dBhelper;

  @override
  void initState() {
    super.initState();
    textDocId = TextEditingController();
    textUserName = TextEditingController();
    focusUserName = FocusNode();
    focusDocId = FocusNode();
    dBhelper = DBhelper.getInstance();
  }

  @override
  void dispose() {
    textDocId.dispose();
    textUserName.dispose();
    focusUserName.dispose();
    focusDocId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevents the Scaffold from forcing a rebuild layout cycle on tap
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: const Text("Patient login"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please Login the customer using your assigned doctor id",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Use explicit Key and FocusNode
              TextField(
                key: const ValueKey('username_field'),
                controller: textUserName,
                focusNode: focusUserName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                key: const ValueKey('doc_id_field'),
                controller: textDocId,
                focusNode: focusDocId,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: "Doctor ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();

                  final String username = textUserName.text.trim();
                  final String docIdStr = textDocId.text.trim();

                  final int? docId = int.tryParse(docIdStr);
                  if (username.isEmpty || docId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid username and doctor ID"),
                      ),
                    );
                    return;
                  }

                  bool isSuccess = await dBhelper.add_user_entry(
                    D: username,
                    b: docId,
                  );

                  if (isSuccess && mounted) {
                    String _username=username;
                    textUserName.clear();
                    textDocId.clear();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  HomePage(),
                      ),
                    );
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}