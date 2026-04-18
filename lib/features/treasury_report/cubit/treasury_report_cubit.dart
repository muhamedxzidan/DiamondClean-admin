import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/datasources/treasury_report_remote_data_source.dart';
import '../data/models/treasury_report_model.dart';
import 'treasury_report_state.dart';

class TreasuryReportCubit extends Cubit<TreasuryReportState> {
  final TreasuryReportRemoteDataSource _dataSource;
  StreamSubscription<TreasuryReportModel>? _reportSubscription;

  TreasuryReportCubit(this._dataSource) : super(const TreasuryReportInitial());

  Future<void> generateReport(DateTime startDate, DateTime endDate) async {
    await _reportSubscription?.cancel();
    emit(const TreasuryReportLoading());

    try {
      _reportSubscription = _dataSource
          .watchReport(startDate, endDate)
          .listen(
            (report) => _handleReport(report, startDate, endDate),
            onError: _emitError,
          );
    } catch (error) {
      _emitError(error);
    }
  }

  Future<void> _handleReport(
    TreasuryReportModel report,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final auditLogs = await _dataSource.getAuditLogsByDateRange(
      startDate,
      endDate,
    );

    if (isClosed) {
      return;
    }

    emit(TreasuryReportLoaded(report, auditLogs: auditLogs));
  }

  void _emitError(Object error) {
    if (isClosed) {
      return;
    }

    emit(TreasuryReportError(error.toString()));
  }

  @override
  Future<void> close() async {
    await _reportSubscription?.cancel();
    return super.close();
  }
}
