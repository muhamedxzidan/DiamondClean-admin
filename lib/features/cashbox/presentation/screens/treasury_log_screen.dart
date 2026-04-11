import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/models/treasury_log_entry.dart';
import 'package:diamond_clean/core/widgets/custom_card.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../cubit/cashbox_cubit.dart';
import '../../cubit/cashbox_state.dart';

class TreasuryLogScreen extends StatelessWidget {
  const TreasuryLogScreen({super.key});

  static List<TreasuryLogEntry> _filterEntries(
    List<TreasuryLogEntry> entries,
    DateTimeRange? dateRange,
  ) {
    if (dateRange == null) {
      return entries;
    }

    final start = dateRange.start;
    final end = dateRange.end.add(const Duration(days: 1));
    return entries
        .where(
          (entry) =>
              !entry.dateTime.isBefore(start) && entry.dateTime.isBefore(end),
        )
        .toList();
  }

  static String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return _TreasuryLogContent();
  }
}

class _TreasuryLogContent extends StatefulWidget {
  const _TreasuryLogContent();

  @override
  State<_TreasuryLogContent> createState() => _TreasuryLogContentState();
}

class _TreasuryLogContentState extends State<_TreasuryLogContent> {
  DateTimeRange? _dateRange;

  Future<void> _pickDateRange() async {
    if (!mounted) return;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
    );
    if (picked != null && mounted) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashboxCubit, CashboxState>(
      builder: (context, state) {
        final entries = switch (state) {
          CashboxLoaded(:final treasuryLogEntries) =>
            TreasuryLogScreen._filterEntries(treasuryLogEntries, _dateRange),
          _ => const <TreasuryLogEntry>[],
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.cashboxTreasuryLog),
            actions: [
              IconButton(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range_outlined),
              ),
              if (_dateRange != null)
                IconButton(
                  onPressed: () => setState(() => _dateRange = null),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          body: switch (state) {
            CashboxLoaded() =>
              entries.isEmpty
                  ? const EmptyStateWidget(
                      message: AppStrings.cashboxNoLogEntries,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isNegative = entry.amount < 0;
                        final theme = Theme.of(context);
                        return CustomCard(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.type,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      TreasuryLogScreen._formatDateTime(
                                        entry.dateTime,
                                      ),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${isNegative ? "" : "+"}${entry.amount.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isNegative
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      entry.note,
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (entry.paymentMethod != null &&
                                        entry.paymentMethod!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          entry.paymentMethod!,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            CashboxError(:final message) => Center(child: Text(message)),
            _ => const LoadingWidget(),
          },
        );
      },
    );
  }
}
