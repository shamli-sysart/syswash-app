part of 'customer_details_bloc.dart';

@immutable
abstract class CustomerDetailsState {}

class CustomerDetailsInitial extends CustomerDetailsState {
  List<Object> get props => [];
}
class ErrorState extends CustomerDetailsState {
  ErrorState();

  List<Object> get props => [];
}

class UnAuthorizedState extends CustomerDetailsState {
  UnAuthorizedState();

  List<Object?> get props => [];
}

class NoInternetState extends CustomerDetailsState {

  List<Object?> get props => [];
}

class LoadingState extends  CustomerDetailsState {
  List<Object> get props => [];
}


class LoadedState extends  CustomerDetailsState{
  final PickupCustomerResponse response;
  LoadedState(this.response);
  @override
  List<Object> get props => [response];
}