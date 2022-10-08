import 'package:flutter_app_sale_06072022/common/bases/base_repository.dart';

class ProductRepository extends BaseRepository {
  Future getListProducts() {
    return apiRequest.getProducts();
  }

  Future getCart() {
    return apiRequest.getCart();
  }

  Future addCart(String idProduct) {
    return apiRequest.addCart(idProduct);
  }

  Future updateCart(String idProduct, String idCart, num quantity) {
    return apiRequest.updateCart(idProduct, idCart, quantity);
  }

  Future confirmCart(String idCart) {
    return apiRequest.confirmCart(idCart);
  }

  Future getOrderHistory() {
    return apiRequest.getOrderHistory();
  }
}
