import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/common/bases/route_helper.dart';
import 'package:flutter_app_sale_06072022/common/constants/variable_constant.dart';
import 'package:flutter_app_sale_06072022/data/datasources/local/cache/app_cache.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_page.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/home/home_event.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/api_constant.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Home"),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            AppCache.setString(key: 'token', value: '');
            Navigator.pushReplacementNamed(
                context, VariableConstant.SIGN_IN_ROUTE);
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10, top: 10),
            child: InkWell(
              child: Icon(Icons.history_outlined),
              onTap: () {
                Navigator.pushNamed(
                    context, VariableConstant.ORDER_HISTORY_ROUTE);
              },
            ),
          ),
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
                    // int count = snapshot.data?.products.length ?? 0;
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
        ProxyProvider<ProductRepository, HomeBloc>(
          update: (context, repository, bloc) {
            bloc?.updateProductRepository(repository);
            return bloc ?? HomeBloc()
              ..updateProductRepository(repository);
          },
        ),
      ],
      child: HomeContainer(),
    );
  }
}

class HomeContainer extends StatefulWidget {
  const HomeContainer({Key? key}) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.eventSink.add(GetListProductEvent());
    _homeBloc.eventSink.add(GetCartEvent());
  }

  void addCart(String idProduct) {
    _homeBloc.eventSink.add(AddCartEvent(idProduct: idProduct));
  }

  void showProductDialog(Product product, BuildContext context) {
    if (context == null) return;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "H???y",
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    )),
                TextButton(
                    onPressed: () {
                      addCart(product.id);
                      Navigator.pop(context);
                    },
                    child: Text("Mua",
                        style: TextStyle(
                            color: Colors.green[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 16))),
              ],
              title: Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              content: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Gi?? : ${NumberFormat("#,###", "en_US").format(product.price)} ??",
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                    ),
                    CarouselSlider(
                      items: product.gallery
                          .map((e) => Container(
                                child: Center(
                                    child: Image.network(
                                  "https://serverappsale.herokuapp.com/" + e,
                                  fit: BoxFit.cover,
                                  width: 1000,
                                )),
                              ))
                          .toList(),
                      options: CarouselOptions(
                        // height: 400,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
                width: double.maxFinite,
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Stack(
        children: [
          StreamBuilder<List<Product>>(
              initialData: const [],
              stream: _homeBloc.listProductController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    child: Center(child: Text("Data error")),
                  );
                }
                if (snapshot.hasData && snapshot.data == []) {
                  return Container();
                }
                return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _buildItemFood(snapshot.data?[index]);
                    });
              }),
          LoadingWidget(
            bloc: _homeBloc,
            child: Container(),
          )
        ],
      ),
    ));
  }

  Widget _buildItemFood(Product? product) {
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
                          "Gi?? : ${NumberFormat("#,###", "en_US").format(product.price)} ??",
                          style: const TextStyle(fontSize: 12)),
                      Row(children: [
                        ElevatedButton(
                          onPressed: () {
                            addCart(product.id);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
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
                                          Radius.circular(10))))),
                          child: const Text("Th??m v??o gi???",
                              style: TextStyle(fontSize: 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              showProductDialog(product, context);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return const Color.fromARGB(
                                        200, 11, 22, 142);
                                  } else {
                                    return const Color.fromARGB(
                                        230, 11, 22, 142);
                                  }
                                }),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))))),
                            child: Text("Chi ti???t",
                                style: const TextStyle(fontSize: 14)),
                          ),
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
