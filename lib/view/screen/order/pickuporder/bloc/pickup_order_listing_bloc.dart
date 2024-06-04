import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../model/PickupOrderListingResponse.dart';
import '../../../../../service/api_service.dart';

part 'pickup_order_listing_event.dart';
part 'pickup_order_listing_state.dart';

class PickupOrderListingBloc extends Bloc<PickupOrderListingEvent, PickupOrderListingState> {
  final ApiService _apiService;
  PickupOrderListingBloc(this._apiService) : super(PickupOrderListingInitial()) {
    on<PickupOrderListingApiEvent>((event, emit) async{
      emit(LoadingState());
      try {
        final response = await _apiService.getPickupOrderList(event.userToken,event.companyCode,event.userID);

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