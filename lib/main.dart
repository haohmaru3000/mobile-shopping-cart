import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Products(),
      child: MaterialApp(
          title: 'Shopping cart',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            colorScheme: ColorScheme.fromSwatch(
              accentColor: Colors.deepOrange,
            ),
            fontFamily: 'Lato',
          ),
          home: ProductsOverviewScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          }),
    );
  }
}
