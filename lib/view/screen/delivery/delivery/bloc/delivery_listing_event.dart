part of 'delivery_listing_bloc.dart';

@immutable
abstract class DeliveryListingEvent extends  Equatable{
  const DeliveryListingEvent();

}
class DeliveryListingApiEvent extends  DeliveryListingEvent {
  final String userToken;
  final String companyCode;
  final String userID;

  const DeliveryListingApiEvent(this.userToken, this.companyCode, this.userID);

  @override
  List<Object?> get props => [userToken,companyCode,userID];
}