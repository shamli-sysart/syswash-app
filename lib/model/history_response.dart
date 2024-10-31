/// code : 200
/// pickup : [{"pickupassgnId":277,"pickupDate":"2024-06-11","pickupCustomerId":"2611","pickupCustomerName":"WAFI","pickupCustomerArea":"Doha","pickupCustomerCode":"JL2610","pickupCustomerPhno":71234566,"pickupDriverid":10,"pickupDrivername":"NewDriver","pickupstatus":"Received","AssignedFrom":null,"pickupOrderId":null,"trash":false},{"pickupassgnId":287,"pickupDate":"2024-06-11","pickupCustomerId":"2589","pickupCustomerName":"roshan","pickupCustomerArea":"Doha","pickupCustomerCode":"JL2589","pickupCustomerPhno":6878790,"pickupDriverid":10,"pickupDrivername":"NewDriver","pickupstatus":"Received","AssignedFrom":"orderList","pickupOrderId":"24583","trash":false},{"pickupassgnId":288,"pickupDate":"2024-06-11","pickupCustomerId":"2600","pickupCustomerName":"Daniel","pickupCustomerArea":"Dubai","pickupCustomerCode":"JL2600","pickupCustomerPhno":501234567,"pickupDriverid":10,"pickupDrivername":"NewDriver","pickupstatus":"Received","AssignedFrom":"orderList","pickupOrderId":"24582","trash":false}]
/// delivery : [{"orderId":24578,"deliveryassgn":[{"deliveryassgnId":141,"deliveryDate":"2024-06-13","deliveryTime":"15:13","deliveryCustomerId":"2599","deliveryCustomerName":"Shivani","deliveryCustomerArea":"Doha","deliveryCustomerCode":"JL2599","deliveryCustomerPhno":56765678,"deliveryDriverid":10,"deliveryDrivername":"NewDriver","status":"Delivered","paymentstatus":"collected","trash":false,"deliveryInvoiceNo":24578}]},{"orderId":24582,"deliveryassgn":[{"deliveryassgnId":146,"deliveryDate":"2024-06-13","deliveryTime":"17:03","deliveryCustomerId":"2600","deliveryCustomerName":"Daniel","deliveryCustomerArea":"Dubai","deliveryCustomerCode":"JL2600","deliveryCustomerPhno":501234567,"deliveryDriverid":10,"deliveryDrivername":"NewDriver","status":"Delivered","paymentstatus":"collected","trash":false,"deliveryInvoiceNo":24582}]}]

class HistoryResponse {
  HistoryResponse({
    num? code,
    List<Pickup>? pickup,
    List<Delivery>? delivery,}){
    _code = code;
    _pickup = pickup;
    _delivery = delivery;
  }

