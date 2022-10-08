// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';

class UpdateCartEvent extends BaseEvent {
  String idProduct;
  num quantity;
  String idCart;
  UpdateCartEvent(
      {required this.idProduct, required this.quantity, required this.idCart});
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ConfirmCartEvent extends BaseEvent {
  String idCart;
  ConfirmCartEvent({
    required this.idCart,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ConfirmCartSuccessEvent extends BaseEvent {
  String message;

  ConfirmCartSuccessEvent({
    required this.message,
  });

  @override
  List<Object?> get props => [];
}
