


/// code : 200
/// pickupassgnId : 6
/// pickupassgn : []
/// pickupDate : "2024-07-04"
/// pickupCustomerId : "18"
/// pickupCustomerName : "Saleem"
/// pickupCustomerArea : "Doha"
/// pickupCustomerCode : "JL0018"
/// pickupCustomerPhno : 66516153
/// pickupDriverid : 1
/// pickupDrivername : "nishi"
/// pickupstatus : "Assigned"
/// AssignedFrom : null
/// pickupOrderId : null
/// remarks : "pickup soon"
/// notes : "should deliver in 2 days"
/// trash : false

class PickupCustomerResponse {
  PickupCustomerResponse({
    num? code,
    num? pickupassgnId,
    List<dynamic>? pickupassgn,
    String? pickupDate,
    String? pickupCustomerId,
    String? pickupCustomerName,
    String? pickupCustomerArea,
    String? pickupCustomerCode,
    num? pickupCustomerPhno,
    num? pickupDriverid,
    String? pickupDrivername,
    String? pickupstatus,
    dynamic assignedFrom,
    dynamic pickupOrderId,
    String? remarks,
    String? notes,
    bool? trash,}){
    _code = code;
    _pickupassgnId = pickupassgnId;
    _pickupassgn = pickupassgn;
    _pickupDate = pickupDate;
    _pickupCustomerId = pickupCustomerId;
    _pickupCustomerName = pickupCustomerName;
    _pickupCustomerArea = pickupCustomerArea;
    _pickupCustomerCode = pickupCustomerCode;
    _pickupCustomerPhno = pickupCustomerPhno;
    _pickupDriverid = pickupDriverid;
    _pickupDrivername = pickupDrivername;
    _pickupstatus = pickupstatus;
    _assignedFrom = assignedFrom;
    _pickupOrderId = pickupOrderId;
    _remarks = remarks;
    _notes = notes;
    _trash = trash;
  }

