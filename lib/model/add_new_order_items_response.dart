// /// code : 200
// /// pickuporderTime : "11:30"
// /// quantity : 4
// /// subTotal : 27.0
// /// discount : 0.0
// /// totalAmount : 27.0
// /// paidAmount : 0.0
// /// balance : 27.0
// /// deliveryType : "PICKUP & DELIVERY"
// /// accountType : "WALKIN CASH"
// /// clothData : [{"priceId":106,"clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"10.000","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","qnty":1,"service":"DC","billing":"Express"},{"priceId":106,"clothName":"T-SHIRT","arabicName":"بلوزة","clothPrice":"5.000","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg","qnty":1,"service":"DC","billing":"Normal"},{"priceId":37,"clothName":"PILLOW COVER","arabicName":"تقية","clothPrice":"4.000","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/PILLOW_PROTECTOR.jpg","qnty":1,"service":"DC","billing":"Normal"},{"priceId":37,"clothName":"PILLOW COVER","arabicName":"تقية","clothPrice":"8.000","clothImg":"https://apisys.s3.me-south-1.amazonaws.com/api/images/PILLOW_PROTECTOR.jpg","qnty":1,"service":"DC","billing":"Express"}]
// /// ClothWiseStatus : null
// /// tenderCurrency : null
// /// tenderDate : null
// /// tenderTime : null
// /// billReceiver : null
// /// pickupassgn : null
//
// class AddNewOrderItemsResponse {
//   AddNewOrderItemsResponse({
//       num? code,
//       String? pickuporderTime,
//       num? quantity,
//       num? subTotal,
//       num? discount,
//       num? totalAmount,
//       num? paidAmount,
//       num? balance,
//       String? deliveryType,
//       String? accountType,
//       List<ClothData>? clothData,
//       dynamic clothWiseStatus,
//       dynamic tenderCurrency,
//       dynamic tenderDate,
//       dynamic tenderTime,
//       dynamic billReceiver,
//       dynamic pickupassgn,}){
//     _code = code;
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
//     _tenderCurrency = tenderCurrency;
//     _tenderDate = tenderDate;
//     _tenderTime = tenderTime;
//     _billReceiver = billReceiver;
//     _pickupassgn = pickupassgn;
// }
//
//   AddNewOrderItemsResponse.fromJson(dynamic json) {
//     _code = json['code'];
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
//     _tenderCurrency = json['tenderCurrency'];
//     _tenderDate = json['tenderDate'];
//     _tenderTime = json['tenderTime'];
//     _billReceiver = json['billReceiver'];
//     _pickupassgn = json['pickupassgn'];
//   }
//   num? _code;
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
//   dynamic _tenderCurrency;
//   dynamic _tenderDate;
//   dynamic _tenderTime;
//   dynamic _billReceiver;
//   dynamic _pickupassgn;
// AddNewOrderItemsResponse copyWith({  num? code,
//   String? pickuporderTime,
//   num? quantity,
//   num? subTotal,
//   num? discount,
//   num? totalAmount,
//   num? paidAmount,
//   num? balance,
//   String? deliveryType,
//   String? accountType,
//   List<ClothData>? clothData,
//   dynamic clothWiseStatus,
//   dynamic tenderCurrency,
//   dynamic tenderDate,
//   dynamic tenderTime,
//   dynamic billReceiver,
//   dynamic pickupassgn,
// }) => AddNewOrderItemsResponse(  code: code ?? _code,
//   pickuporderTime: pickuporderTime ?? _pickuporderTime,
//   quantity: quantity ?? _quantity,
//   subTotal: subTotal ?? _subTotal,
//   discount: discount ?? _discount,
//   totalAmount: totalAmount ?? _totalAmount,
//   paidAmount: paidAmount ?? _paidAmount,
//   balance: balance ?? _balance,
//   deliveryType: deliveryType ?? _deliveryType,
//   accountType: accountType ?? _accountType,
//   clothData: clothData ?? _clothData,
//   clothWiseStatus: clothWiseStatus ?? _clothWiseStatus,
//   tenderCurrency: tenderCurrency ?? _tenderCurrency,
//   tenderDate: tenderDate ?? _tenderDate,
//   tenderTime: tenderTime ?? _tenderTime,
//   billReceiver: billReceiver ?? _billReceiver,
//   pickupassgn: pickupassgn ?? _pickupassgn,
// );
//   num? get code => _code;
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
//   dynamic get tenderCurrency => _tenderCurrency;
//   dynamic get tenderDate => _tenderDate;
//   dynamic get tenderTime => _tenderTime;
//   dynamic get billReceiver => _billReceiver;
//   dynamic get pickupassgn => _pickupassgn;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['code'] = _code;
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
//     map['tenderCurrency'] = _tenderCurrency;
//     map['tenderDate'] = _tenderDate;
//     map['tenderTime'] = _tenderTime;
//     map['billReceiver'] = _billReceiver;
//     map['pickupassgn'] = _pickupassgn;
//     return map;
//   }
//
// }
//
// /// priceId : 106
// /// clothName : "T-SHIRT"
// /// arabicName : "بلوزة"
// /// clothPrice : "10.000"
// /// clothImg : "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg"
// /// qnty : 1
// /// service : "DC"
// /// billing : "Express"
//
// class ClothData {
//   ClothData({
//       num? priceId,
//       String? clothName,
//       String? arabicName,
//       String? clothPrice,
//       String? clothImg,
//       num? qnty,
//       String? service,
//       String? billing,}){
//     _priceId = priceId;
//     _clothName = clothName;
//     _arabicName = arabicName;
//     _clothPrice = clothPrice;
//     _clothImg = clothImg;
//     _qnty = qnty;
//     _service = service;
//     _billing = billing;
// }
//
//   ClothData.fromJson(dynamic json) {
//     _priceId = json['priceId'];
//     _clothName = json['clothName'];
//     _arabicName = json['arabicName'];
//     _clothPrice = json['clothPrice'];
//     _clothImg = json['clothImg'];
//     _qnty = json['qnty'];
//     _service = json['service'];
//     _billing = json['billing'];
//   }
//   num? _priceId;
//   String? _clothName;
//   String? _arabicName;
//   String? _clothPrice;
//   String? _clothImg;
//   num? _qnty;
//   String? _service;
//   String? _billing;
// ClothData copyWith({  num? priceId,
//   String? clothName,
//   String? arabicName,
//   String? clothPrice,
//   String? clothImg,
//   num? qnty,
//   String? service,
//   String? billing,
// }) => ClothData(  priceId: priceId ?? _priceId,
//   clothName: clothName ?? _clothName,
//   arabicName: arabicName ?? _arabicName,
//   clothPrice: clothPrice ?? _clothPrice,
//   clothImg: clothImg ?? _clothImg,
//   qnty: qnty ?? _qnty,
//   service: service ?? _service,
//   billing: billing ?? _billing,
// );
//   num? get priceId => _priceId;
//   String? get clothName => _clothName;
//   String? get arabicName => _arabicName;
//   String? get clothPrice => _clothPrice;
//   String? get clothImg => _clothImg;
//   num? get qnty => _qnty;
//   String? get service => _service;
//   String? get billing => _billing;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['priceId'] = _priceId;
//     map['clothName'] = _clothName;
//     map['arabicName'] = _arabicName;
//     map['clothPrice'] = _clothPrice;
//     map['clothImg'] = _clothImg;
//     map['qnty'] = _qnty;
//     map['service'] = _service;
//     map['billing'] = _billing;
//     return map;
//   }
//
// }