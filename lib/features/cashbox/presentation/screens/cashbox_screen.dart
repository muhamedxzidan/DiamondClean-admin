import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../cubit/cashbox_cubit.dart';
import '../../cubit/cashbox_state.dart';
import '../widgets/cashbox_close_sheet.dart';
import '../widgets/cashbox_app_bar_actions.dart';
import '../widgets/cashbox_day_ended_dialog.dart';
import '../widgets/cashbox_loaded_content.dart';
import '../widgets/cashbox_opening_balance_dialog.dart';
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
  bool _isDayEndedDialogShowing = false;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

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
            buildWhen: (previous, current) {
              final prevPin = previous is CashboxLoaded
                  ? previous.settings.ownerPin
                  : null;
              final currPin = current is CashboxLoaded
                  ? current.settings.ownerPin
                  : null;
              return prevPin != currPin ||
                  previous.runtimeType != current.runtimeType;
            },
            builder: (context, state) {
              final pin = state is CashboxLoaded
                  ? state.settings.ownerPin
                  : null;
              final cubit = context.read<CashboxCubit>();
              return CashboxAppBarActions(
                hasPin: pin != null,
                isUnlocked: _isUnlocked,
                onPinPressed: () => showCashboxPinDialog(context, pin, cubit),
                onPickDayPressed: _pickDay,
                onOpeningBalancePressed: () =>
                    showCashboxOpeningBalanceDialog(context, cubit),
                onClosuresLogPressed: () {
                  if (state is! CashboxLoaded) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ClosuresLogScreen(closures: state.dailyClosures),
                    ),
                  );
                },
                onTreasuryLogPressed: () {
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
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CashboxCubit, CashboxState>(
        listenWhen: (previous, current) {
          if (current is CashboxError) return true;
          if (current is CashboxLoaded && current.isDayEnded) return true;
          return false;
        },
        buildWhen: (previous, current) {
          if (previous.runtimeType != current.runtimeType) return true;
          if (previous is CashboxLoaded && current is CashboxLoaded) {
            return previous.selectedDay != current.selectedDay ||
                previous.sessionRevenue != current.sessionRevenue ||
                previous.sessionExpenseEntries !=
                    current.sessionExpenseEntries ||
                previous.sessionIncomeEntries != current.sessionIncomeEntries ||
                previous.settings.ownerPin != current.settings.ownerPin;
          }
          return true;
        },
        listener: (context, state) {
          if (state is CashboxError) {
            _scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is CashboxLoaded &&
              state.isDayEnded &&
              !_isDayEndedDialogShowing) {
            _showDayEndedDialog(state);
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
    return CashboxLoadedContent(
      state: state,
      onRefresh: () async =>
          context.read<CashboxCubit>().selectDay(state.selectedDay),
      onClosePressed: () => _showCloseBottomSheet(state),
    );
  }

  void _showDayEndedDialog(CashboxLoaded state) {
    _isDayEndedDialogShowing = true;
    CashboxDayEndedDialog.show(
      context,
      state: state,
      onCloseAndCarryOver: () async {
        Navigator.pop(context);
        _isDayEndedDialogShowing = false;

        final cubit = context.read<CashboxCubit>();
        final carryOverBalance = state.sessionBalance;

        await cubit.closeCashbox('إقفال تلقائي - منتصف الليل');
        await cubit.saveOpeningBalance(carryOverBalance, 'ترحيل تلقائي');
        cubit.selectDay(DateTime.now());
      },
      onCloseAndZero: () async {
        Navigator.pop(context);
        _isDayEndedDialogShowing = false;

        final cubit = context.read<CashboxCubit>();

        await cubit.closeCashbox('تصفير - منتصف الليل');
        await cubit.saveOpeningBalance(0, 'تصفير تلقائي');
        cubit.selectDay(DateTime.now());
      },
      onDismiss: () {
        Navigator.pop(context);
        _isDayEndedDialogShowing = false;
        context.read<CashboxCubit>().dismissDayEndedNotification();
      },
    );
  }
}
