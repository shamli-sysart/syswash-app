part of 'pickup_order_listing_bloc.dart';

@immutable
abstract class PickupOrderListingState {}

class PickupOrderListingInitial extends PickupOrderListingState {
  List<Object> get props => [];
}

class ErrorState extends  PickupOrderListingState {
  ErrorState();

  List<Object> get props => [];
}

class UnAuthorizedState extends  PickupOrderListingState {
  UnAuthorizedState();

  List<Object?> get props => [];
}

class NoInternetState extends PickupOrderListingState {
  NoInternetState();

  List<Object?> get props => [];
}

class LoadingState extends  PickupOrderListingState {
  List<Object> get props => [];
}


class LoadedState extends  PickupOrderListingState {
  final PickupOrderListingResponse response;
  LoadedState(this. response);



  List<Object> get props => [response];
}