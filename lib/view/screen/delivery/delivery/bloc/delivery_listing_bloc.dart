import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../model/delivery_listing_response.dart';
import '../../../../../service/api_service.dart';

part 'delivery_listing_event.dart';
part 'delivery_listing_state.dart';

class DeliveryListingBloc extends Bloc<DeliveryListingEvent, DeliveryListingState> {
  final ApiService _apiService;
  DeliveryListingBloc(this._apiService) : super(DeliveryListingInitial()) {
    on<DeliveryListingApiEvent>((event, emit) async{
      emit(LoadingState());
      try {
        final response = await _apiService.getDeliveryList(event.userToken,event.companyCode,event.userID);

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
