import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../model/pickup_customer_response.dart';
import '../../../../../service/api_service.dart';

part 'customer_details_event.dart';
part 'customer_details_state.dart';

class CustomerDetailsBloc
    extends Bloc<CustomerDetailsEvent, CustomerDetailsState> {
  final ApiService _apiService;
  CustomerDetailsBloc(this._apiService) : super(CustomerDetailsInitial()) {
    on<CustomerDetailsApiEvent>((event, emit) async {
      emit(LoadingState());
      final response = await _apiService.getPickupCustomerDetails(
          event.userToken, event.companyCode, event.pickupassgnId);
      if (response.code == 401) {
        emit(
          UnAuthorizedState(),
        );
      } else if (response.code == 500) {
        emit(
          ErrorState(),
        );
      } else if (response.code == 503) {
        emit(NoInternetState());
      } else {
        emit(LoadedState(response));
      }
    });
  }
}
