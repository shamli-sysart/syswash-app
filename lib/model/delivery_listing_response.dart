class DeliveryListingResponse {
  DeliveryListingResponse({
    num? code,
    List<Data>? data,}){
    _code = code;
    _data = data;
  }

  DeliveryListingResponse.fromJson(dynamic json) {
    _code = json['code'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  num? _code;
  List<Data>? _data;
  DeliveryListingResponse copyWith({  num? code,
    List<Data>? data,
  }) => DeliveryListingResponse(  code: code ?? _code,
    data: data ?? _data,
  );
  num? get code => _code;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// deliveryassgnId : 45
/// deliveryDate : "2024-03-16"
/// deliveryTime : null
/// deliveryCustomerId : null
/// deliveryCustomerName : null
/// deliveryCustomerArea : null
/// deliveryCustomerCode : null
/// deliveryCustomerPhno : null
/// deliveryDriverid : 8
/// deliveryDrivername : "Shamli"
/// status : "Assigned"
/// paymentstatus : "pending"
/// trash : false
/// deliveryInvoiceNo : 24388

class Data {
  Data({
    num? deliveryassgnId,
    String? deliveryDate,
    dynamic deliveryTime,
    dynamic deliveryCustomerId,
    dynamic deliveryCustomerName,
    dynamic deliveryCustomerArea,
    dynamic deliveryCustomerCode,
    dynamic deliveryCustomerPhno,
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

  Data.fromJson(dynamic json) {
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
  dynamic _deliveryTime;
  dynamic _deliveryCustomerId;
  dynamic _deliveryCustomerName;
  dynamic _deliveryCustomerArea;
  dynamic _deliveryCustomerCode;
  dynamic _deliveryCustomerPhno;
  num? _deliveryDriverid;
  String? _deliveryDrivername;
  String? _status;
  String? _paymentstatus;
  bool? _trash;
  num? _deliveryInvoiceNo;
  Data copyWith({  num? deliveryassgnId,
    String? deliveryDate,
    dynamic deliveryTime,
    dynamic deliveryCustomerId,
    dynamic deliveryCustomerName,
    dynamic deliveryCustomerArea,
    dynamic deliveryCustomerCode,
    dynamic deliveryCustomerPhno,
    num? deliveryDriverid,
    String? deliveryDrivername,
    String? status,
    String? paymentstatus,
    bool? trash,
    num? deliveryInvoiceNo,
  }) => Data(  deliveryassgnId: deliveryassgnId ?? _deliveryassgnId,
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
  dynamic get deliveryTime => _deliveryTime;
  dynamic get deliveryCustomerId => _deliveryCustomerId;
  dynamic get deliveryCustomerName => _deliveryCustomerName;
  dynamic get deliveryCustomerArea => _deliveryCustomerArea;
  dynamic get deliveryCustomerCode => _deliveryCustomerCode;
  dynamic get deliveryCustomerPhno => _deliveryCustomerPhno;
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