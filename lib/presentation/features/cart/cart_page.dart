import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/common/constants/api_constant.dart';
import 'package:flutter_app_sale_06072022/common/constants/variable_constant.dart';
import 'package:flutter_app_sale_06072022/common/widgets/loading_widget.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/api_request.dart';
import 'package:flutter_app_sale_06072022/data/model/cart.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_event.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_event.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Giỏ hàng"),
        actions: [
          Consumer<CartBloc>(
            builder: ((context, bloc, child) {
              return StreamBuilder(
                initialData: null,
                stream: bloc.cartController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError || snapshot.data == null) {
                    return Container();
                  }
                  Cart cart = snapshot.data as Cart;
                  num count = 0;
                  for (var element in cart.products) {
                    count = count + element.quantity;
                  }
                  return Container(
                    margin: EdgeInsets.only(right: 20, top: 10),
                    child: InkWell(
                      child: Badge(
                        badgeContent: Text(
                          count.toString(),
                          // "0",
                          style: const TextStyle(color: Colors.white),
                        ),
                        child: Icon(Icons.shopping_cart_outlined),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? ProductRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<ProductRepository, CartBloc>(
          update: (context, repository, bloc) {
            bloc?.updateProductRepository(repository);
            bloc = bloc ?? CartBloc()
              ..updateProductRepository(repository);
            return bloc;
          },
        ),
      ],
      child: CartContainer(),
    );
  }
}

class CartContainer extends StatefulWidget {
  const CartContainer({Key? key}) : super(key: key);

  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  late CartBloc _cartBloc;
  // @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cartBloc = context.read<CartBloc>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Cart cart = ModalRoute.of(context)!.settings.arguments as Cart;
      _cartBloc.cartController.sink.add(cart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Stack(children: [
          StreamBuilder<Cart>(
            initialData: null,
            stream: _cartBloc.cartController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  child: Center(child: Text("Data error")),
                );
              }
              List<Product>? products = snapshot.data?.products ?? [];
              // print(snapshot.data);
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _renderItem(
                      products[index], snapshot.data?.id.toString());
                },
              );
            },
          ),
          LoadingWidget(
            bloc: _cartBloc,
            child: Container(),
          )
        ]),
      ),
    );
  }

  void updateCart(String idProduct, int quantity, String idCart) {
    _cartBloc.eventSink.add(UpdateCartEvent(
        idProduct: idProduct, quantity: quantity, idCart: idCart));
  }

  Widget _renderItem(Product product, String? idCart) {
    if (product == null) return Container();
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(product.name.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16)),
                      ),
                      Text(
                          "Giá : ${NumberFormat("#,###", "en_US").format(product.price)} đ",
                          style: const TextStyle(fontSize: 12)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // addCart(product.id);
                                if (idCart != null) {
                                  updateCart(product.id,
                                      (product.quantity - 1).toInt(), idCart);
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          200, 240, 102, 61);
                                    } else {
                                      return const Color.fromARGB(
                                          230, 240, 102, 61);
                                    }
                                  }),
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))))),
                              child: const Text("-",
                                  style: TextStyle(fontSize: 14)),
                            ),
                            Text(product.quantity.toString()),
                            ElevatedButton(
                              onPressed: () {
                                if (idCart != null) {
                                  updateCart(product.id,
                                      (product.quantity + 1).toInt(), idCart);
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          200, 240, 102, 61);
                                    } else {
                                      return const Color.fromARGB(
                                          230, 240, 102, 61);
                                    }
                                  }),
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))))),
                              child: const Text("+",
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
