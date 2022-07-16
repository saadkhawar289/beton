


import 'package:hive/hive.dart';

part 'LoacleCallModel.g.dart';

@HiveType(typeId: 0)
class LocalStorageCalls extends HiveObject{
@HiveField(0)
  late int totalLength;
@HiveField(1)
  late bool isVerified;
@HiveField(2)
  late String clientId;




}