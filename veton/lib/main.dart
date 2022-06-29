import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'CallData.dart';
import 'Login.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CallData()),
        ],
        child: const MyApp(),
      ),

      );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:  LoginScreen(),
    );
  }
}

