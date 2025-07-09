import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/modules/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/modules/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  //from validation method

  final _fromKey = GlobalKey<FormState>();
  var _eneteredName = '';
  var _enteredNumber = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    if (_fromKey.currentState!.validate() //method for validation
        ) {
      _fromKey.currentState!.save();
      //method to save the data
      final url = Uri.https('flutter-prep-2b2fd-default-rtdb.firebaseio.com',
          'grocery-list.json');
      final response = await http.post(
        url,
        headers: {
          'content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(
          {
            'name': _eneteredName,
            'quantity': _enteredNumber,
            'category': _selectedCategory.title,
          },
        ),
      );
      final resData = json.decode(response.body);
      //pop the screen
      if (!context.mounted) return;
      //check if context is mounted
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _eneteredName,
          quantity: _enteredNumber,
          category: _selectedCategory,
        ),
      );
    }
  }

  void _resetItem() {
    //method to reset
    _fromKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _fromKey, //gloobal key
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                    label: Text(
                      'Name',
                    ),
                    hintText: 'Enter new item name'),
                //input validation check
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _eneteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          label: Text(
                            'Quantity',
                          ),
                          hintText: 'Enter qunatity in number'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Must be valid positive number.';
                        }
                        return null;
                      },
                      initialValue: _enteredNumber.toString(),
                      keyboardType: TextInputType.number, //number keyboard
                      onSaved: (newValue) {
                        _enteredNumber = int.parse(newValue!);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title)
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(
                          () {
                            _selectedCategory = value!;
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _resetItem, child: Text('Reset')),
                  ElevatedButton(onPressed: _saveItem, child: Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
