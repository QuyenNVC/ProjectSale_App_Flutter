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
