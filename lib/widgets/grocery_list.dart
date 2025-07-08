import 'package:flutter/material.dart';
import 'package:shopping_list/modules/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItem = [];
  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => NewItem(),
    ));
    if (newItem == null) return;
    setState(() {
      _groceryItem.add(newItem);
    });
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

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_groceryItem[index].name),
          leading: Container(
            height: 24,
            width: 24,
            color: _groceryItem[index].category.color,
          ),
          trailing: Text(_groceryItem[index].quantity.toString()),
        ),
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
