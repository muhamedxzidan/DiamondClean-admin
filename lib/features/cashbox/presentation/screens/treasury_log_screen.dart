import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/widgets/custom_card.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../cubit/cashbox_cubit.dart';
import '../../cubit/cashbox_state.dart';

class TreasuryLogScreen extends StatefulWidget {
  const TreasuryLogScreen({super.key});

  @override
  State<TreasuryLogScreen> createState() => _TreasuryLogScreenState();
}

class _TreasuryLogScreenState extends State<TreasuryLogScreen> {
  DateTimeRange? _dateRange;

  List<CashboxTreasuryLogEntry> _filterEntries(
    List<CashboxTreasuryLogEntry> entries,
  ) {
    final dateRange = _dateRange;
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

  Future<void> _pickDateRange() async {
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

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashboxCubit, CashboxState>(
      builder: (context, state) {
        final entries = switch (state) {
          CashboxLoaded(:final treasuryLogEntries) => _filterEntries(
            treasuryLogEntries,
          ),
          _ => const <CashboxTreasuryLogEntry>[],
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
                                      _formatDateTime(entry.dateTime),
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
                                child: Text(
                                  entry.note,
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
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
