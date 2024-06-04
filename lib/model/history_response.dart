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

class Delivery {
  Delivery({
    num? orderId,
    String? refNo,
    String? remarks,
    List<dynamic>? payment,
    List<dynamic>? editHistory,
    List<Deliveryassgn>? deliveryassgn,
    String? orderDate,
    String? orderTime,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveredDateTime,
    dynamic lastModifieddate,
    dynamic lastModifiedTime,
    String? customerId,
    String? customerCode,
    String? customerName,
    num? customerPhno,
    String? customerAddress,
    String? customerStreet,
    String? customerReffrNo,
    String? customerHotel,
    String? customerRoomNo,
    String? villaAddress,
    num? customerDiscount,
    String? cusfragrance,
    dynamic employeeId,
    dynamic employeeName,
    num? driverId,
    String? driverName,
    dynamic pickupDriverId,
    dynamic pickupDriverName,
    num? quantity,
    num? subTotal,
    num? discount,
    num? totalAmount,
    num? paidAmount,
    num? balance,
    String? bill,
    String? deliveryType,
    String? accountType,
    dynamic paymentMode,
    List<ClothData>? clothData,
    dynamic clothWiseStatus,
    bool? folded,
    bool? hanger,
    bool? packing,
    String? status,
    dynamic rackName,
    dynamic rackFloor,
    dynamic clothAndMechineId,
    num? tenderCurrency,
    num? commission,
    String? tenderDate,
    dynamic tenderTime,
    String? billReceiver,
    bool? pickupStatus,
    String? nasha,
    String? orderReceiver,
    num? wallet,
    num? vat,
    num? vatValue,
    num? openingBalance,
    bool? trash,}){
    _orderId = orderId;
    _refNo = refNo;
    _remarks = remarks;
    _payment = payment;
    _editHistory = editHistory;
    _deliveryassgn = deliveryassgn;
    _orderDate = orderDate;
    _orderTime = orderTime;
    _deliveryDate = deliveryDate;
    _deliveryTime = deliveryTime;
    _deliveredDateTime = deliveredDateTime;
    _lastModifieddate = lastModifieddate;
    _lastModifiedTime = lastModifiedTime;
    _customerId = customerId;
    _customerCode = customerCode;
    _customerName = customerName;
    _customerPhno = customerPhno;
    _customerAddress = customerAddress;
    _customerStreet = customerStreet;
    _customerReffrNo = customerReffrNo;
    _customerHotel = customerHotel;
    _customerRoomNo = customerRoomNo;
    _villaAddress = villaAddress;
    _customerDiscount = customerDiscount;
    _cusfragrance = cusfragrance;
    _employeeId = employeeId;
    _employeeName = employeeName;
    _driverId = driverId;
    _driverName = driverName;
    _pickupDriverId = pickupDriverId;
    _pickupDriverName = pickupDriverName;
    _quantity = quantity;
    _subTotal = subTotal;
    _discount = discount;
    _totalAmount = totalAmount;
    _paidAmount = paidAmount;
    _balance = balance;
    _bill = bill;
    _deliveryType = deliveryType;
    _accountType = accountType;
    _paymentMode = paymentMode;
    _clothData = clothData;
    _clothWiseStatus = clothWiseStatus;
    _folded = folded;
    _hanger = hanger;
    _packing = packing;
    _status = status;
    _rackName = rackName;
    _rackFloor = rackFloor;
    _clothAndMechineId = clothAndMechineId;
    _tenderCurrency = tenderCurrency;
    _commission = commission;
    _tenderDate = tenderDate;
    _tenderTime = tenderTime;
    _billReceiver = billReceiver;
    _pickupStatus = pickupStatus;
    _nasha = nasha;
    _orderReceiver = orderReceiver;
    _wallet = wallet;
    _vat = vat;
    _vatValue = vatValue;
    _openingBalance = openingBalance;
    _trash = trash;
  }

