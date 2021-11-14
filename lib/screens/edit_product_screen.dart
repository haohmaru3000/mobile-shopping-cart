import 'package:flutter/material.dart';

/*
 *  Form inputs are only good for a widget in local state => use Stateful widget
 *  (what the users entered is important for this widget because we wanna validate it, and store there.
 *   Once user submits like pressing submit button, we typically wanna save that info into the App-wide state)
 *   EX: create a product, signup a users, whatever we're doing but until the submit button is pressed 
 *      we only wanna only manage that data in our local widget as users might cancel adding, might close the app...
 *      => So, the general app is not affected by the user input until it's really submitted
 *      => We want to manage the User input and validate it and so on, locally in this widget
 */
class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

/* The state which is related to EditProductScreen widget */
class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Standalone page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
