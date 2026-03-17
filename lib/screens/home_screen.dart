import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsProvider);
    final totalMonthly = ref.watch(totalMonthlyProvider);
    final totalYearly = ref.watch(totalYearlyProvider);
    final theme = Theme.of(context);

    return subsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (subs) {
        if (subs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.subscriptions_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('No subscriptions yet',
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Tap + to add your first subscription',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Monthly Spend',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalMonthly.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text('\$${totalYearly.toStringAsFixed(2)} / year',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('${subs.length} Subscriptions',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...subs.map((sub) => _SubscriptionTile(sub: sub)),
          ],
        );
      },
    );
  }
}

class _SubscriptionTile extends ConsumerWidget {
  final Subscription sub;
  const _SubscriptionTile({required this.sub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final daysUntil = sub.nextBilling.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(sub.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) {
        ref.read(subscriptionsProvider.notifier).deleteSubscription(sub.id);
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: sub.color.withValues(alpha: 0.2),
            child: Text(
              sub.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                  color: sub.color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(sub.name),
          subtitle: Text(
            sub.isOverdue
                ? 'Overdue!'
                : sub.isDueSoon
                    ? 'Due in $daysUntil days'
                    : '${sub.cycleLabel} · Next: ${_formatDate(sub.nextBilling)}',
          ),
          trailing: Text(
            '\$${sub.price.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: sub.isOverdue ? theme.colorScheme.error : null,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.month}/${d.day}/${d.year}';
}
