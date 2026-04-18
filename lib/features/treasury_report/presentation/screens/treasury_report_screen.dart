import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/treasury_report_date_range_calculator.dart';
import 'package:diamond_clean/features/cashbox/cubit/cashbox_cubit.dart';
import 'package:diamond_clean/features/cashbox/cubit/cashbox_state.dart';
import 'package:diamond_clean/features/cashbox/presentation/widgets/cashbox_pin_dialog.dart';

import '../../cubit/treasury_report_cubit.dart';
import '../../cubit/treasury_report_state.dart';
import '../widgets/report_quick_date_filter.dart';
import '../widgets/treasury_report_error_view.dart';
import '../widgets/treasury_report_loaded_view.dart';

class TreasuryReportScreen extends StatefulWidget {
  const TreasuryReportScreen({super.key});

  @override
  State<TreasuryReportScreen> createState() => _TreasuryReportScreenState();
}

class _TreasuryReportScreenState extends State<TreasuryReportScreen> {
  static const _dateRangeCalculator = TreasuryReportDateRangeCalculator();

  late DateTime _startDate;
  late DateTime _endDate;
  var _selectedFilter = ReportDateFilter.week;

  @override
  void initState() {
    super.initState();
    final range = _dateRangeCalculator.rangeFor(
      ReportDateFilter.week,
      DateTime.now(),
    );
    _startDate = range!.start;
    _endDate = range.end;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadReport();
    });
  }

  Future<void> _showChangePinDialog() async {
    final cubit = context.read<CashboxCubit>();
    final currentPin = switch (cubit.state) {
      CashboxLoaded(:final settings) => settings.ownerPin,
      _ => null,
    };
    if (!mounted) {
      return;
    }
    await showCashboxPinDialog(context, currentPin, cubit);
  }

  void _applyFilter(ReportDateFilter filter) {
    setState(() => _selectedFilter = filter);

    final range = _dateRangeCalculator.rangeFor(filter, DateTime.now());
    if (range == null) {
      return;
    }

    _startDate = range.start;
    _endDate = range.end;

    _loadReport();
  }

  void _loadReport() {
    context.read<TreasuryReportCubit>().generateReport(_startDate, _endDate);
  }

  Future<void> _showCustomDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedFilter = ReportDateFilter.custom;
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.treasuryReportTitle),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showChangePinDialog,
            icon: const Icon(Icons.lock_outline),
            tooltip: AppStrings.cashboxPinChange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                ReportQuickDateFilter(
                  selectedFilter: _selectedFilter,
                  onFilterSelected: _applyFilter,
                  onCustomTap: _showCustomDatePicker,
                ),
                const SizedBox(height: 8),
                Text(
                  '${dateFormatter.format(_startDate)} — ${dateFormatter.format(_endDate)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TreasuryReportCubit, TreasuryReportState>(
              buildWhen: (previous, current) {
                if (previous.runtimeType != current.runtimeType) return true;
                if (previous is TreasuryReportLoaded &&
                    current is TreasuryReportLoaded) {
                  return previous.report != current.report ||
                      previous.auditLogs != current.auditLogs;
                }
                return false;
              },
              builder: (context, state) => switch (state) {
                TreasuryReportInitial() => Center(
                  child: Text(AppStrings.treasuryReportSelectPeriod),
                ),
                TreasuryReportLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                TreasuryReportLoaded(
                  report: final report,
                  auditLogs: final auditLogs,
                ) =>
                  TreasuryReportLoadedView(
                    report: report,
                    auditLogs: auditLogs,
                    onRefresh: () async => _loadReport(),
                  ),
                TreasuryReportError(message: final message) =>
                  TreasuryReportErrorView(
                    message: message,
                    onRetry: _loadReport,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
