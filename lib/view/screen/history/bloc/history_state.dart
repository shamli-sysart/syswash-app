part of 'history_bloc.dart';

@immutable
abstract class HistoryState {}

class HistoryInitial extends HistoryState {
  List<Object> get props => [];
}


class ErrorState extends  HistoryState {
  ErrorState();

  List<Object> get props => [];
}

class UnAuthorizedState extends  HistoryState {
  UnAuthorizedState();

  List<Object?> get props => [];
}

class NoInternetState extends HistoryState {
  NoInternetState();

  List<Object?> get props => [];
}

class LoadingState extends  HistoryState {
  List<Object> get props => [];
}


class LoadedState extends  HistoryState {
  final HistoryResponse response;
  LoadedState(this. response);



  List<Object> get props => [response];
}