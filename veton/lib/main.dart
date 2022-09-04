import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veton/Home.dart';
import 'Login.dart';
import 'Model/LoacleCallModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(LocalStorageCallsAdapter());
  await Hive.openBox<LocalStorageCalls>('CallsHistory');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn=false;
  String? name,id,pic,code,role,number;
  @override
  void initState() {
    isUserLoggedIn().then((value) => {
      isLoggedIn=value
    });
    super.initState();
  }

  Future<bool> isUserLoggedIn()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
bool value = pref.getBool('isLoggedIn')??false;
   name= pref.getString('username')??'empty';
    id= pref.getString('id')??'empty';
    pic= pref.getString('pic')??'empty';
    role= pref.getString('role')??'empty';
    code= pref.getString('crmCode')??'empty';
    number= pref.getString('phone')??'empty';



    return value;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:isLoggedIn?Home(id!, name!, pic!,role!,code!,number!): LoginScreen(),
    );
  }
}
