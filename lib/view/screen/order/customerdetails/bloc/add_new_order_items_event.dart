// part of 'add_new_order_items_bloc.dart';
//
// @immutable
// abstract class AddNewOrderItemsEvent extends Equatable {
//   const AddNewOrderItemsEvent();
// }
// class AddNewOrderItemsApiEvent extends  AddNewOrderItemsEvent{
//
//   final String itemId;
//   final String name;
//   final String descriptions;
//   final String mrp;
//   final String cost;
//   final String stockStatus;
//   final String categoryId;
//   final File productImage;
//   final String tokenId;
//
//
//
//   const AddNewOrderItemsApiEvent({
//     required this.itemId,
//     required this.name,
//     required this.descriptions,
//     required this.mrp,
//     required this.cost,
//     required this.stockStatus,
//     required this.categoryId,
//     required this.productImage,
//     required this.tokenId,
//
//   });
//   @override
//   List<Object?> get props => [itemId,name,descriptions,mrp,cost,stockStatus,categoryId,productImage,tokenId];
//
// }