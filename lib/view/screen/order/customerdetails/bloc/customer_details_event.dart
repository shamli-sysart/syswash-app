part of 'customer_details_bloc.dart';

@immutable
abstract class CustomerDetailsEvent extends Equatable{
  const CustomerDetailsEvent();
}
class CustomerDetailsApiEvent extends CustomerDetailsEvent{

  final String userToken;
  final String companyCode;
  final String pickupassgnId;




  const CustomerDetailsApiEvent(this.userToken,this.companyCode,this.pickupassgnId);

  @override
  List<Object?> get props => [];

}