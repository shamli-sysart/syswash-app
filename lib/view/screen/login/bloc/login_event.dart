part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {

}
class LoginApiEvent extends LoginEvent {
  final String username;
  final String password;
  final String companycode;
  // final String deviceId;

  LoginApiEvent({
    required this.username,
    required this.password,
    required this.companycode,
    // required this.deviceId,
  });

  List<Object?> get props => [username, password,companycode];
  // List<Object?> get props => [username, password, tokenId, deviceId];

}