  PickupCustomerResponse.fromJson(dynamic json) {
    _code = json['code'];
    _pickupassgnId = json['pickupassgnId'];
    if (json['pickupassgn'] != null) {
      _pickupassgn = [];
      json['pickupassgn'].forEach((v) {
        // _pickupassgn?.add(Dynamic.fromJson(v));
      });
    }
    _pickupDate = json['pickupDate'];
    _pickupCustomerId = json['pickupCustomerId'];
    _pickupCustomerName = json['pickupCustomerName'];
    _pickupCustomerArea = json['pickupCustomerArea'];
    _pickupCustomerCode = json['pickupCustomerCode'];
    _pickupCustomerPhno = json['pickupCustomerPhno'];
    _pickupDriverid = json['pickupDriverid'];
    _pickupDrivername = json['pickupDrivername'];
    _pickupstatus = json['pickupstatus'];
    _assignedFrom = json['AssignedFrom'];
    _pickupOrderId = json['pickupOrderId'];
    _remarks = json['remarks'];
    _notes = json['notes'];
    _trash = json['trash'];
  }
  num? _code;
  num? _pickupassgnId;
  List<dynamic>? _pickupassgn;
  String? _pickupDate;
  String? _pickupCustomerId;
  String? _pickupCustomerName;
  String? _pickupCustomerArea;
  String? _pickupCustomerCode;
  num? _pickupCustomerPhno;
  num? _pickupDriverid;
  String? _pickupDrivername;
  String? _pickupstatus;
  dynamic _assignedFrom;
  dynamic _pickupOrderId;
  String? _remarks;
  String? _notes;
  bool? _trash;
  PickupCustomerResponse copyWith({  num? code,
    num? pickupassgnId,
    List<dynamic>? pickupassgn,
    String? pickupDate,
    String? pickupCustomerId,
    String? pickupCustomerName,
    String? pickupCustomerArea,
    String? pickupCustomerCode,
    num? pickupCustomerPhno,
    num? pickupDriverid,
    String? pickupDrivername,
    String? pickupstatus,
    dynamic assignedFrom,
    dynamic pickupOrderId,
    String? remarks,
    String? notes,
    bool? trash,
  }) => PickupCustomerResponse(  code: code ?? _code,
    pickupassgnId: pickupassgnId ?? _pickupassgnId,
    pickupassgn: pickupassgn ?? _pickupassgn,
    pickupDate: pickupDate ?? _pickupDate,
    pickupCustomerId: pickupCustomerId ?? _pickupCustomerId,
    pickupCustomerName: pickupCustomerName ?? _pickupCustomerName,
    pickupCustomerArea: pickupCustomerArea ?? _pickupCustomerArea,
    pickupCustomerCode: pickupCustomerCode ?? _pickupCustomerCode,
    pickupCustomerPhno: pickupCustomerPhno ?? _pickupCustomerPhno,
    pickupDriverid: pickupDriverid ?? _pickupDriverid,
    pickupDrivername: pickupDrivername ?? _pickupDrivername,
    pickupstatus: pickupstatus ?? _pickupstatus,
    assignedFrom: assignedFrom ?? _assignedFrom,
    pickupOrderId: pickupOrderId ?? _pickupOrderId,
    remarks: remarks ?? _remarks,
    notes: notes ?? _notes,
    trash: trash ?? _trash,
  );
  num? get code => _code;
  num? get pickupassgnId => _pickupassgnId;
  List<dynamic>? get pickupassgn => _pickupassgn;
  String? get pickupDate => _pickupDate;
  String? get pickupCustomerId => _pickupCustomerId;
  String? get pickupCustomerName => _pickupCustomerName;
  String? get pickupCustomerArea => _pickupCustomerArea;
  String? get pickupCustomerCode => _pickupCustomerCode;
  num? get pickupCustomerPhno => _pickupCustomerPhno;
  num? get pickupDriverid => _pickupDriverid;
  String? get pickupDrivername => _pickupDrivername;
  String? get pickupstatus => _pickupstatus;
  dynamic get assignedFrom => _assignedFrom;
  dynamic get pickupOrderId => _pickupOrderId;
  String? get remarks => _remarks;
  String? get notes => _notes;
  bool? get trash => _trash;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['pickupassgnId'] = _pickupassgnId;
    if (_pickupassgn != null) {
      map['pickupassgn'] = _pickupassgn?.map((v) => v.toJson()).toList();
    }
    map['pickupDate'] = _pickupDate;
    map['pickupCustomerId'] = _pickupCustomerId;
    map['pickupCustomerName'] = _pickupCustomerName;
    map['pickupCustomerArea'] = _pickupCustomerArea;
    map['pickupCustomerCode'] = _pickupCustomerCode;
    map['pickupCustomerPhno'] = _pickupCustomerPhno;
    map['pickupDriverid'] = _pickupDriverid;
    map['pickupDrivername'] = _pickupDrivername;
    map['pickupstatus'] = _pickupstatus;
    map['AssignedFrom'] = _assignedFrom;
    map['pickupOrderId'] = _pickupOrderId;
    map['remarks'] = _remarks;
    map['notes'] = _notes;
    map['trash'] = _trash;
    return map;
  }

}

















