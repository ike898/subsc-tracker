import 'package:flutter/material.dart';

enum BillingCycle { weekly, monthly, quarterly, yearly }

class Subscription {
  final String id;
  final String name;
  final String? icon;
  final double price;
  final String currency;
  final BillingCycle cycle;
  final DateTime startDate;
  final DateTime nextBilling;
  final String? category;
  final String? note;
  final int colorValue;

  Subscription({
    required this.id,
    required this.name,
    this.icon,
    required this.price,
    this.currency = 'USD',
    required this.cycle,
    required this.startDate,
    required this.nextBilling,
    this.category,
    this.note,
    this.colorValue = 0xFF6750A4,
  });

  double get monthlyPrice {
    switch (cycle) {
      case BillingCycle.weekly:
        return price * 52 / 12;
      case BillingCycle.monthly:
        return price;
      case BillingCycle.quarterly:
        return price / 3;
      case BillingCycle.yearly:
        return price / 12;
    }
  }

  double get yearlyPrice => monthlyPrice * 12;

  bool get isDueSoon {
    final now = DateTime.now();
    return nextBilling.difference(now).inDays <= 3 &&
        nextBilling.isAfter(now);
  }

  bool get isOverdue {
    return nextBilling.isBefore(DateTime.now());
  }

  Color get color => Color(colorValue);

  String get cycleLabel {
    switch (cycle) {
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  Subscription copyWith({
    String? name,
    String? icon,
    double? price,
    String? currency,
    BillingCycle? cycle,
    DateTime? startDate,
    DateTime? nextBilling,
    String? category,
    String? note,
    int? colorValue,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      cycle: cycle ?? this.cycle,
      startDate: startDate ?? this.startDate,
      nextBilling: nextBilling ?? this.nextBilling,
      category: category ?? this.category,
      note: note ?? this.note,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'price': price,
        'currency': currency,
        'cycle': cycle.index,
        'startDate': startDate.toIso8601String(),
        'nextBilling': nextBilling.toIso8601String(),
        'category': category,
        'note': note,
        'colorValue': colorValue,
      };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String?,
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        cycle: BillingCycle.values[json['cycle'] as int],
        startDate: DateTime.parse(json['startDate'] as String),
        nextBilling: DateTime.parse(json['nextBilling'] as String),
        category: json['category'] as String?,
        note: json['note'] as String?,
        colorValue: json['colorValue'] as int? ?? 0xFF6750A4,
      );
}
