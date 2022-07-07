// class Client{
//   Data.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     email = json['email'];
//     phoneNumber = json['phoneNumber'];
//     isAddressApproved = json['isAddressApproved'];
//     unitNumber = json['unitNumber'];
//     streetAddress = json['streetAddress'];
//     area = json['area'];
//     zipCode = json['zipCode'];
//     totalOrder = json['totalOrder'];
//     todayOrder = json['todayOrder'];
//     isPauseDelivery = json['isPauseDelivery'];
//     vacationStartDt = json['vacationStartDt'];
//     vacationEndDt = json['vacationEndDt'];
//     defaultLiter = json['defaultLiter'];
//   }
//
//   const {client}=data[0]
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['email'] = this.email;
//     data['phoneNumber'] = this.phoneNumber;
//     data['isAddressApproved'] = this.isAddressApproved;
//     data['unitNumber'] = this.unitNumber;
//     data['streetAddress'] = this.streetAddress;
//     data['area'] = this.area;
//     data['zipCode'] = this.zipCode;
//     data['totalOrder'] = this.totalOrder;
//     data['todayOrder'] = this.todayOrder;
//     data['isPauseDelivery'] = this.isPauseDelivery;
//     data['vacationStartDt'] = this.vacationStartDt;
//     data['vacationEndDt'] = this.vacationEndDt;
//     data['defaultLiter'] = this.defaultLiter;
//     return data;
//   }
// }