  HistoryResponse.fromJson(dynamic json) {
    _code = json['code'];
    if (json['pickup'] != null) {
      _pickup = [];
      json['pickup'].forEach((v) {
        _pickup?.add(Pickup.fromJson(v));
      });
    }
    if (json['delivery'] != null) {
      _delivery = [];
      json['delivery'].forEach((v) {
        _delivery?.add(Delivery.fromJson(v));
      });
    }
  }
  num? _code;
  List<Pickup>? _pickup;
  List<Delivery>? _delivery;
  HistoryResponse copyWith({  num? code,
    List<Pickup>? pickup,
    List<Delivery>? delivery,
  }) => HistoryResponse(  code: code ?? _code,
    pickup: pickup ?? _pickup,
    delivery: delivery ?? _delivery,
  );
  num? get code => _code;
  List<Pickup>? get pickup => _pickup;
  List<Delivery>? get delivery => _delivery;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    if (_pickup != null) {
      map['pickup'] = _pickup?.map((v) => v.toJson()).toList();
    }
    if (_delivery != null) {
      map['delivery'] = _delivery?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// orderId : 24578
/// deliveryassgn : [{"deliveryassgnId":141,"deliveryDate":"2024-06-13","deliveryTime":"15:13","deliveryCustomerId":"2599","deliveryCustomerName":"Shivani","deliveryCustomerArea":"Doha","deliveryCustomerCode":"JL2599","deliveryCustomerPhno":56765678,"deliveryDriverid":10,"deliveryDrivername":"NewDriver","status":"Delivered","paymentstatus":"collected","trash":false,"deliveryInvoiceNo":24578}]

class Delivery {
  Delivery({
    num? orderId,
    List<Deliveryassgn>? deliveryassgn,}){
    _orderId = orderId;
    _deliveryassgn = deliveryassgn;
  }

  Delivery.fromJson(dynamic json) {
    _orderId = json['orderId'];
    if (json['deliveryassgn'] != null) {
      _deliveryassgn = [];
      json['deliveryassgn'].forEach((v) {
        _deliveryassgn?.add(Deliveryassgn.fromJson(v));
      });
    }
  }
  num? _orderId;
  List<Deliveryassgn>? _deliveryassgn;
  Delivery copyWith({  num? orderId,
    List<Deliveryassgn>? deliveryassgn,
  }) => Delivery(  orderId: orderId ?? _orderId,
    deliveryassgn: deliveryassgn ?? _deliveryassgn,
  );
  num? get orderId => _orderId;
  List<Deliveryassgn>? get deliveryassgn => _deliveryassgn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orderId'] = _orderId;
    if (_deliveryassgn != null) {
      map['deliveryassgn'] = _deliveryassgn?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// deliveryassgnId : 141
/// deliveryDate : "2024-06-13"
/// deliveryTime : "15:13"
/// deliveryCustomerId : "2599"
/// deliveryCustomerName : "Shivani"
/// deliveryCustomerArea : "Doha"
/// deliveryCustomerCode : "JL2599"
/// deliveryCustomerPhno : 56765678
/// deliveryDriverid : 10
/// deliveryDrivername : "NewDriver"
/// status : "Delivered"
/// paymentstatus : "collected"
/// trash : false
/// deliveryInvoiceNo : 24578

class Deliveryassgn {
  Deliveryassgn({
    num? deliveryassgnId,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveryCustomerId,
    String? deliveryCustomerName,
    String? deliveryCustomerArea,
    String? deliveryCustomerCode,
    num? deliveryCustomerPhno,
    num? deliveryDriverid,
    String? deliveryDrivername,
    String? status,
    String? paymentstatus,
    bool? trash,
    num? deliveryInvoiceNo,}){
    _deliveryassgnId = deliveryassgnId;
    _deliveryDate = deliveryDate;
    _deliveryTime = deliveryTime;
    _deliveryCustomerId = deliveryCustomerId;
    _deliveryCustomerName = deliveryCustomerName;
    _deliveryCustomerArea = deliveryCustomerArea;
    _deliveryCustomerCode = deliveryCustomerCode;
    _deliveryCustomerPhno = deliveryCustomerPhno;
    _deliveryDriverid = deliveryDriverid;
    _deliveryDrivername = deliveryDrivername;
    _status = status;
    _paymentstatus = paymentstatus;
    _trash = trash;
    _deliveryInvoiceNo = deliveryInvoiceNo;
  }

  Deliveryassgn.fromJson(dynamic json) {
    _deliveryassgnId = json['deliveryassgnId'];
    _deliveryDate = json['deliveryDate'];
    _deliveryTime = json['deliveryTime'];
    _deliveryCustomerId = json['deliveryCustomerId'];
    _deliveryCustomerName = json['deliveryCustomerName'];
    _deliveryCustomerArea = json['deliveryCustomerArea'];
    _deliveryCustomerCode = json['deliveryCustomerCode'];
    _deliveryCustomerPhno = json['deliveryCustomerPhno'];
    _deliveryDriverid = json['deliveryDriverid'];
    _deliveryDrivername = json['deliveryDrivername'];
    _status = json['status'];
    _paymentstatus = json['paymentstatus'];
    _trash = json['trash'];
    _deliveryInvoiceNo = json['deliveryInvoiceNo'];
  }
  num? _deliveryassgnId;
  String? _deliveryDate;
  String? _deliveryTime;
  String? _deliveryCustomerId;
  String? _deliveryCustomerName;
  String? _deliveryCustomerArea;
  String? _deliveryCustomerCode;
  num? _deliveryCustomerPhno;
  num? _deliveryDriverid;
  String? _deliveryDrivername;
  String? _status;
  String? _paymentstatus;
  bool? _trash;
  num? _deliveryInvoiceNo;
  Deliveryassgn copyWith({  num? deliveryassgnId,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveryCustomerId,
    String? deliveryCustomerName,
    String? deliveryCustomerArea,
    String? deliveryCustomerCode,
    num? deliveryCustomerPhno,
    num? deliveryDriverid,
    String? deliveryDrivername,
    String? status,
    String? paymentstatus,
    bool? trash,
    num? deliveryInvoiceNo,
  }) => Deliveryassgn(  deliveryassgnId: deliveryassgnId ?? _deliveryassgnId,
    deliveryDate: deliveryDate ?? _deliveryDate,
    deliveryTime: deliveryTime ?? _deliveryTime,
    deliveryCustomerId: deliveryCustomerId ?? _deliveryCustomerId,
    deliveryCustomerName: deliveryCustomerName ?? _deliveryCustomerName,
    deliveryCustomerArea: deliveryCustomerArea ?? _deliveryCustomerArea,
    deliveryCustomerCode: deliveryCustomerCode ?? _deliveryCustomerCode,
    deliveryCustomerPhno: deliveryCustomerPhno ?? _deliveryCustomerPhno,
    deliveryDriverid: deliveryDriverid ?? _deliveryDriverid,
    deliveryDrivername: deliveryDrivername ?? _deliveryDrivername,
    status: status ?? _status,
    paymentstatus: paymentstatus ?? _paymentstatus,
    trash: trash ?? _trash,
    deliveryInvoiceNo: deliveryInvoiceNo ?? _deliveryInvoiceNo,
  );
  num? get deliveryassgnId => _deliveryassgnId;
  String? get deliveryDate => _deliveryDate;
  String? get deliveryTime => _deliveryTime;
  String? get deliveryCustomerId => _deliveryCustomerId;
  String? get deliveryCustomerName => _deliveryCustomerName;
  String? get deliveryCustomerArea => _deliveryCustomerArea;
  String? get deliveryCustomerCode => _deliveryCustomerCode;
  num? get deliveryCustomerPhno => _deliveryCustomerPhno;
  num? get deliveryDriverid => _deliveryDriverid;
  String? get deliveryDrivername => _deliveryDrivername;
  String? get status => _status;
  String? get paymentstatus => _paymentstatus;
  bool? get trash => _trash;
  num? get deliveryInvoiceNo => _deliveryInvoiceNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['deliveryassgnId'] = _deliveryassgnId;
    map['deliveryDate'] = _deliveryDate;
    map['deliveryTime'] = _deliveryTime;
    map['deliveryCustomerId'] = _deliveryCustomerId;
    map['deliveryCustomerName'] = _deliveryCustomerName;
    map['deliveryCustomerArea'] = _deliveryCustomerArea;
    map['deliveryCustomerCode'] = _deliveryCustomerCode;
    map['deliveryCustomerPhno'] = _deliveryCustomerPhno;
    map['deliveryDriverid'] = _deliveryDriverid;
    map['deliveryDrivername'] = _deliveryDrivername;
    map['status'] = _status;
    map['paymentstatus'] = _paymentstatus;
    map['trash'] = _trash;
    map['deliveryInvoiceNo'] = _deliveryInvoiceNo;
    return map;
  }

}

/// pickupassgnId : 277
/// pickupDate : "2024-06-11"
/// pickupCustomerId : "2611"
/// pickupCustomerName : "WAFI"
/// pickupCustomerArea : "Doha"
/// pickupCustomerCode : "JL2610"
/// pickupCustomerPhno : 71234566
/// pickupDriverid : 10
/// pickupDrivername : "NewDriver"
/// pickupstatus : "Received"
/// AssignedFrom : null
/// pickupOrderId : null
/// trash : false

class Pickup {
  Pickup({
    num? pickupassgnId,
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
    bool? trash,}){
    _pickupassgnId = pickupassgnId;
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
  bool? _trash;
  Pickup copyWith({  num? pickupassgnId,
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
    bool? trash,
  }) => Pickup(  pickupassgnId: pickupassgnId ?? _pickupassgnId,
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
  bool? get trash => _trash;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pickupassgnId'] = _pickupassgnId;
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