import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_bloc.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/dto/cart_dto.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/dto/product_dto.dart';
import 'package:flutter_app_sale_06072022/data/model/cart.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/order_history/order_history_event.dart';

class OrderHistoryBloc extends BaseBloc {
  StreamController<List<Cart>> orderHistoryController = StreamController();

  late ProductRepository _repository;

  void updateProductRepository(ProductRepository productRepository) {
    this._repository = productRepository;
  }

  @override
  void dispatch(BaseEvent event) {
    switch (event.runtimeType) {
      case GetOrderHistoryEvent:
        _getOrderHistory();
        break;
    }
  }

  void _getOrderHistory() async {
    loadingSink.add(true);
    try {
      Response response = await _repository.getOrderHistory();

      List<CartDto> orderHistoryDto =
          response.data["data"].map<CartDto>((item) {
        CartDto cartDto = CartDto.fromJson(item);
        return cartDto;
      }).toList();

      List<Cart> listCart = orderHistoryDto.map((e) {
        List<Product> listProducts = e.products!.map((product) {
          return Product(product.id, product.name, product.address,
              product.price, product.img, product.quantity, product.gallery);
        }).toList();
        num price = 0;
        if (e.products != null) {
          for (var i = 0; i < e.products!.length; i++) {
            ProductDto product = e.products![i];
            num product_price = product.price ?? 0;
            num quantity = product.quantity ?? 0;
            price = price + product_price * quantity;
          }
        }
        return Cart(e.id, listProducts, e.idUser, price, e.date_created);
      }).toList();
      orderHistoryController.sink.add(listCart);
    } on DioError catch (e) {
      messageSink.add(e.response?.data["message"]);
    } catch (e) {
      // print(e.toString());
      messageSink.add(e.toString());
    }
    loadingSink.add(false);
  }
}
