import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'Home.dart';
import 'Login.dart';
import 'package:http/http.dart' as http;

final users = {'ss@ss.com': '12345'};

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 1050);
  String? userID;
  String? employeeName,profilePicture;
  bool isLoginSuccess = false;
  String loginMessage = '';

  Future<String> _authUser(LoginData data) async {
    var baseUrl = 'http://44.203.240.206:5000/user/signin';
    var url = Uri.parse(baseUrl);
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(url,
        body: json.encode(
          {
            "email": data.name,
            "password": data.password,
          },
        ),
        headers: {"content-type": "application/json"});

    final Map<String, dynamic> productData = jsonDecode(response.body);

    print(productData);
    if (productData['message'] == 'User Not Registered') {
      loginMessage = productData['message'];
    } else if (productData['data'] != null) {
       userID='${productData['data']['_id']}'.toString();
       employeeName= '${productData['data']['first_name']} ${productData['data']['last_name']}'.toString();
       profilePicture=productData['data']['profilePicture'];
      print('=============>>>>>>>>>$userID');
      print('=============>>>>>>>>>$employeeName');

      userID.toString();
      employeeName.toString();
      isLoginSuccess = true;
       pref.setBool('isLoggedIn', true);
       pref.setString('username', employeeName??'empty');
       pref.setString('id', userID??"empty");
       pref.setString('profilePicture', profilePicture??'empty');


    } else {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool('isLoggedIn', false);

      loginMessage = productData['message'];
      pref.setBool('isLoggedIn', false);

    }
    return Future.delayed(loginTime).then((_) {
      if (!isLoginSuccess) {
        return loginMessage;
      }
      return '';
    });
  }

  // Future<String> _onSubmitUser(LoginData data) {
  //   print('Name: ${data.name}, Password: ${data.password}');
  //   return Future.delayed(loginTime).then((_) {
  //     users[data.name] = data.password;
  //     return '';
  //   });
  // }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      logo: 'assets/betoonlogo.png',
      onLogin: _authUser,
      onSubmitAnimationCompleted: () {
        print(userID);

        print(employeeName);

        Future.delayed(Duration(seconds: 0),(){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Home(userID!,employeeName!,profilePicture!),
          ));
        });

      },
      onRecoverPassword: _recoverPassword,
      //     loginProviders: <LoginProvider>[
      //     Platform.isAndroid
      //     ? LoginProvider(
      // icon: FontAwesomeIcons.google,
      // callback: () async {
      //   print('start google sign in');
      //   await Future.delayed(loginTime);
      //   print('stop google sign in');
      //   return null;
      // },
      // )
      //     : LoginProvider(
      // icon: FontAwesomeIcons.apple,
      // callback: () async {
      // print('start google sign in');
      // await Future.delayed(loginTime);
      // print('stop google sign in');
      // return null;
      // },
      // ),
      // LoginProvider(
      // icon: FontAwesomeIcons.facebookF,
      // callback: () async {
      // print('start facebook sign in');
      // await Future.delayed(loginTime);
      // print('stop facebook sign in');
      // return null;
      // },
      // ),
      // ]);
    );
  }
}