  Delivery.fromJson(dynamic json) {
    _orderId = json['orderId'];
    _refNo = json['refNo'];
    _remarks = json['remarks'];
    if (json['payment'] != null) {
      _payment = [];
      json['payment'].forEach((v) {
        //_payment?.add(Dynamic.fromJson(v));
      });
    }
    if (json['edit_history'] != null) {
      _editHistory = [];
      json['edit_history'].forEach((v) {
        //_editHistory?.add(Dynamic.fromJson(v));
      });
    }
    if (json['deliveryassgn'] != null) {
      _deliveryassgn = [];
      json['deliveryassgn'].forEach((v) {
        _deliveryassgn?.add(Deliveryassgn.fromJson(v));
      });
    }
    _orderDate = json['orderDate'];
    _orderTime = json['orderTime'];
    _deliveryDate = json['deliveryDate'];
    _deliveryTime = json['deliveryTime'];
    _deliveredDateTime = json['deliveredDateTime'];
    _lastModifieddate = json['lastModifieddate'];
    _lastModifiedTime = json['lastModifiedTime'];
    _customerId = json['customerId'];
    _customerCode = json['customerCode'];
    _customerName = json['customerName'];
    _customerPhno = json['customerPhno'];
    _customerAddress = json['customerAddress'];
    _customerStreet = json['customerStreet'];
    _customerReffrNo = json['customerReffrNo'];
    _customerHotel = json['customerHotel'];
    _customerRoomNo = json['customerRoomNo'];
    _villaAddress = json['villaAddress'];
    _customerDiscount = json['customerDiscount'];
    _cusfragrance = json['cusfragrance'];
    _employeeId = json['employeeId'];
    _employeeName = json['employeeName'];
    _driverId = json['driverId'];
    _driverName = json['driverName'];
    _pickupDriverId = json['pickupDriverId'];
    _pickupDriverName = json['pickupDriverName'];
    _quantity = json['quantity'];
    _subTotal = json['subTotal'];
    _discount = json['discount'];
    _totalAmount = json['totalAmount'];
    _paidAmount = json['paidAmount'];
    _balance = json['balance'];
    _bill = json['bill'];
    _deliveryType = json['deliveryType'];
    _accountType = json['accountType'];
    _paymentMode = json['paymentMode'];
    if (json['clothData'] != null) {
      _clothData = [];
      json['clothData'].forEach((v) {
        _clothData?.add(ClothData.fromJson(v));
      });
    }
    _clothWiseStatus = json['ClothWiseStatus'];
    _folded = json['folded'];
    _hanger = json['hanger'];
    _packing = json['packing'];
    _status = json['status'];
    _rackName = json['rackName'];
    _rackFloor = json['rackFloor'];
    _clothAndMechineId = json['clothAndMechineId'];
    _tenderCurrency = json['tenderCurrency'];
    _commission = json['commission'];
    _tenderDate = json['tenderDate'];
    _tenderTime = json['tenderTime'];
    _billReceiver = json['billReceiver'];
    _pickupStatus = json['pickupStatus'];
    _nasha = json['nasha'];
    _orderReceiver = json['orderReceiver'];
    _wallet = json['wallet'];
    _vat = json['vat'];
    _vatValue = json['vatValue'];
    _openingBalance = json['openingBalance'];
    _trash = json['trash'];
  }
  num? _orderId;
  String? _refNo;
  String? _remarks;
  List<dynamic>? _payment;
  List<dynamic>? _editHistory;
  List<Deliveryassgn>? _deliveryassgn;
  String? _orderDate;
  String? _orderTime;
  String? _deliveryDate;
  String? _deliveryTime;
  String? _deliveredDateTime;
  dynamic _lastModifieddate;
  dynamic _lastModifiedTime;
  String? _customerId;
  String? _customerCode;
  String? _customerName;
  num? _customerPhno;
  String? _customerAddress;
  String? _customerStreet;
  String? _customerReffrNo;
  String? _customerHotel;
  String? _customerRoomNo;
  String? _villaAddress;
  num? _customerDiscount;
  String? _cusfragrance;
  dynamic _employeeId;
  dynamic _employeeName;
  num? _driverId;
  String? _driverName;
  dynamic _pickupDriverId;
  dynamic _pickupDriverName;
  num? _quantity;
  num? _subTotal;
  num? _discount;
  num? _totalAmount;
  num? _paidAmount;
  num? _balance;
  String? _bill;
  String? _deliveryType;
  String? _accountType;
  dynamic _paymentMode;
  List<ClothData>? _clothData;
  dynamic _clothWiseStatus;
  bool? _folded;
  bool? _hanger;
  bool? _packing;
  String? _status;
  dynamic _rackName;
  dynamic _rackFloor;
  dynamic _clothAndMechineId;
  num? _tenderCurrency;
  num? _commission;
  String? _tenderDate;
  dynamic _tenderTime;
  String? _billReceiver;
  bool? _pickupStatus;
  String? _nasha;
  String? _orderReceiver;
  num? _wallet;
  num? _vat;
  num? _vatValue;
  num? _openingBalance;
  bool? _trash;
  Delivery copyWith({  num? orderId,
    String? refNo,
    String? remarks,
    List<dynamic>? payment,
    List<dynamic>? editHistory,
    List<Deliveryassgn>? deliveryassgn,
    String? orderDate,
    String? orderTime,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveredDateTime,
    dynamic lastModifieddate,
    dynamic lastModifiedTime,
    String? customerId,
    String? customerCode,
    String? customerName,
    num? customerPhno,
    String? customerAddress,
    String? customerStreet,
    String? customerReffrNo,
    String? customerHotel,
    String? customerRoomNo,
    String? villaAddress,
    num? customerDiscount,
    String? cusfragrance,
    dynamic employeeId,
    dynamic employeeName,
    num? driverId,
    String? driverName,
    dynamic pickupDriverId,
    dynamic pickupDriverName,
    num? quantity,
    num? subTotal,
    num? discount,
    num? totalAmount,
    num? paidAmount,
    num? balance,
    String? bill,
    String? deliveryType,
    String? accountType,
    dynamic paymentMode,
    List<ClothData>? clothData,
    dynamic clothWiseStatus,
    bool? folded,
    bool? hanger,
    bool? packing,
    String? status,
    dynamic rackName,
    dynamic rackFloor,
    dynamic clothAndMechineId,
    num? tenderCurrency,
    num? commission,
    String? tenderDate,
    dynamic tenderTime,
    String? billReceiver,
    bool? pickupStatus,
    String? nasha,
    String? orderReceiver,
    num? wallet,
    num? vat,
    num? vatValue,
    num? openingBalance,
    bool? trash,
  }) => Delivery(  orderId: orderId ?? _orderId,
    refNo: refNo ?? _refNo,
    remarks: remarks ?? _remarks,
    payment: payment ?? _payment,
    editHistory: editHistory ?? _editHistory,
    deliveryassgn: deliveryassgn ?? _deliveryassgn,
    orderDate: orderDate ?? _orderDate,
    orderTime: orderTime ?? _orderTime,
    deliveryDate: deliveryDate ?? _deliveryDate,
    deliveryTime: deliveryTime ?? _deliveryTime,
    deliveredDateTime: deliveredDateTime ?? _deliveredDateTime,
    lastModifieddate: lastModifieddate ?? _lastModifieddate,
    lastModifiedTime: lastModifiedTime ?? _lastModifiedTime,
    customerId: customerId ?? _customerId,
    customerCode: customerCode ?? _customerCode,
    customerName: customerName ?? _customerName,
    customerPhno: customerPhno ?? _customerPhno,
    customerAddress: customerAddress ?? _customerAddress,
    customerStreet: customerStreet ?? _customerStreet,
    customerReffrNo: customerReffrNo ?? _customerReffrNo,
    customerHotel: customerHotel ?? _customerHotel,
    customerRoomNo: customerRoomNo ?? _customerRoomNo,
    villaAddress: villaAddress ?? _villaAddress,
    customerDiscount: customerDiscount ?? _customerDiscount,
    cusfragrance: cusfragrance ?? _cusfragrance,
    employeeId: employeeId ?? _employeeId,
    employeeName: employeeName ?? _employeeName,
    driverId: driverId ?? _driverId,
    driverName: driverName ?? _driverName,
    pickupDriverId: pickupDriverId ?? _pickupDriverId,
    pickupDriverName: pickupDriverName ?? _pickupDriverName,
    quantity: quantity ?? _quantity,
    subTotal: subTotal ?? _subTotal,
    discount: discount ?? _discount,
    totalAmount: totalAmount ?? _totalAmount,
    paidAmount: paidAmount ?? _paidAmount,
    balance: balance ?? _balance,
    bill: bill ?? _bill,
    deliveryType: deliveryType ?? _deliveryType,
    accountType: accountType ?? _accountType,
    paymentMode: paymentMode ?? _paymentMode,
    clothData: clothData ?? _clothData,
    clothWiseStatus: clothWiseStatus ?? _clothWiseStatus,
    folded: folded ?? _folded,
    hanger: hanger ?? _hanger,
    packing: packing ?? _packing,
    status: status ?? _status,
    rackName: rackName ?? _rackName,
    rackFloor: rackFloor ?? _rackFloor,
    clothAndMechineId: clothAndMechineId ?? _clothAndMechineId,
    tenderCurrency: tenderCurrency ?? _tenderCurrency,
    commission: commission ?? _commission,
    tenderDate: tenderDate ?? _tenderDate,
    tenderTime: tenderTime ?? _tenderTime,
    billReceiver: billReceiver ?? _billReceiver,
    pickupStatus: pickupStatus ?? _pickupStatus,
    nasha: nasha ?? _nasha,
    orderReceiver: orderReceiver ?? _orderReceiver,
    wallet: wallet ?? _wallet,
    vat: vat ?? _vat,
    vatValue: vatValue ?? _vatValue,
    openingBalance: openingBalance ?? _openingBalance,
    trash: trash ?? _trash,
  );
  num? get orderId => _orderId;
  String? get refNo => _refNo;
  String? get remarks => _remarks;
  List<dynamic>? get payment => _payment;
  List<dynamic>? get editHistory => _editHistory;
  List<Deliveryassgn>? get deliveryassgn => _deliveryassgn;
  String? get orderDate => _orderDate;
  String? get orderTime => _orderTime;
  String? get deliveryDate => _deliveryDate;
  String? get deliveryTime => _deliveryTime;
  String? get deliveredDateTime => _deliveredDateTime;
  dynamic get lastModifieddate => _lastModifieddate;
  dynamic get lastModifiedTime => _lastModifiedTime;
  String? get customerId => _customerId;
  String? get customerCode => _customerCode;
  String? get customerName => _customerName;
  num? get customerPhno => _customerPhno;
  String? get customerAddress => _customerAddress;
  String? get customerStreet => _customerStreet;
  String? get customerReffrNo => _customerReffrNo;
  String? get customerHotel => _customerHotel;
  String? get customerRoomNo => _customerRoomNo;
  String? get villaAddress => _villaAddress;
  num? get customerDiscount => _customerDiscount;
  String? get cusfragrance => _cusfragrance;
  dynamic get employeeId => _employeeId;
  dynamic get employeeName => _employeeName;
  num? get driverId => _driverId;
  String? get driverName => _driverName;
  dynamic get pickupDriverId => _pickupDriverId;
  dynamic get pickupDriverName => _pickupDriverName;
  num? get quantity => _quantity;
  num? get subTotal => _subTotal;
  num? get discount => _discount;
  num? get totalAmount => _totalAmount;
  num? get paidAmount => _paidAmount;
  num? get balance => _balance;
  String? get bill => _bill;
  String? get deliveryType => _deliveryType;
  String? get accountType => _accountType;
  dynamic get paymentMode => _paymentMode;
  List<ClothData>? get clothData => _clothData;
  dynamic get clothWiseStatus => _clothWiseStatus;
  bool? get folded => _folded;
  bool? get hanger => _hanger;
  bool? get packing => _packing;
  String? get status => _status;
  dynamic get rackName => _rackName;
  dynamic get rackFloor => _rackFloor;
  dynamic get clothAndMechineId => _clothAndMechineId;
  num? get tenderCurrency => _tenderCurrency;
  num? get commission => _commission;
  String? get tenderDate => _tenderDate;
  dynamic get tenderTime => _tenderTime;
  String? get billReceiver => _billReceiver;
  bool? get pickupStatus => _pickupStatus;
  String? get nasha => _nasha;
  String? get orderReceiver => _orderReceiver;
  num? get wallet => _wallet;
  num? get vat => _vat;
  num? get vatValue => _vatValue;
  num? get openingBalance => _openingBalance;
  bool? get trash => _trash;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orderId'] = _orderId;
    map['refNo'] = _refNo;
    map['remarks'] = _remarks;
    if (_payment != null) {
      map['payment'] = _payment?.map((v) => v.toJson()).toList();
    }
    if (_editHistory != null) {
      map['edit_history'] = _editHistory?.map((v) => v.toJson()).toList();
    }
    if (_deliveryassgn != null) {
      map['deliveryassgn'] = _deliveryassgn?.map((v) => v.toJson()).toList();
    }
    map['orderDate'] = _orderDate;
    map['orderTime'] = _orderTime;
    map['deliveryDate'] = _deliveryDate;
    map['deliveryTime'] = _deliveryTime;
    map['deliveredDateTime'] = _deliveredDateTime;
    map['lastModifieddate'] = _lastModifieddate;
    map['lastModifiedTime'] = _lastModifiedTime;
    map['customerId'] = _customerId;
    map['customerCode'] = _customerCode;
    map['customerName'] = _customerName;
    map['customerPhno'] = _customerPhno;
    map['customerAddress'] = _customerAddress;
    map['customerStreet'] = _customerStreet;
    map['customerReffrNo'] = _customerReffrNo;
    map['customerHotel'] = _customerHotel;
    map['customerRoomNo'] = _customerRoomNo;
    map['villaAddress'] = _villaAddress;
    map['customerDiscount'] = _customerDiscount;
    map['cusfragrance'] = _cusfragrance;
    map['employeeId'] = _employeeId;
    map['employeeName'] = _employeeName;
    map['driverId'] = _driverId;
    map['driverName'] = _driverName;
    map['pickupDriverId'] = _pickupDriverId;
    map['pickupDriverName'] = _pickupDriverName;
    map['quantity'] = _quantity;
    map['subTotal'] = _subTotal;
    map['discount'] = _discount;
    map['totalAmount'] = _totalAmount;
    map['paidAmount'] = _paidAmount;
    map['balance'] = _balance;
    map['bill'] = _bill;
    map['deliveryType'] = _deliveryType;
    map['accountType'] = _accountType;
    map['paymentMode'] = _paymentMode;
    if (_clothData != null) {
      map['clothData'] = _clothData?.map((v) => v.toJson()).toList();
    }
    map['ClothWiseStatus'] = _clothWiseStatus;
    map['folded'] = _folded;
    map['hanger'] = _hanger;
    map['packing'] = _packing;
    map['status'] = _status;
    map['rackName'] = _rackName;
    map['rackFloor'] = _rackFloor;
    map['clothAndMechineId'] = _clothAndMechineId;
    map['tenderCurrency'] = _tenderCurrency;
    map['commission'] = _commission;
    map['tenderDate'] = _tenderDate;
    map['tenderTime'] = _tenderTime;
    map['billReceiver'] = _billReceiver;
    map['pickupStatus'] = _pickupStatus;
    map['nasha'] = _nasha;
    map['orderReceiver'] = _orderReceiver;
    map['wallet'] = _wallet;
    map['vat'] = _vat;
    map['vatValue'] = _vatValue;
    map['openingBalance'] = _openingBalance;
    map['trash'] = _trash;
    return map;
  }

}

