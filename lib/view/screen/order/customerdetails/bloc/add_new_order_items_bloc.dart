// import 'dart:async';
// import 'dart:html';
//
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
//
// import '../../../../../model/add_new_order_items_response.dart';
// import '../../../../../service/api_service.dart';
//
// part 'add_new_order_items_event.dart';
// part 'add_new_order_items_state.dart';
//
// class AddNewOrderItemsBloc extends Bloc<AddNewOrderItemsEvent, AddNewOrderItemsState> {
//   final ApiService _apiService;
//   AddNewOrderItemsBloc(this._apiService) : super(AddNewOrderItemsInitial()) {
//     on<AddNewOrderItemsApiEvent>((event, emit) async{
//       emit(LoadingState());
//       final response = await _apiService.AddNewOrder(
//
//         event.itemId.toString(),
//         event.name.toString(),
//         event.descriptions.toString(),
//         event.mrp.toString(),
//         event.cost.toString(),
//         event.stockStatus.toString(),
//         event.categoryId.toString(),
//         event.productImage,
//         event.tokenId.toString(),
//       );
//       if (response.code==401) {
//         emit(
//           UnAuthorizedState(),
//         );
//       } else if (response.code == 500) {
//         emit(
//           ErrorState(),
//         );
//       } else if (response.code == 503) {
//         emit(NoInternetState());
//
//       } else {
//         emit(
//             LoadedState(response));
//       }
//
//     });
//   }
// }
