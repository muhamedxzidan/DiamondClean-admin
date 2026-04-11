import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../cubit/cashbox_cubit.dart';
import '../../cubit/cashbox_state.dart';
import '../widgets/cashbox_close_sheet.dart';
import '../widgets/cashbox_daily_report_section.dart';
import '../widgets/cashbox_expenses_section.dart';
import '../widgets/cashbox_opening_balance_dialog.dart';
import '../widgets/cashbox_orders_section.dart';
import '../widgets/cashbox_pin_dialog.dart';
import '../widgets/cashbox_pin_overlay.dart';
import 'closures_log_screen.dart';
import 'treasury_log_screen.dart';

class CashboxScreen extends StatefulWidget {
  const CashboxScreen({super.key});

  @override
  State<CashboxScreen> createState() => _CashboxScreenState();
}

class _CashboxScreenState extends State<CashboxScreen> {
  bool _isUnlocked = false;

  Future<void> _pickDay() async {
    final state = context.read<CashboxCubit>().state;
    final selectedDay = state is CashboxLoaded
        ? state.selectedDay
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: selectedDay,
    );
    if (picked != null && mounted) {
      context.read<CashboxCubit>().selectDay(picked);
    }
  }

  void _showCloseBottomSheet(CashboxLoaded state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => CashboxCloseSheet(
        openingBalance: state.settings.openingBalance,
        sessionRevenue: state.sessionRevenue,
        sessionExpenses: state.sessionExpenses,
        sessionExpenseEntries: state.sessionExpenseEntries,
        sessionBalance: state.sessionBalance,
        onConfirm: (closedBy) async {
          Navigator.pop(sheetContext);
          await context.read<CashboxCubit>().closeCashbox(closedBy);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cashboxTitle),
        actions: [
          BlocBuilder<CashboxCubit, CashboxState>(
            builder: (context, state) {
              final pin = state is CashboxLoaded
                  ? state.settings.ownerPin
                  : null;
              final locked = pin != null && !_isUnlocked;
              final cubit = context.read<CashboxCubit>();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _isUnlocked || pin == null
                        ? () => showCashboxPinDialog(context, pin, cubit)
                        : null,
                    icon: Icon(
                      pin == null
                          ? Icons.lock_open_outlined
                          : Icons.lock_outlined,
                    ),
                    tooltip: pin == null
                        ? AppStrings.cashboxPinSet
                        : AppStrings.cashboxPinChange,
                  ),
                  IconButton(
                    onPressed: locked ? null : _pickDay,
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                  IconButton(
                    onPressed: locked
                        ? null
                        : () => showCashboxOpeningBalanceDialog(context, cubit),
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    tooltip: AppStrings.cashboxSetOpeningBalance,
                  ),
                  IconButton(
                    onPressed: locked
                        ? null
                        : () {
                            if (state is! CashboxLoaded) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ClosuresLogScreen(
                                  closures: state.dailyClosures,
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.history_outlined),
                    tooltip: AppStrings.cashboxClosuresLog,
                  ),
                  IconButton(
                    onPressed: locked
                        ? null
                        : () {
                            if (state is! CashboxLoaded) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CashboxCubit>(),
                                  child: const TreasuryLogScreen(),
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.receipt_long_outlined),
                    tooltip: AppStrings.cashboxTreasuryLog,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CashboxCubit, CashboxState>(
        listener: (context, state) {
          if (state is CashboxError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) => switch (state) {
          CashboxInitial() || CashboxLoading() => const LoadingWidget(),
          CashboxError(:final message) => Center(child: Text(message)),
          CashboxLoaded() => _buildLockedOrContent(context, state),
        },
      ),
    );
  }

  Widget _buildLockedOrContent(BuildContext context, CashboxLoaded state) {
    final pin = state.settings.ownerPin;
    if (pin != null && !_isUnlocked) {
      return CashboxPinOverlay(
        storedPin: pin,
        onUnlocked: () => setState(() => _isUnlocked = true),
      );
    }
    return _buildLoaded(context, state);
  }

  Widget _buildLoaded(BuildContext context, CashboxLoaded state) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<CashboxCubit>().selectDay(state.selectedDay),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CashboxDailyReportSection(state: state),
                const SizedBox(height: 16),
                CashboxExpensesSection(state: state),
                const SizedBox(height: 16),
                CashboxOrdersSection(state: state),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _buildCloseCta(context, state),
      ],
    );
  }

  Widget _buildCloseCta(BuildContext context, CashboxLoaded state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => _showCloseBottomSheet(state),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            child: const Text(
              AppStrings.cashboxCloseTodayCta,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
