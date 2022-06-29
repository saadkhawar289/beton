import 'package:flutter/material.dart';


class CallData extends ChangeNotifier{
List<CallModel> localeCalls= [];

int get listLength{
  print(localeCalls.length);
  notifyListeners();
  return localeCalls.length;
}void addCall(CallModel callModel){
  localeCalls.add(callModel);
  print('done');
  notifyListeners();
}

  void removeCall(CallModel callModel){
    localeCalls.remove(callModel);

  }


}


class CallModel {
  String callLength;
  bool callVerified;
  String toClientId;
  String callStartAt;
  String callEndAt;

  CallModel(this.callEndAt,this.callLength,this.callStartAt,this.callVerified,this.toClientId);

}