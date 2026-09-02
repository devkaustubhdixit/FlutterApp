import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qpp/screens/LOGINPAGE.dart';
import 'package:qpp/screens/MyHomePage.dart';
import 'package:qpp/screens/data/local/db_helper.dart';

// 1. main() MUST be defined outside the MyApp class at root level
DBhelper dbh= DBhelper.getInstance();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  


DBhelper dbh= DBhelper.getInstance();
final bool isLogin= await dbh.loginauth();
runApp(MyApp(isLogin:isLogin));

}
class MyApp extends StatelessWidget {
  final bool isLogin;
  const MyApp( {super.key, required  this.isLogin});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 2. Set your target standard design frame size (width, height) in logical pixels
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return  MaterialApp(
          debugShowCheckedModeBanner: false,
          home: isLogin ? HomePage():Loginpage(),
        );
      },
    );
  }
}