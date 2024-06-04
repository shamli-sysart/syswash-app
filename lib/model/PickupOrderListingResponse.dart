/// code : 200
/// pickup : [{"pickupassgnId":56,"pickupassgn":[],"pickupDate":"2024-03-16","pickupCustomerId":"2551","pickupCustomerName":"SAVAD","pickupCustomerArea":"AIN KHALID","pickupCustomerCode":"JL2551","pickupCustomerPhno":99009900,"pickupDriverid":8,"pickupDrivername":"Shamli","pickupstatus":"Assigned","AssignedFrom":"orderList","pickupOrderId":"24388","trash":false},{"pickupassgnId":66,"pickupassgn":[],"pickupDate":"2024-03-18","pickupCustomerId":"2563","pickupCustomerName":"SHMILI","pickupCustomerArea":"Doha","pickupCustomerCode":"JL2563","pickupCustomerPhno":788990766,"pickupDriverid":8,"pickupDrivername":"Shamli","pickupstatus":"Assigned","AssignedFrom":"orderList","pickupOrderId":"24379","trash":false},{"pickupassgnId":67,"pickupassgn":[],"pickupDate":"2024-03-18","pickupCustomerId":"2564","pickupCustomerName":"jiny","pickupCustomerArea":"Doha","pickupCustomerCode":"JL2564","pickupCustomerPhno":35789642,"pickupDriverid":8,"pickupDrivername":"Shamli","pickupstatus":"Assigned","AssignedFrom":null,"pickupOrderId":null,"trash":false},{"pickupassgnId":68,"pickupassgn":[],"pickupDate":"2024-03-18","pickupCustomerId":"2564","pickupCustomerName":"jiny","pickupCustomerArea":"Doha","pickupCustomerCode":"JL2564","pickupCustomerPhno":35789642,"pickupDriverid":8,"pickupDrivername":"Shamli","pickupstatus":"Assigned","AssignedFrom":null,"pickupOrderId":null,"trash":false},{"pickupassgnId":69,"pickupassgn":[],"pickupDate":"2024-03-18","pickupCustomerId":"2551","pickupCustomerName":"SAVAD","pickupCustomerArea":"AIN KHALID","pickupCustomerCode":"JL2551","pickupCustomerPhno":99009900,"pickupDriverid":8,"pickupDrivername":"Shamli","pickupstatus":"Assigned","AssignedFrom":"orderList","pickupOrderId":"24388","trash":false},{"pickupassgnId":70,"pickupassgn":[{"pickuporderId":1,"paymentMode":null,"pickuporderDate":"2024-03-26","pickuporderTime":"12:359","quantity":2,"subTotal":6285.0,"discount":0.0,"totalAmount":6285.0,"paidAmount":0.0,"balance":6285.0,"deliveryType":"PICKUP & DELIVERY","accountType":"MobileApp","clothData":[{"qnty":1,"billing":"Express","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"10.000"},{"qnty":1,"billing":"Normal","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"5.000"}],"ClothWiseStatus":null,"status":"Received","tenderCurrency":null,"tenderDate":null,"tenderTime":null,"billReceiver":null,"trash":false,"pickupassgn":70},{"pickuporderId":2,"paymentMode":null,"pickuporderDate":"2024-03-26","pickuporderTime":"12:359","quantity":2,"subTotal":6285.0,"discount":0.0,"totalAmount":6285.0,"paidAmount":0.0,"balance":6285.0,"deliveryType":"PICKUP & DELIVERY","accountType":"MobileApp","clothData":[{"qnty":1,"billing":"Express","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"10.000"},{"qnty":1,"billing":"Normal","priceId":106,"service":"DC","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"5.000"}],"ClothWiseStatus":null,"status":"Received","tenderCurrency":null,"tenderDate":null,"tenderTime":null,"billReceiver":null,"trash":false,"pickupassgn":70}],"pickupDate":"2024-03-18","pickupCustomerId":"2562","pickupCustomerName":"nishitha","pickupCustomerArea":"Doha","pickupCustomerCode":"JL2562","pickupCustomerPhno":98764212345,"pickupDriverid":8,"pickupDrivername":"Shamli","pickupstatus":"Assigned","AssignedFrom":null,"pickupOrderId":null,"trash":false}]

class PickupOrderListingResponse {
  PickupOrderListingResponse({
    num? code,
    List<Pickup>? pickup,}){
    _code = code;
    _pickup = pickup;
  }

  PickupOrderListingResponse.fromJson(dynamic json) {
    _code = json['code'];
    if (json['pickup'] != null) {
      _pickup = [];
      json['pickup'].forEach((v) {
        _pickup?.add(Pickup.fromJson(v));
      });
    }
  }
  num? _code;
  List<Pickup>? _pickup;
  PickupOrderListingResponse copyWith({  num? code,
    List<Pickup>? pickup,
  }) => PickupOrderListingResponse(  code: code ?? _code,
    pickup: pickup ?? _pickup,
  );
  num? get code => _code;
  List<Pickup>? get pickup => _pickup;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    if (_pickup != null) {
      map['pickup'] = _pickup?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// pickupassgnId : 56
/// pickupassgn : []
/// pickupDate : "2024-03-16"
/// pickupCustomerId : "2551"
/// pickupCustomerName : "SAVAD"
/// pickupCustomerArea : "AIN KHALID"
/// pickupCustomerCode : "JL2551"
/// pickupCustomerPhno : 99009900
/// pickupDriverid : 8
/// pickupDrivername : "Shamli"
/// pickupstatus : "Assigned"
/// AssignedFrom : "orderList"
/// pickupOrderId : "24388"
/// trash : false

class Pickup {
  Pickup({
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
    String? assignedFrom,
    String? pickupOrderId,
    bool? trash,}){
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
    _trash = trash;
  }

  Pickup.fromJson(dynamic json) {
    _pickupassgnId = json['pickupassgnId'];
    if (json['pickupassgn'] != null) {
      _pickupassgn = [];
      json['pickupassgn'].forEach((v) {
        //_pickupassgn?.add(Dynamic.fromJson(v));
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
    _trash = json['trash'];
  }
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
  String? _assignedFrom;
  String? _pickupOrderId;
  bool? _trash;
  Pickup copyWith({  num? pickupassgnId,
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
    String? assignedFrom,
    String? pickupOrderId,
    bool? trash,
  }) => Pickup(  pickupassgnId: pickupassgnId ?? _pickupassgnId,
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
    trash: trash ?? _trash,
  );
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
  String? get assignedFrom => _assignedFrom;
  String? get pickupOrderId => _pickupOrderId;
  bool? get trash => _trash;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
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
    map['trash'] = _trash;
    return map;
  }

}