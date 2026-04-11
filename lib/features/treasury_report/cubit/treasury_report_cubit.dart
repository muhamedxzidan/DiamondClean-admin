import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/datasources/treasury_report_remote_data_source.dart';
import 'treasury_report_state.dart';

class TreasuryReportCubit extends Cubit<TreasuryReportState> {
  final TreasuryReportRemoteDataSource _dataSource;
  StreamSubscription<dynamic>? _reportSubscription;

  TreasuryReportCubit(this._dataSource) : super(const TreasuryReportInitial());

  Future<void> generateReport(DateTime startDate, DateTime endDate) async {
    await _reportSubscription?.cancel();
    emit(const TreasuryReportLoading());

    try {
      _reportSubscription = _dataSource.watchReport(startDate, endDate).listen(
        (report) async {
          // Fetch audit logs for the same date range
          final auditLogs = await _dataSource.getAuditLogsByDateRange(
            startDate,
            endDate,
          );
          emit(TreasuryReportLoaded(report, auditLogs: auditLogs));
        },
        onError: (Object error) => emit(TreasuryReportError(error.toString())),
      );
    } catch (error) {
      emit(TreasuryReportError(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _reportSubscription?.cancel();
    return super.close();
  }
}
