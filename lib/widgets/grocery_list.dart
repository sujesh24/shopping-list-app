import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/modules/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  var isLoading = true;
  String? _error;

//load /get data
  @override
  void initState() {
    _loadItem();
    super.initState();
  }

  void _loadItem() async {
    final url = Uri.https(
        'flutter-prep-2b2fd-default-rtdb.firebaseio.com', 'grocery-list.json');
    final resposne = await http.get(url);
    if (resposne.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data!Please try again.';
      });
    }
    //decode
    final Map<String, dynamic> listData = json.decode(resposne.body);
    //convert to GroceryItem
    final List<GroceryItem> loadData = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      loadData.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }
    setState(() {
      _groceryItem = loadData;
      isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );

    // _loadItem();
    setState(() {
      if (newItem != null) {
        _groceryItem.add(newItem);
      }
    });
  }

  void _removeItem(GroceryItem item) async {
    final newItemIndex = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
      isLoading = true;
    });

    final url = Uri.https('flutter-prep-2b2fd-default-rtdb.firebaseio.com',
        'grocery-list/${item.id}.json');
    final response = await http.delete(url);

    setState(() {
      isLoading = false;
      if (response.statusCode >= 400) {
        _groceryItem.insert(newItemIndex, item);
      }
    });

    //sacfold
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            setState(() {
              isLoading = true;
              _groceryItem.insert(newItemIndex, item);
            });
            //undo in firebase - restore the item with correct endpoint and data format
            final url = Uri.https(
                'flutter-prep-2b2fd-default-rtdb.firebaseio.com',
                'grocery-list/${item.id}.json');
            final response = await http.put(url,
                headers: {'content-type': 'application/json'},
                body: json.encode({
                  'name': item.name,
                  'quantity': item.quantity,
                  'category': item.category.title,
                }));
            setState(() {
              isLoading = false;
              if (response.statusCode >= 400) {
                // Handle error case - maybe remove the item from UI again
                _groceryItem.removeAt(newItemIndex);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No items addded yet!',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(
            width: 6,
          ),
          Icon(
            Icons.remove_shopping_cart,
            size: 30,
          ),
        ],
      ),
    );
    if (isLoading) {
      content = Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey,
          color: Colors.white,
        ),
      );
    } else if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItem[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItem[index]);
          },
          child: ListTile(
            title: Text(_groceryItem[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItem[index].category.color,
            ),
            trailing: Text(_groceryItem[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!,
            style: TextStyle(
              fontSize: 24,
            )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