/// qnty : 1
/// unit : "PCS"
/// billing : "Express"
/// priceId : 64
/// service : "DC"
/// clothImg : "https://apisyss.s3.ap-south-1.amazonaws.com/api/images/GUTRA_RED_01.jpg"
/// clothName : "GUTRA"
/// arabicName : "غترة"
/// clothPrice : "12.000"

class ClothData {
  ClothData({
    num? qnty,
    String? unit,
    String? billing,
    num? priceId,
    String? service,
    String? clothImg,
    String? clothName,
    String? arabicName,
    String? clothPrice,}){
    _qnty = qnty;
    _unit = unit;
    _billing = billing;
    _priceId = priceId;
    _service = service;
    _clothImg = clothImg;
    _clothName = clothName;
    _arabicName = arabicName;
    _clothPrice = clothPrice;
  }

  ClothData.fromJson(dynamic json) {
    _qnty = json['qnty'];
    _unit = json['unit'];
    _billing = json['billing'];
    _priceId = json['priceId'];
    _service = json['service'];
    _clothImg = json['clothImg'];
    _clothName = json['clothName'];
    _arabicName = json['arabicName'];
    _clothPrice = json['clothPrice'];
  }
  num? _qnty;
  String? _unit;
  String? _billing;
  num? _priceId;
  String? _service;
  String? _clothImg;
  String? _clothName;
  String? _arabicName;
  String? _clothPrice;
  ClothData copyWith({  num? qnty,
    String? unit,
    String? billing,
    num? priceId,
    String? service,
    String? clothImg,
    String? clothName,
    String? arabicName,
    String? clothPrice,
  }) => ClothData(  qnty: qnty ?? _qnty,
    unit: unit ?? _unit,
    billing: billing ?? _billing,
    priceId: priceId ?? _priceId,
    service: service ?? _service,
    clothImg: clothImg ?? _clothImg,
    clothName: clothName ?? _clothName,
    arabicName: arabicName ?? _arabicName,
    clothPrice: clothPrice ?? _clothPrice,
  );
  num? get qnty => _qnty;
  String? get unit => _unit;
  String? get billing => _billing;
  num? get priceId => _priceId;
  String? get service => _service;
  String? get clothImg => _clothImg;
  String? get clothName => _clothName;
  String? get arabicName => _arabicName;
  String? get clothPrice => _clothPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['qnty'] = _qnty;
    map['unit'] = _unit;
    map['billing'] = _billing;
    map['priceId'] = _priceId;
    map['service'] = _service;
    map['clothImg'] = _clothImg;
    map['clothName'] = _clothName;
    map['arabicName'] = _arabicName;
    map['clothPrice'] = _clothPrice;
    return map;
  }

}

