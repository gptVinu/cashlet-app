import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense; // true for expense, false for income

  Category({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    this.isExpense = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.value,
      'isExpense': isExpense,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['icon'],
        fontFamily: json['iconFontFamily'],
      ),
      color: Color(json['color']),
      isExpense: json['isExpense'],
    );
  }

  static List<Category> defaultCategories() {
    return [
      Category(
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      Category(
        name: 'Transport',
        icon: Icons.directions_bus,
        color: Colors.blue,
      ),
      Category(
        name: 'Entertainment',
        icon: Icons.movie,
        color: Colors.purple,
      ),
      Category(
        name: 'Shopping',
        icon: Icons.shopping_cart,
        color: Colors.pink,
      ),
      Category(
        name: 'Bills',
        icon: Icons.receipt,
        color: Colors.red,
      ),
      Category(
        name: 'Salary',
        icon: Icons.account_balance_wallet,
        color: Colors.green,
        isExpense: false,
      ),
    ];
  }
}
