import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/features/cashbox/cubit/cashbox_cubit.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/cashbox_remote_data_source.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/cashbox_remote_data_source_impl.dart';
import 'package:diamond_clean/features/cashbox/presentation/widgets/cashbox_pin_dialog.dart';

import '../../cubit/treasury_report_cubit.dart';
import '../../cubit/treasury_report_state.dart';
import '../widgets/report_audit_log_section.dart';
import '../widgets/report_cashbox_settlement_section.dart';
import '../widgets/report_expenses_section.dart';
import '../widgets/report_orders_section.dart';
import '../widgets/report_profit_section.dart';
import '../widgets/report_quick_date_filter.dart';
import '../widgets/report_revenue_section.dart';

class TreasuryReportScreen extends StatefulWidget {
  const TreasuryReportScreen({super.key});

  @override
  State<TreasuryReportScreen> createState() => _TreasuryReportScreenState();
}

class _TreasuryReportScreenState extends State<TreasuryReportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  late final CashboxRemoteDataSource _cashboxDataSource;
  var _selectedFilter = ReportDateFilter.week;

  @override
  void initState() {
    super.initState();
    _cashboxDataSource = CashboxRemoteDataSourceImpl(
      FirebaseFirestore.instance,
    );
    _applyFilter(ReportDateFilter.week);
  }

  Future<void> _showChangePinDialog() async {
    final currentPin = await _cashboxDataSource.getOwnerPin();
    if (!mounted) {
      return;
    }
    await showCashboxPinDialog(
      context,
      currentPin,
      context.read<CashboxCubit>(),
    );
  }

  void _applyFilter(ReportDateFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() => _selectedFilter = filter);

    switch (filter) {
      case ReportDateFilter.today:
        _startDate = today;
        _endDate = today;
      case ReportDateFilter.week:
        _startDate = today.subtract(const Duration(days: 7));
        _endDate = today;
      case ReportDateFilter.month:
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = today;
      case ReportDateFilter.threeMonths:
        _startDate = DateTime(now.year, now.month - 3, now.day);
        _endDate = today;
      case ReportDateFilter.custom:
        return;
    }

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
                  RefreshIndicator(
                    onRefresh: () async => _loadReport(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ReportCashboxSettlementSection(report: report),
                        const SizedBox(height: 20),
                        ReportRevenueSection(report: report),
                        const SizedBox(height: 20),
                        ReportExpensesSection(report: report),
                        const SizedBox(height: 20),
                        ReportOrdersSection(report: report),
                        const SizedBox(height: 20),
                        ReportProfitSection(report: report),
                        const SizedBox(height: 20),
                        if (auditLogs.isNotEmpty)
                          ReportAuditLogSection(auditLogs: auditLogs),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                TreasuryReportError(message: final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('خطأ: $message'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadReport,
                        child: const Text(AppStrings.tryAgain),
                      ),
                    ],
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
