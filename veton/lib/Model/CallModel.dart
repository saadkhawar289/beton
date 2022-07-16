class CallModel {
  late String totalLength;
  late bool isVerified;
  late String employeeId;
  late String clientId;

  CallModel(
      {required this.totalLength,
      required this.employeeId,
      required this.clientId,
      required this.isVerified});

  CallModel.fromJson(Map<String, dynamic> json) {
    totalLength = json['totalLength'];
    isVerified = json['isVerified'];
    employeeId = json['employeeId'];
    clientId = json['clientId'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalLength'] = totalLength;
    data['isVerified'] = isVerified;
    data['employeeId'] = employeeId;
    data['clientId'] = clientId;

    return data;
  }
}
