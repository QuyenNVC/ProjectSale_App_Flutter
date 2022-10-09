import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/common/constants/api_constant.dart';
import 'package:flutter_app_sale_06072022/common/constants/variable_constant.dart';
import 'package:flutter_app_sale_06072022/common/utils/extension.dart';
import 'package:flutter_app_sale_06072022/common/widgets/loading_widget.dart';
import 'package:flutter_app_sale_06072022/common/widgets/progress_listener_widget.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/api_request.dart';
import 'package:flutter_app_sale_06072022/data/model/cart.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_event.dart';
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
                  if (count == 0) {
                    return Container();
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
      _cartBloc.messageStream.listen((event) {
        showMessage(context, "Thông báo", event);
      });
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
              if (products.length == 0) {
                return Expanded(
                  child: Column(
                    children: [
                      Center(
                        child: Image.asset('assets/images/empty_cart.png'),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Giỏ hàng trống",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, VariableConstant.HOME_ROUTE);
                        },
                        child: const Text("Quay lại"),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color.fromARGB(200, 240, 102, 61);
                              } else {
                                return const Color.fromARGB(230, 240, 102, 61);
                              }
                            }),
                            shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20))))),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                );
              }
              num sumPrice = products.fold(0, (sum, e) {
                sum = sum + e.price * e.quantity;
                return sum;
              });

              return CustomScrollView(
                slivers: <Widget>[
                  _getSlivers(products, snapshot.data?.id.toString(), context),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Thành tiền: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${NumberFormat("#,###", "en_US").format(sumPrice)} đ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text(
                                        "Đặt hàng?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red),
                                      ),
                                      content: Text(
                                          "Quý khách sẽ thanh toán ${NumberFormat("#,###", "en_US").format(sumPrice)} đồng cho các món ăn trên"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              "Hủy",
                                              style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 16),
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              confirmCart(
                                                  snapshot.data!.id.toString());
                                              Navigator.pop(context);
                                            },
                                            child: Text("Thanh toán",
                                                style: TextStyle(
                                                    color: Colors.red[400],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))),
                                      ],
                                    );
                                  });
                            },
                            child: Text(
                              "Thanh toán",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 255, 0, 0),
                              minimumSize: const Size.fromHeight(50),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          ProgressListenerWidget<CartBloc>(
            callback: (event) {
              print(event.toString());
              if (event is ConfirmCartSuccessEvent) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(event.message)));
                // Navigator.pop(context);
                Navigator.popAndPushNamed(context, VariableConstant.HOME_ROUTE);
              }
            },
            child: Container(),
          ),
          LoadingWidget(
            bloc: _cartBloc,
            child: Container(),
          )
        ]),
      ),
    );
  }

  SliverList _getSlivers(List products, String? idCart, BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _renderItem(products[index], idCart);
        },
        childCount: products.length,
      ),
    );
  }

  void updateCart(String idProduct, int quantity, String idCart) {
    _cartBloc.eventSink.add(UpdateCartEvent(
        idProduct: idProduct, quantity: quantity, idCart: idCart));
  }

  void confirmCart(String idCart) {
    _cartBloc.eventSink.add(ConfirmCartEvent(idCart: idCart));
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
