import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './product.dart';

/*  ChangeNotifier: kind of related to the inherited widget that the provider package uses,
 *                  and allows us to establish behind the scene communication turnel with the
 *                  help of context object in every widget.
 *  - The class will be used as a Provider package which uses inherited widget behind the scene
 *    to establish a communication channel between this class and widgets that are interested for us.
 *  - It also needs to be provided to the widget at a highest point leading to child widgets which are 
 *    interested in data provided by this class.
 */
class Products with ChangeNotifier {
  List<Product> _items = [];
  // A list which can be changed over time and not final
  // Product(
  //   id: 'p1',
  //   title: 'Red Shirt',
  //   description: 'A red shirt - it is pretty red!',
  //   price: 29.99,
  //   imageUrl:
  //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  // ),
  // Product(
  //   id: 'p2',
  //   title: 'Trousers',
  //   description: 'A nice pair of trousers.',
  //   price: 59.99,
  //   imageUrl:
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  // ),
  // Product(
  //   id: 'p3',
  //   title: 'Yellow Scarf',
  //   description: 'Warm and cozy - exactly what you need for the winter.',
  //   price: 19.99,
  //   imageUrl:
  //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  // ),
  // Product(
  //   id: 'p4',
  //   title: 'A Pan',
  //   description: 'Prepare any meal you want.',
  //   price: 49.99,
  //   imageUrl:
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  // ),

  final String? _authToken;

  Products(this._authToken, this._items);

  List<Product> get items {
    return [
      ..._items
    ]; // Return a copy of "_items" to ensure it can't be changed directly from outside
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id.toString() == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        "https://flutter-cart-1-default-rtdb.firebaseio.com/products.json?auth=${_authToken}");
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }

    // try {
    //   final response = await http.get(url);
    //   if (response.body != "null") {
    //     print(response.statusCode);
    //     final Map<String, dynamic> decodedJSON = jsonDecode(response.body);
    //     final List<Product> loadedProduct = [];

    //     decodedJSON.forEach((prodId, prodData) {
    //       loadedProduct.add(Product(
    //         id: prodId,
    //         title: prodData["title"],
    //         description: prodData["description"],
    //         price: prodData["price"],
    //         imageUrl: prodData["imageUrl"],
    //         isFavorite: prodData["isFavorite"],
    //       ));
    //     });
    //     _items = loadedProduct;
    //   } else {
    //     _items = [];
    //   }
    //   notifyListeners();
    // } catch (error) {
    //   rethrow;
    // }
  }

  /* Add a new product into the current list of products */
  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        "https://flutter-cart-1-default-rtdb.firebaseio.com/products.json?auth=${_authToken}");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners(); // Notify widget classes listening to this class about changes in "_items" to be rebuilt
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  /* Edit and update the information about the selected product */
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id.toString() == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          "https://flutter-cart-1-default-rtdb.firebaseio.com/products/$id.json?auth=${_authToken}");
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  /* Delete a specific product based on an product-id provided by someone */
  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://flutter-cart-1-default-rtdb.firebaseio.com/products/$id.json?auth=${_authToken}");
    final existingProductIndex =
        _items.indexWhere((prod) => prod.id.toString() == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
