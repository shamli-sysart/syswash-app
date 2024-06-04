part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {
  List<Object> get props => [];
}
class ErrorState extends LoginState{
  ErrorState();
  List<Object> get props => [];
}

class UnAuthorizedState extends LoginState {
  UnAuthorizedState();

  List<Object?> get props => [];
}
class NoInternetState extends LoginState {
  NoInternetState();

  List<Object?> get props => [];
}

class LoginLoadingState extends LoginState {
  List<Object> get props => [];
}


class LoginSuccessState extends LoginState {
  final LoginResponse response;

  LoginSuccessState(this.response);


  List<Object> get props => [response];
}


