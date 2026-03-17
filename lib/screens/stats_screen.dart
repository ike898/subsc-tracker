import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../widgets/banner_ad_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsProvider);
    final totalMonthly = ref.watch(totalMonthlyProvider);
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
                Icon(Icons.bar_chart,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Add subscriptions to see stats',
                    style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        }

        // Sort by monthly price descending
        final sorted = [...subs]
          ..sort((a, b) => b.monthlyPrice.compareTo(a.monthlyPrice));

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  Row(
                    children: [
                      _StatCard(
                        title: 'Monthly',
                        value: '\$${totalMonthly.toStringAsFixed(2)}',
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'Yearly',
                        value:
                            '\$${(totalMonthly * 12).toStringAsFixed(2)}',
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatCard(
                        title: 'Subscriptions',
                        value: '${subs.length}',
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'Avg / Sub',
                        value: subs.isNotEmpty
                            ? '\$${(totalMonthly / subs.length).toStringAsFixed(2)}'
                            : '\$0',
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('By Cost (Monthly)',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...sorted.map((sub) {
                    final ratio = totalMonthly > 0
                        ? sub.monthlyPrice / totalMonthly
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(sub.name,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: ratio,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              color: sub.color,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${sub.monthlyPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const BannerAdWidget(),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final ThemeData theme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
