import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/common/utils/extension.dart';
import 'package:flutter_app_sale_06072022/common/widgets/loading_widget.dart';
import 'package:flutter_app_sale_06072022/data/datasources/remote/api_request.dart';
import 'package:flutter_app_sale_06072022/data/model/cart.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_page.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_event.dart';
import 'package:flutter_app_sale_06072022/presentation/features/order_history/order_history_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/order_history/order_history_event.dart';
import 'package:flutter_app_sale_06072022/presentation/features/order_history_detail/order_history_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
        child: OrderHistoryContainer(),
        providers: [
          Provider(create: (context) => ApiRequest()),
          ProxyProvider<ApiRequest, ProductRepository>(
              update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? ProductRepository()
              ..updateRequest(request);
          }),
          ProxyProvider<ProductRepository, OrderHistoryBloc>(
              update: (context, repository, bloc) {
            bloc?.updateProductRepository(repository);
            return bloc ?? OrderHistoryBloc()
              ..updateProductRepository(repository);
          }),
          ProxyProvider<ProductRepository, HomeBloc>(
            update: (context, repository, bloc) {
              bloc?.updateProductRepository(repository);
              return bloc ?? HomeBloc()
                ..updateProductRepository(repository);
            },
          ),
        ],
        appBar: AppBar(
          title: const Text("Lịch sử đặt hàng"),
          actions: [
            Consumer<HomeBloc>(
              builder: (context, bloc, child) {
                return StreamBuilder<Cart>(
                    initialData: null,
                    stream: bloc.cartController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.data?.products.isEmpty == true) {
                        return Container();
                      }
                      num count = 0;
                      for (var element in snapshot.data!.products) {
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            child: Icon(Icons.shopping_cart_outlined),
                          ),
                          onTap: () {
                            // Navigator.pushNamed(
                            //     context, VariableConstant.CART_ROUTE);
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CartPage(),
                                        settings: RouteSettings(
                                            arguments: snapshot.data)))
                                .then((value) {
                              bloc.eventSink.add(GetCartEvent());
                            });
                          },
                        ),
                      );
                    });
              },
            )
          ],
        ));
  }
}

class OrderHistoryContainer extends StatefulWidget {
  const OrderHistoryContainer({Key? key}) : super(key: key);

  @override
  State<OrderHistoryContainer> createState() => _OrderHistoryContainerState();
}

class _OrderHistoryContainerState extends State<OrderHistoryContainer> {
  late OrderHistoryBloc _orderHistoryBloc;
  late HomeBloc _homeBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _orderHistoryBloc = context.read<OrderHistoryBloc>();
    _orderHistoryBloc.eventSink.add(GetOrderHistoryEvent());
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.eventSink.add(GetCartEvent());

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _orderHistoryBloc.messageStream.listen((event) {
        showMessage(context, "Thông báo", event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(children: [
      StreamBuilder<List<Cart>?>(
          initialData: const [],
          stream: _orderHistoryBloc.orderHistoryController.stream,
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                child: Center(child: Text("Data error")),
              );
            }
            if (snapshot.hasData && snapshot.data?.length == 0) {
              return Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset('assets/images/empty_cart.png'),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Chưa có lịch sử đơn hàng",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))))),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  return _renderOrderHistoryItem(
                      snapshot.data?[index], context);
                });
          })),
      LoadingWidget(
        bloc: _orderHistoryBloc,
        child: Container(),
      )
    ]));
  }
}

Widget _renderOrderHistoryItem(Cart? cart, BuildContext context) {
  if (cart == null) return Container();
  return SizedBox(
    height: 90,
    child: Card(
      elevation: 5,
      shadowColor: Colors.blueGrey,
      child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    convertServerTimeToString(cart.date_created),
                    style: TextStyle(
                        color: Color.fromARGB(200, 240, 102, 61),
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                      "Sum Price: ${NumberFormat("#,###", "en_US").format(cart.price)}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderHistoryDetailPage(),
                          settings: RouteSettings(arguments: cart)));
                },
                child: const Text("Chi tiết"),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))))),
              )
            ],
          )),
    ),
  );
}
