part of 'cashbox_cubit.dart';

CashboxSessionSummary _cashboxSessionSummary(CashboxCubit cubit) {
  return cubit._calculationService.sessionSummary(
    incomeEntries: cubit._incomeEntries,
    expenses: cubit._expenses,
    selectedDay: cubit._selectedDay,
    settings: cubit._settings,
    todayStart: CashboxCubit._todayStart(),
  );
}
