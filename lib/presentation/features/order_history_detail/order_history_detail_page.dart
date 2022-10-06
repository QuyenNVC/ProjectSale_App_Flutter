import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/common/constants/api_constant.dart';
import 'package:flutter_app_sale_06072022/common/constants/style_constant.dart';
import 'package:flutter_app_sale_06072022/data/model/cart.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:intl/intl.dart';

class OrderHistoryDetailPage extends StatefulWidget {
  const OrderHistoryDetailPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryDetailPage> createState() => _OrderHistoryDetailPageState();
}

class _OrderHistoryDetailPageState extends State<OrderHistoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
      ),
      providers: [],
      child: OrderHistoryDetailContainer(),
    );
  }
}

class OrderHistoryDetailContainer extends StatefulWidget {
  const OrderHistoryDetailContainer({Key? key}) : super(key: key);

  @override
  State<OrderHistoryDetailContainer> createState() =>
      _OrderHistoryDetailContainerState();
}

class _OrderHistoryDetailContainerState
    extends State<OrderHistoryDetailContainer> {
  @override
  Widget build(BuildContext context) {
    Cart? cart = ModalRoute.of(context)!.settings.arguments as Cart;
    List<Product> products = cart.products;
    return SafeArea(
        child: Container(
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          Product product = products[index];
          return SizedBox(
            height: 135,
            child: Card(
              elevation: 5,
              shadowColor: Colors.blueGrey,
              child: Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(ApiConstant.BASE_URL + product.img,
                          width: 150, height: 120, fit: BoxFit.fill),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 5, 8),
                              child: Text(product.name.toString(),
                                  // maxLines: 1,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: StyleConstant.TITLE_COLOR)),
                            ),
                            Text(
                                "Giá : ${NumberFormat("#,###", "en_US").format(product.price)} đ",
                                style: const TextStyle(fontSize: 16)),
                            Text("Số lượng: " + product.quantity.toString())
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ));
  }
}
