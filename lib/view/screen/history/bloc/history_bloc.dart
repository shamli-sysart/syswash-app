import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


import '../../../../model/history_response.dart';
import '../../../../service/api_service.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ApiService _apiService;
  HistoryBloc(this._apiService) : super(HistoryInitial()) {
    on<HistoryApiEvent>((event, emit)async{
      emit(LoadingState());
      try {

        final response = await _apiService.getHistory(event.userToken,event.companyCode,event.userID);

        if (response.code == 401) {
          emit(UnAuthorizedState());
        } else if (response.code == 500) {
          emit(ErrorState());
        } else if (response.code == 503) {
          emit(NoInternetState());
        } else {
          emit(LoadedState(response));
        }
      } catch (e) {
        // Handle errors here
      }

    });
  }
}