/// deliveryassgnId : 52
/// deliveryDate : "2024-03-14"
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
/// trash : true
/// deliveryInvoiceNo : 24373

class Deliveryassgn {
  Deliveryassgn({
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
  Deliveryassgn copyWith({  num? deliveryassgnId,
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


class Pickup {
  Pickup({
    num? pickupassgnId,
    List<Pickupassgn>? pickupassgn,
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
        _pickupassgn?.add(Pickupassgn.fromJson(v));
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
  List<Pickupassgn>? _pickupassgn;
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
    List<Pickupassgn>? pickupassgn,
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
  List<Pickupassgn>? get pickupassgn => _pickupassgn;
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



class Pickupassgn {
  Pickupassgn({
    num? pickuporderId,
    dynamic paymentMode,
    String? pickuporderDate,
    String? pickuporderTime,
    num? quantity,
    num? subTotal,
    num? discount,
    num? totalAmount,
    num? paidAmount,
    num? balance,
    String? deliveryType,
    String? accountType,
    List<ClothData>? clothData,
    dynamic clothWiseStatus,
    String? status,
    dynamic tenderCurrency,
    dynamic tenderDate,
    dynamic tenderTime,
    dynamic billReceiver,
    bool? trash,
    num? pickupassgn,}){
    _pickuporderId = pickuporderId;
    _paymentMode = paymentMode;
    _pickuporderDate = pickuporderDate;
    _pickuporderTime = pickuporderTime;
    _quantity = quantity;
    _subTotal = subTotal;
    _discount = discount;
    _totalAmount = totalAmount;
    _paidAmount = paidAmount;
    _balance = balance;
    _deliveryType = deliveryType;
    _accountType = accountType;
    _clothData = clothData;
    _clothWiseStatus = clothWiseStatus;
    _status = status;
    _tenderCurrency = tenderCurrency;
    _tenderDate = tenderDate;
    _tenderTime = tenderTime;
    _billReceiver = billReceiver;
    _trash = trash;
    _pickupassgn = pickupassgn;
  }

  Pickupassgn.fromJson(dynamic json) {
    _pickuporderId = json['pickuporderId'];
    _paymentMode = json['paymentMode'];
    _pickuporderDate = json['pickuporderDate'];
    _pickuporderTime = json['pickuporderTime'];
    _quantity = json['quantity'];
    _subTotal = json['subTotal'];
    _discount = json['discount'];
    _totalAmount = json['totalAmount'];
    _paidAmount = json['paidAmount'];
    _balance = json['balance'];
    _deliveryType = json['deliveryType'];
    _accountType = json['accountType'];
    if (json['clothData'] != null) {
      _clothData = [];
      json['clothData'].forEach((v) {
        _clothData?.add(ClothData.fromJson(v));
      });
    }
    _clothWiseStatus = json['ClothWiseStatus'];
    _status = json['status'];
    _tenderCurrency = json['tenderCurrency'];
    _tenderDate = json['tenderDate'];
    _tenderTime = json['tenderTime'];
    _billReceiver = json['billReceiver'];
    _trash = json['trash'];
    _pickupassgn = json['pickupassgn'];
  }
  num? _pickuporderId;
  dynamic _paymentMode;
  String? _pickuporderDate;
  String? _pickuporderTime;
  num? _quantity;
  num? _subTotal;
  num? _discount;
  num? _totalAmount;
  num? _paidAmount;
  num? _balance;
  String? _deliveryType;
  String? _accountType;
  List<ClothData>? _clothData;
  dynamic _clothWiseStatus;
  String? _status;
  dynamic _tenderCurrency;
  dynamic _tenderDate;
  dynamic _tenderTime;
  dynamic _billReceiver;
  bool? _trash;
  num? _pickupassgn;
  Pickupassgn copyWith({  num? pickuporderId,
    dynamic paymentMode,
    String? pickuporderDate,
    String? pickuporderTime,
    num? quantity,
    num? subTotal,
    num? discount,
    num? totalAmount,
    num? paidAmount,
    num? balance,
    String? deliveryType,
    String? accountType,
    List<ClothData>? clothData,
    dynamic clothWiseStatus,
    String? status,
    dynamic tenderCurrency,
    dynamic tenderDate,
    dynamic tenderTime,
    dynamic billReceiver,
    bool? trash,
    num? pickupassgn,
  }) => Pickupassgn(  pickuporderId: pickuporderId ?? _pickuporderId,
    paymentMode: paymentMode ?? _paymentMode,
    pickuporderDate: pickuporderDate ?? _pickuporderDate,
    pickuporderTime: pickuporderTime ?? _pickuporderTime,
    quantity: quantity ?? _quantity,
    subTotal: subTotal ?? _subTotal,
    discount: discount ?? _discount,
    totalAmount: totalAmount ?? _totalAmount,
    paidAmount: paidAmount ?? _paidAmount,
    balance: balance ?? _balance,
    deliveryType: deliveryType ?? _deliveryType,
    accountType: accountType ?? _accountType,
    clothData: clothData ?? _clothData,
    clothWiseStatus: clothWiseStatus ?? _clothWiseStatus,
    status: status ?? _status,
    tenderCurrency: tenderCurrency ?? _tenderCurrency,
    tenderDate: tenderDate ?? _tenderDate,
    tenderTime: tenderTime ?? _tenderTime,
    billReceiver: billReceiver ?? _billReceiver,
    trash: trash ?? _trash,
    pickupassgn: pickupassgn ?? _pickupassgn,
  );
  num? get pickuporderId => _pickuporderId;
  dynamic get paymentMode => _paymentMode;
  String? get pickuporderDate => _pickuporderDate;
  String? get pickuporderTime => _pickuporderTime;
  num? get quantity => _quantity;
  num? get subTotal => _subTotal;
  num? get discount => _discount;
  num? get totalAmount => _totalAmount;
  num? get paidAmount => _paidAmount;
  num? get balance => _balance;
  String? get deliveryType => _deliveryType;
  String? get accountType => _accountType;
  List<ClothData>? get clothData => _clothData;
  dynamic get clothWiseStatus => _clothWiseStatus;
  String? get status => _status;
  dynamic get tenderCurrency => _tenderCurrency;
  dynamic get tenderDate => _tenderDate;
  dynamic get tenderTime => _tenderTime;
  dynamic get billReceiver => _billReceiver;
  bool? get trash => _trash;
  num? get pickupassgn => _pickupassgn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pickuporderId'] = _pickuporderId;
    map['paymentMode'] = _paymentMode;
    map['pickuporderDate'] = _pickuporderDate;
    map['pickuporderTime'] = _pickuporderTime;
    map['quantity'] = _quantity;
    map['subTotal'] = _subTotal;
    map['discount'] = _discount;
    map['totalAmount'] = _totalAmount;
    map['paidAmount'] = _paidAmount;
    map['balance'] = _balance;
    map['deliveryType'] = _deliveryType;
    map['accountType'] = _accountType;
    if (_clothData != null) {
      map['clothData'] = _clothData?.map((v) => v.toJson()).toList();
    }
    map['ClothWiseStatus'] = _clothWiseStatus;
    map['status'] = _status;
    map['tenderCurrency'] = _tenderCurrency;
    map['tenderDate'] = _tenderDate;
    map['tenderTime'] = _tenderTime;
    map['billReceiver'] = _billReceiver;
    map['trash'] = _trash;
    map['pickupassgn'] = _pickupassgn;
    return map;
  }

}