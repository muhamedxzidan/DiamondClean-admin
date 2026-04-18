part of 'cashbox_cubit.dart';

Future<void> _cashboxPerformMutation(
  CashboxCubit cubit,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    cubit._emitMutationError(error);
  }
}

Future<void> _cashboxLogAuditEvent(
  CashboxCubit cubit, {
  required AuditEventType eventType,
  required String operationId,
  required String performedBy,
  required double amount,
  String? description,
  Map<String, dynamic>? metadata,
  required bool isValid,
  String? validationError,
}) async {
  try {
    final auditLog = CashboxAuditLogModel(
      id: '${DateTime.now().microsecondsSinceEpoch}_$operationId',
      eventType: eventType,
      operationId: operationId,
      performedBy: performedBy,
      amount: amount,
      description: description,
      metadata: metadata,
      isValid: isValid,
      validationError: validationError,
      createdAt: DateTime.now(),
    );

    await cubit._dataSource.logAuditEvent(auditLog);
  } catch (error) {
    // Audit logging must not block cashbox operations.
  }
}
