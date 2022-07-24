class CallModel {
  late String totalLength;
  late bool isVerified;
  // late String employeeId;
  // late String clientId;
  late String from;
  late String to;

  CallModel(
      {required this.totalLength,
      // required this.employeeId,
      // required this.clientId,
      required this.isVerified,required this.from,required this.to});

  CallModel.fromJson(Map<String, dynamic> json) {
    totalLength = json['totalLength'];
    isVerified = json['verified'];
    // employeeId = json['employeeId'];
    // clientId = json['clientId'];
    to = json['to'];
    from = json['from'];

  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['duration'] = totalLength;
    data['verified'] = isVerified;
    // data['to'] = employeeId;
    // data['from'] = clientId;
    data['from']=from;
    data['to']=to;
    return data;
  }
}
