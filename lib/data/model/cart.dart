import 'package:flutter_app_sale_06072022/data/model/product.dart';

class Cart {
  late String id;
  late List<Product> products;
  late String idUser;
  late num price;
  late String date_created;

  Cart(
      [String? id,
      List<Product>? products,
      String? idUser,
      num? price,
      String? date_created]) {
    this.id = id ?? "";
    this.products = products ?? [];
    this.idUser = idUser ?? "";
    this.price = price ?? 0;
    this.date_created = date_created ?? "";
  }
}
