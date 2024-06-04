part of 'history_bloc.dart';

@immutable

abstract class HistoryEvent extends  Equatable{
  const HistoryEvent();


}
class HistoryApiEvent extends  HistoryEvent {
  final String userToken;
  final String companyCode;
  final String userID;

  const HistoryApiEvent(this.userToken, this.companyCode, this.userID);

  @override
  List<Object?> get props => [userToken,companyCode,userID];
}