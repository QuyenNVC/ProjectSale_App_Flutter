import 'package:flutter_app_sale_06072022/data/datasources/remote/dto/product_dto.dart';

class CartDto {
  CartDto({this.id, this.products, this.idUser, this.price, this.date_created});

  CartDto.fromJson(dynamic json) {
    id = json['_id'];
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products?.add(ProductDto.fromJson(v));
      });
    }
    idUser = json['id_user'];
    price = json['price'];
    date_created = json['date_created'];
  }

  String? id;
  List<ProductDto>? products;
  String? idUser;
  num? price;
  String? date_created;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    if (products != null) {
      map['products'] = products?.map((v) => v.toJson()).toList();
    }
    map['id_user'] = idUser;
    map['price'] = price;
    map['date_created'] = date_created;
    return map;
  }

  static CartDto convertJson(dynamic json) => CartDto.fromJson(json);

  @override
  String toString() {
    // TODO: implement toString
    return "id: " +
        this.id.toString() +
        ", created_at: " +
        this.date_created.toString();
  }
}
