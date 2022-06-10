
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'dart:io';

import 'Home.dart';
import 'Login.dart';

final users = {'ahmed@gmail.com': '12345'};

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return '';
    });
  }

  Future<String> _onSubmitUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      users[data.name] = data.password;
      return '';
    });
  }

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
      logo: 'assets/images/SimpySwap-03-(White Version).png',
      onLogin: _authUser,
     // onSignup: _onSubmitUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Home(),
        ));
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