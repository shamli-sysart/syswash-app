/// code : 200
/// email : "shamli@syswash.com"
/// id : 8
/// username : "Shamli"
/// userType : "Driver"
/// access : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzEwNjI1ODI2LCJpYXQiOjE3MTA1ODI2MjYsImp0aSI6IjQxN2IzNzQzNjYwYjRlYTI5OWMyMTZiN2U5ZjY3MjBjIiwidXNlcl9pZCI6OH0.IZAiGaCQ7uvVfNbGimvuMbY1C1C2v9X6N1K_MJqucFQ"
/// refresh : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDY2OTAyNiwiaWF0IjoxNzEwNTgyNjI2LCJqdGkiOiI5ZDRjNTYwNzNiZmE0MDIxOWYwOWM4NWYxNTI0YWZkNiIsInVzZXJfaWQiOjh9._kJxn6NgsLB260YYKYTpkcYPwWU_Z8en4DbIeprdqrA"

class LoginResponse {
  LoginResponse({
      num? code, 
      String? email, 
      num? id, 
      String? username, 
      String? userType, 
      String? access, 
      String? refresh,}){
    _code = code;
    _email = email;
    _id = id;
    _username = username;
    _userType = userType;
    _access = access;
    _refresh = refresh;
}

  LoginResponse.fromJson(dynamic json) {
    _code = json['code'];
    _email = json['email'];
    _id = json['id'];
    _username = json['username'];
    _userType = json['userType'];
    _access = json['access'];
    _refresh = json['refresh'];
  }
  num? _code;
  String? _email;
  num? _id;
  String? _username;
  String? _userType;
  String? _access;
  String? _refresh;
LoginResponse copyWith({  num? code,
  String? email,
  num? id,
  String? username,
  String? userType,
  String? access,
  String? refresh,
}) => LoginResponse(  code: code ?? _code,
  email: email ?? _email,
  id: id ?? _id,
  username: username ?? _username,
  userType: userType ?? _userType,
  access: access ?? _access,
  refresh: refresh ?? _refresh,
);
  num? get code => _code;
  String? get email => _email;
  num? get id => _id;
  String? get username => _username;
  String? get userType => _userType;
  String? get access => _access;
  String? get refresh => _refresh;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['email'] = _email;
    map['id'] = _id;
    map['username'] = _username;
    map['userType'] = _userType;
    map['access'] = _access;
    map['refresh'] = _refresh;
    return map;
  }

}