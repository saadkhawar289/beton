


import 'dart:convert';

import 'package:hive/hive.dart';

part 'LoacleCallModel.g.dart';

@HiveType(typeId: 0)
class LocalStorageCalls extends HiveObject{
@HiveField(0)
  late String totalLength;
@HiveField(1)
  late bool isVerified;
@HiveField(2)
  late String employeeId;
@HiveField(3)
late String clientId;
LocalStorageCalls();

// @override
// String toString() {
//   return jsonEncode({
//     'duration': totalLength,
//     'verified': isVerified,
//     'from': employeeId,
//     'to': clientId,
//   });
// }


 LocalStorageCalls.fromJson(Map<String, dynamic> json) {
  totalLength = json['totalLength'];
  isVerified = json['isVerified'];
  employeeId = json['from'];
  clientId = json['to'];

}
// @HiveField(5)
// Map<String, dynamic> toJson() {
//   final data = <String, dynamic>{};
//   data['totalLength'] = totalLength;
//   data['isVerified'] = isVerified;
//   data['employeeId'] = employeeId;
//   data['clientId'] = clientId;
//
//   return data;
// }
}

