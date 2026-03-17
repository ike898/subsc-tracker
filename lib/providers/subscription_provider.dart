import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/subscription.dart';

final subscriptionsProvider =
    AsyncNotifierProvider<SubscriptionsNotifier, List<Subscription>>(
        SubscriptionsNotifier.new);

// Derived providers
final totalMonthlyProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  return subs.fold(0.0, (sum, s) => sum + s.monthlyPrice);
});

final totalYearlyProvider = Provider<double>((ref) {
  return ref.watch(totalMonthlyProvider) * 12;
});

final upcomingProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  final upcoming = subs.where((s) => s.isDueSoon || s.isOverdue).toList();
  upcoming.sort((a, b) => a.nextBilling.compareTo(b.nextBilling));
  return upcoming;
});

class SubscriptionsNotifier extends AsyncNotifier<List<Subscription>> {
  @override
  Future<List<Subscription>> build() async => _load();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/subscriptions.json');
  }

  Future<List<Subscription>> _load() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as List;
        return json
            .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _save(List<Subscription> subs) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(subs.map((s) => s.toJson()).toList()));
  }

  Future<void> addSubscription({
    required String name,
    required double price,
    required BillingCycle cycle,
    String? category,
    String? note,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sub = Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      cycle: cycle,
      startDate: today,
      nextBilling: _computeNextBilling(today, cycle),
      category: category,
      note: note,
    );
    final current = [...(state.valueOrNull ?? []), sub];
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> deleteSubscription(String id) async {
    final current =
        (state.valueOrNull ?? []).where((s) => s.id != id).toList();
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> updateSubscription(Subscription updated) async {
    final current = (state.valueOrNull ?? [])
        .map((s) => s.id == updated.id ? updated : s)
        .toList();
    state = AsyncData(current);
    await _save(current);
  }

  DateTime _computeNextBilling(DateTime from, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.weekly:
        return from.add(const Duration(days: 7));
      case BillingCycle.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case BillingCycle.quarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case BillingCycle.yearly:
        return DateTime(from.year + 1, from.month, from.day);
    }
  }
}
