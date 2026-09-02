import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBhelper {
  DBhelper._(); // Private constructor

  static final DBhelper _instance = DBhelper._();

  static DBhelper getInstance() {
    return _instance;
  }

  Database? _myDB;

  static const String t_name = "abc";
  static const String q_id = "id";
  static const String q_name = "name";
  static const String q_value = "value";

  static const String userlogintable_name = "Firstlogintable";
  static const String user_id = "user_id";
  static const String User_name = "Username";
  static const String doctor_id_value = "doctor_id";

  Future<Database> getDB() async {
    if (_myDB != null) {
      return _myDB!;
    } else {
      _myDB = await openDB();
      return _myDB!;
    }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, "mydata.db");

    return await openDatabase(
      dbpath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $t_name ($q_id INTEGER PRIMARY KEY, $q_name TEXT, $q_value INTEGER)",
        );
        // Fixed space: PRIMARY KEY AUTOINCREMENT
        await db.execute(
          "CREATE TABLE $userlogintable_name ($user_id INTEGER PRIMARY KEY AUTOINCREMENT, $User_name TEXT, $doctor_id_value INTEGER)",
        );
      },
    );
  }

  Future<bool> add_entry({
    required int myid,
    required String D,
    required int b,
  }) async {
    var db = await getDB();
    int row_affected = await db.insert(t_name, {
      q_id: myid,
      q_name: D,
      q_value: b,
    });
    return row_affected > 0;
  }

  Future<bool> add_user_entry({
    required String D,
    required int b,
  }) async {
    var db = await getDB();
    int row_affected = await db.insert(userlogintable_name, {
      User_name: D,
      doctor_id_value: b,
    });
    return row_affected > 0;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(t_name);
    return mData;
  }

  Future<bool> loginauth() async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT COUNT(*) FROM $userlogintable_name",
      );
      int count = Sqflite.firstIntValue(result) ?? 0;
      return count >= 1;
    } catch (e) {
      print("Database Error during loginauth: $e");
      return false;
    }
  }
  Future<String> getname()async{
     var db = await getDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT ${User_name} FROM $userlogintable_name "
      );
      return result[0]["Username"];
  }
}