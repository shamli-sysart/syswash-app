part of 'delivery_listing_bloc.dart';

@immutable
abstract class DeliveryListingState {}

class DeliveryListingInitial extends DeliveryListingState {
  List<Object> get props => [];
}
class ErrorState extends  DeliveryListingState {
  ErrorState();

  List<Object> get props => [];
}

class UnAuthorizedState extends  DeliveryListingState {
  UnAuthorizedState();

  List<Object?> get props => [];
}

class NoInternetState extends DeliveryListingState {
  NoInternetState();

  List<Object?> get props => [];
}

class LoadingState extends  DeliveryListingState {
  List<Object> get props => [];
}


class LoadedState extends  DeliveryListingState {
  final DeliveryListingResponse response;
  LoadedState(this. response);



  List<Object> get props => [response];
}