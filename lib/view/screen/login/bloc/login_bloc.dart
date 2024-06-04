import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../model/login_response.dart';
import '../../../../service/api_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiService _apiService;
  LoginBloc(this._apiService) : super(LoginInitial()) {
    on<LoginApiEvent>((event, emit)async {
      final response = await _apiService.getLogin(
        event.username.toString(),
        event.password.toString(),
        event.companycode.toString(),
        // event.deviceId.toString(),
      );
      if (response.code==401) {
        emit(
          UnAuthorizedState(),
        );
      } else if (response.code == 500) {
        emit(
          ErrorState(),
        );
      } else if (response.code == 503) {
        emit(
          NoInternetState(),
        );
      } else {
        emit(
            LoginSuccessState(response));
      }

    });
  }
}