// /// code : 200
// /// pickupassgnId : 67
// /// pickupassgn : [{"pickuporderId":3,"paymentMode":null,"pickuporderDate":"2024-03-28","pickuporderTime":"12:39","quantity":2,"subTotal":2000.0,"discount":0.0,"totalAmount":3000.0,"paidAmount":0.0,"balance":300.0,"deliveryType":"PICKUP & DELIVERY","accountType":"MobileApp","clothData":[{"qnty":1,"billing":"Express","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"10.000"},{"qnty":1,"billing":"Normal","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"5.000"}],"ClothWiseStatus":null,"status":"Received","tenderCurrency":null,"tenderDate":null,"tenderTime":null,"billReceiver":null,"trash":false,"pickupassgn":67}]
// /// pickupDate : "2024-03-18"
// /// pickupCustomerId : "2564"
// /// pickupCustomerName : "jiny"
// /// pickupCustomerArea : "Doha"
// /// pickupCustomerCode : "JL2564"
// /// pickupCustomerPhno : 35789642
// /// pickupDriverid : 8
// /// pickupDrivername : "Shamli"
// /// pickupstatus : "Assigned"
// /// AssignedFrom : null
// /// pickupOrderId : null
// /// trash : false
//
// class PickupCustomerResponse {
//   PickupCustomerResponse({
//     num? code,
//     num? pickupassgnId,
//     List<Pickupassgn>? pickupassgn,
//     String? pickupDate,
//     String? pickupCustomerId,
//     String? pickupCustomerName,
//     String? pickupCustomerArea,
//     String? pickupCustomerCode,
//     num? pickupCustomerPhno,
//     num? pickupDriverid,
//     String? pickupDrivername,
//     String? pickupstatus,
//     dynamic assignedFrom,
//     dynamic pickupOrderId,
//     bool? trash,}){
//     _code = code;
//     _pickupassgnId = pickupassgnId;
//     _pickupassgn = pickupassgn;
//     _pickupDate = pickupDate;
//     _pickupCustomerId = pickupCustomerId;
//     _pickupCustomerName = pickupCustomerName;
//     _pickupCustomerArea = pickupCustomerArea;
//     _pickupCustomerCode = pickupCustomerCode;
//     _pickupCustomerPhno = pickupCustomerPhno;
//     _pickupDriverid = pickupDriverid;
//     _pickupDrivername = pickupDrivername;
//     _pickupstatus = pickupstatus;
//     _assignedFrom = assignedFrom;
//     _pickupOrderId = pickupOrderId;
//     _trash = trash;
//   }
//
//   PickupCustomerResponse.fromJson(dynamic json) {
//     _code = json['code'];
//     _pickupassgnId = json['pickupassgnId'];
//     if (json['pickupassgn'] != null) {
//       _pickupassgn = [];
//       json['pickupassgn'].forEach((v) {
//         _pickupassgn?.add(Pickupassgn.fromJson(v));
//       });
//     }
//     _pickupDate = json['pickupDate'];
//     _pickupCustomerId = json['pickupCustomerId'];
//     _pickupCustomerName = json['pickupCustomerName'];
//     _pickupCustomerArea = json['pickupCustomerArea'];
//     _pickupCustomerCode = json['pickupCustomerCode'];
//     _pickupCustomerPhno = json['pickupCustomerPhno'];
//     _pickupDriverid = json['pickupDriverid'];
//     _pickupDrivername = json['pickupDrivername'];
//     _pickupstatus = json['pickupstatus'];
//     _assignedFrom = json['AssignedFrom'];
//     _pickupOrderId = json['pickupOrderId'];
//     _trash = json['trash'];
//   }
//   num? _code;
//   num? _pickupassgnId;
//   List<Pickupassgn>? _pickupassgn;
//   String? _pickupDate;
//   String? _pickupCustomerId;
//   String? _pickupCustomerName;
//   String? _pickupCustomerArea;
//   String? _pickupCustomerCode;
//   num? _pickupCustomerPhno;
//   num? _pickupDriverid;
//   String? _pickupDrivername;
//   String? _pickupstatus;
//   dynamic _assignedFrom;
//   dynamic _pickupOrderId;
//   bool? _trash;
//   PickupCustomerResponse copyWith({  num? code,
//     num? pickupassgnId,
//     List<Pickupassgn>? pickupassgn,
//     String? pickupDate,
//     String? pickupCustomerId,
//     String? pickupCustomerName,
//     String? pickupCustomerArea,
//     String? pickupCustomerCode,
//     num? pickupCustomerPhno,
//     num? pickupDriverid,
//     String? pickupDrivername,
//     String? pickupstatus,
//     dynamic assignedFrom,
//     dynamic pickupOrderId,
//     bool? trash,
//   }) => PickupCustomerResponse(  code: code ?? _code,
//     pickupassgnId: pickupassgnId ?? _pickupassgnId,
//     pickupassgn: pickupassgn ?? _pickupassgn,
//     pickupDate: pickupDate ?? _pickupDate,
//     pickupCustomerId: pickupCustomerId ?? _pickupCustomerId,
//     pickupCustomerName: pickupCustomerName ?? _pickupCustomerName,
//     pickupCustomerArea: pickupCustomerArea ?? _pickupCustomerArea,
//     pickupCustomerCode: pickupCustomerCode ?? _pickupCustomerCode,
//     pickupCustomerPhno: pickupCustomerPhno ?? _pickupCustomerPhno,
//     pickupDriverid: pickupDriverid ?? _pickupDriverid,
//     pickupDrivername: pickupDrivername ?? _pickupDrivername,
//     pickupstatus: pickupstatus ?? _pickupstatus,
//     assignedFrom: assignedFrom ?? _assignedFrom,
//     pickupOrderId: pickupOrderId ?? _pickupOrderId,
//     trash: trash ?? _trash,
//   );
//   num? get code => _code;
//   num? get pickupassgnId => _pickupassgnId;
//   List<Pickupassgn>? get pickupassgn => _pickupassgn;
//   String? get pickupDate => _pickupDate;
//   String? get pickupCustomerId => _pickupCustomerId;
//   String? get pickupCustomerName => _pickupCustomerName;
//   String? get pickupCustomerArea => _pickupCustomerArea;
//   String? get pickupCustomerCode => _pickupCustomerCode;
//   num? get pickupCustomerPhno => _pickupCustomerPhno;
//   num? get pickupDriverid => _pickupDriverid;
//   String? get pickupDrivername => _pickupDrivername;
//   String? get pickupstatus => _pickupstatus;
//   dynamic get assignedFrom => _assignedFrom;
//   dynamic get pickupOrderId => _pickupOrderId;
//   bool? get trash => _trash;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['code'] = _code;
//     map['pickupassgnId'] = _pickupassgnId;
//     if (_pickupassgn != null) {
//       map['pickupassgn'] = _pickupassgn?.map((v) => v.toJson()).toList();
//     }
//     map['pickupDate'] = _pickupDate;
//     map['pickupCustomerId'] = _pickupCustomerId;
//     map['pickupCustomerName'] = _pickupCustomerName;
//     map['pickupCustomerArea'] = _pickupCustomerArea;
//     map['pickupCustomerCode'] = _pickupCustomerCode;
//     map['pickupCustomerPhno'] = _pickupCustomerPhno;
//     map['pickupDriverid'] = _pickupDriverid;
//     map['pickupDrivername'] = _pickupDrivername;
//     map['pickupstatus'] = _pickupstatus;
//     map['AssignedFrom'] = _assignedFrom;
//     map['pickupOrderId'] = _pickupOrderId;
//     map['trash'] = _trash;
//     return map;
//   }
//
// }
//
// /// pickuporderId : 3
// /// paymentMode : null
// /// pickuporderDate : "2024-03-28"
// /// pickuporderTime : "12:39"
// /// quantity : 2
// /// subTotal : 2000.0
// /// discount : 0.0
// /// totalAmount : 3000.0
// /// paidAmount : 0.0
// /// balance : 300.0
// /// deliveryType : "PICKUP & DELIVERY"
// /// accountType : "MobileApp"
// /// clothData : [{"qnty":1,"billing":"Express","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"10.000"},{"qnty":1,"billing":"Normal","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"5.000"}]
// /// ClothWiseStatus : null
// /// status : "Received"
// /// tenderCurrency : null
// /// tenderDate : null
// /// tenderTime : null
// /// billReceiver : null
// /// trash : false
// /// pickupassgn : 67
//
// class Pickupassgn {
//   Pickupassgn({
//     num? pickuporderId,
//     dynamic paymentMode,
//     String? pickuporderDate,
//     String? pickuporderTime,
//     num? quantity,
//     num? subTotal,
//     num? discount,
//     num? totalAmount,
//     num? paidAmount,
//     num? balance,
//     String? deliveryType,
//     String? accountType,
//     List<ClothData>? clothData,
//     dynamic clothWiseStatus,
//     String? status,
//     dynamic tenderCurrency,
//     dynamic tenderDate,
//     dynamic tenderTime,
//     dynamic billReceiver,
//     bool? trash,
//     num? pickupassgn,}){
//     _pickuporderId = pickuporderId;
//     _paymentMode = paymentMode;
//     _pickuporderDate = pickuporderDate;
//     _pickuporderTime = pickuporderTime;
//     _quantity = quantity;
//     _subTotal = subTotal;
//     _discount = discount;
//     _totalAmount = totalAmount;
//     _paidAmount = paidAmount;
//     _balance = balance;
//     _deliveryType = deliveryType;
//     _accountType = accountType;
//     _clothData = clothData;
//     _clothWiseStatus = clothWiseStatus;
//     _status = status;
//     _tenderCurrency = tenderCurrency;
//     _tenderDate = tenderDate;
//     _tenderTime = tenderTime;
//     _billReceiver = billReceiver;
//     _trash = trash;
//     _pickupassgn = pickupassgn;
//   }
//
//   Pickupassgn.fromJson(dynamic json) {
//     _pickuporderId = json['pickuporderId'];
//     _paymentMode = json['paymentMode'];
//     _pickuporderDate = json['pickuporderDate'];
//     _pickuporderTime = json['pickuporderTime'];
//     _quantity = json['quantity'];
//     _subTotal = json['subTotal'];
//     _discount = json['discount'];
//     _totalAmount = json['totalAmount'];
//     _paidAmount = json['paidAmount'];
//     _balance = json['balance'];
//     _deliveryType = json['deliveryType'];
//     _accountType = json['accountType'];
//     if (json['clothData'] != null) {
//       _clothData = [];
//       json['clothData'].forEach((v) {
//         _clothData?.add(ClothData.fromJson(v));
//       });
//     }
//     _clothWiseStatus = json['ClothWiseStatus'];
//     _status = json['status'];
//     _tenderCurrency = json['tenderCurrency'];
//     _tenderDate = json['tenderDate'];
//     _tenderTime = json['tenderTime'];
//     _billReceiver = json['billReceiver'];
//     _trash = json['trash'];
//     _pickupassgn = json['pickupassgn'];
//   }
//   num? _pickuporderId;
//   dynamic _paymentMode;
//   String? _pickuporderDate;
//   String? _pickuporderTime;
//   num? _quantity;
//   num? _subTotal;
//   num? _discount;
//   num? _totalAmount;
//   num? _paidAmount;
//   num? _balance;
//   String? _deliveryType;
//   String? _accountType;
//   List<ClothData>? _clothData;
//   dynamic _clothWiseStatus;
//   String? _status;
//   dynamic _tenderCurrency;
//   dynamic _tenderDate;
//   dynamic _tenderTime;
//   dynamic _billReceiver;
//   bool? _trash;
//   num? _pickupassgn;
//   Pickupassgn copyWith({  num? pickuporderId,
//     dynamic paymentMode,
//     String? pickuporderDate,
//     String? pickuporderTime,
//     num? quantity,
//     num? subTotal,
//     num? discount,
//     num? totalAmount,
//     num? paidAmount,
//     num? balance,
//     String? deliveryType,
//     String? accountType,
//     List<ClothData>? clothData,
//     dynamic clothWiseStatus,
//     String? status,
//     dynamic tenderCurrency,
//     dynamic tenderDate,
//     dynamic tenderTime,
//     dynamic billReceiver,
//     bool? trash,
//     num? pickupassgn,
//   }) => Pickupassgn(  pickuporderId: pickuporderId ?? _pickuporderId,
//     paymentMode: paymentMode ?? _paymentMode,
//     pickuporderDate: pickuporderDate ?? _pickuporderDate,
//     pickuporderTime: pickuporderTime ?? _pickuporderTime,
//     quantity: quantity ?? _quantity,
//     subTotal: subTotal ?? _subTotal,
//     discount: discount ?? _discount,
//     totalAmount: totalAmount ?? _totalAmount,
//     paidAmount: paidAmount ?? _paidAmount,
//     balance: balance ?? _balance,
//     deliveryType: deliveryType ?? _deliveryType,
//     accountType: accountType ?? _accountType,
//     clothData: clothData ?? _clothData,
//     clothWiseStatus: clothWiseStatus ?? _clothWiseStatus,
//     status: status ?? _status,
//     tenderCurrency: tenderCurrency ?? _tenderCurrency,
//     tenderDate: tenderDate ?? _tenderDate,
//     tenderTime: tenderTime ?? _tenderTime,
//     billReceiver: billReceiver ?? _billReceiver,
//     trash: trash ?? _trash,
//     pickupassgn: pickupassgn ?? _pickupassgn,
//   );
//   num? get pickuporderId => _pickuporderId;
//   dynamic get paymentMode => _paymentMode;
//   String? get pickuporderDate => _pickuporderDate;
//   String? get pickuporderTime => _pickuporderTime;
//   num? get quantity => _quantity;
//   num? get subTotal => _subTotal;
//   num? get discount => _discount;
//   num? get totalAmount => _totalAmount;
//   num? get paidAmount => _paidAmount;
//   num? get balance => _balance;
//   String? get deliveryType => _deliveryType;
//   String? get accountType => _accountType;
//   List<ClothData>? get clothData => _clothData;
//   dynamic get clothWiseStatus => _clothWiseStatus;
//   String? get status => _status;
//   dynamic get tenderCurrency => _tenderCurrency;
//   dynamic get tenderDate => _tenderDate;
//   dynamic get tenderTime => _tenderTime;
//   dynamic get billReceiver => _billReceiver;
//   bool? get trash => _trash;
//   num? get pickupassgn => _pickupassgn;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['pickuporderId'] = _pickuporderId;
//     map['paymentMode'] = _paymentMode;
//     map['pickuporderDate'] = _pickuporderDate;
//     map['pickuporderTime'] = _pickuporderTime;
//     map['quantity'] = _quantity;
//     map['subTotal'] = _subTotal;
//     map['discount'] = _discount;
//     map['totalAmount'] = _totalAmount;
//     map['paidAmount'] = _paidAmount;
//     map['balance'] = _balance;
//     map['deliveryType'] = _deliveryType;
//     map['accountType'] = _accountType;
//     if (_clothData != null) {
//       map['clothData'] = _clothData?.map((v) => v.toJson()).toList();
//     }
//     map['ClothWiseStatus'] = _clothWiseStatus;
//     map['status'] = _status;
//     map['tenderCurrency'] = _tenderCurrency;
//     map['tenderDate'] = _tenderDate;
//     map['tenderTime'] = _tenderTime;
//     map['billReceiver'] = _billReceiver;
//     map['trash'] = _trash;
//     map['pickupassgn'] = _pickupassgn;
//     return map;
//   }
//
// }
//
// /// qnty : 1
// /// billing : "Express"
// /// priceId : 106
// /// service : "DC"
// /// clothImg : "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg"
// /// clothName : "T-SHIRT"
// /// arabicName : "بلوزة"
// /// clothPrice : "10.000"
//
// class ClothData {
//   ClothData({
//     num? qnty,
//     String? billing,
//     num? priceId,
//     String? service,
//     String? clothImg,
//     String? clothName,
//     String? arabicName,
//     String? clothPrice,}){
//     _qnty = qnty;
//     _billing = billing;
//     _priceId = priceId;
//     _service = service;
//     _clothImg = clothImg;
//     _clothName = clothName;
//     _arabicName = arabicName;
//     _clothPrice = clothPrice;
//   }
//
//   ClothData.fromJson(dynamic json) {
//     _qnty = json['qnty'];
//     _billing = json['billing'];
//     _priceId = json['priceId'];
//     _service = json['service'];
//     _clothImg = json['clothImg'];
//     _clothName = json['clothName'];
//     _arabicName = json['arabicName'];
//     _clothPrice = json['clothPrice'];
//   }
//   num? _qnty;
//   String? _billing;
//   num? _priceId;
//   String? _service;
//   String? _clothImg;
//   String? _clothName;
//   String? _arabicName;
//   String? _clothPrice;
//   ClothData copyWith({  num? qnty,
//     String? billing,
//     num? priceId,
//     String? service,
//     String? clothImg,
//     String? clothName,
//     String? arabicName,
//     String? clothPrice,
//   }) => ClothData(  qnty: qnty ?? _qnty,
//     billing: billing ?? _billing,
//     priceId: priceId ?? _priceId,
//     service: service ?? _service,
//     clothImg: clothImg ?? _clothImg,
//     clothName: clothName ?? _clothName,
//     arabicName: arabicName ?? _arabicName,
//     clothPrice: clothPrice ?? _clothPrice,
//   );
//   num? get qnty => _qnty;
//   String? get billing => _billing;
//   num? get priceId => _priceId;
//   String? get service => _service;
//   String? get clothImg => _clothImg;
//   String? get clothName => _clothName;
//   String? get arabicName => _arabicName;
//   String? get clothPrice => _clothPrice;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['qnty'] = _qnty;
//     map['billing'] = _billing;
//     map['priceId'] = _priceId;
//     map['service'] = _service;
//     map['clothImg'] = _clothImg;
//     map['clothName'] = _clothName;
//     map['arabicName'] = _arabicName;
//     map['clothPrice'] = _clothPrice;
//     return map;
//   }
//
// }