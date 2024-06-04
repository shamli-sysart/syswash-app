part of 'pickup_order_listing_bloc.dart';

@immutable
abstract class PickupOrderListingEvent extends  Equatable{
  const PickupOrderListingEvent();

}
class PickupOrderListingApiEvent extends  PickupOrderListingEvent {
  final String userToken;
  final String companyCode;
  final String userID;

  const PickupOrderListingApiEvent(this.userToken, this.companyCode, this.userID);

  @override
  List<Object?> get props => [userToken,companyCode,userID];
}