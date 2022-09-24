// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';

class GetListProductEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class GetCartEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class AddCartEvent extends BaseEvent {
  String idProduct;
  AddCartEvent({
    required this.idProduct,
  });

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
