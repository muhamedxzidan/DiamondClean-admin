import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an auditable event in the cashbox system.
/// Every operation (income, expense, closure, etc.) is recorded with who did it and when.
class CashboxAuditLogModel {
  final String id;
  final AuditEventType eventType;
  final String operationId;
  final String performedBy;
  final double amount;
  final String? description;
  final Map<String, dynamic>? metadata;
  final bool isValid;
  final String? validationError;
  final DateTime createdAt;

  const CashboxAuditLogModel({
    required this.id,
    required this.eventType,
    required this.operationId,
    required this.performedBy,
    required this.amount,
    this.description,
    this.metadata,
    this.isValid = true,
    this.validationError,
    required this.createdAt,
  });

  factory CashboxAuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashboxAuditLogModel(
      id: doc.id,
      eventType: AuditEventType.fromValue(data['eventType'] as String?),
      operationId: data['operationId'] as String? ?? '',
      performedBy: data['performedBy'] as String? ?? 'System',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      description: data['description'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      isValid: data['isValid'] as bool? ?? true,
      validationError: data['validationError'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'eventType': eventType.value,
    'operationId': operationId,
    'performedBy': performedBy,
    'amount': amount,
    if (description != null) 'description': description,
    if (metadata != null) 'metadata': metadata,
    'isValid': isValid,
    if (validationError != null) 'validationError': validationError,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

enum AuditEventType {
  openingBalanceSet('opening_balance_set', 'تعيين رصيد الافتتاح'),
  incomeRecorded('income_recorded', 'تسجيل دخل'),
  expenseAdded('expense_added', 'إضافة مصروف'),
  expenseUpdated('expense_updated', 'تعديل مصروف'),
  expenseDeleted('expense_deleted', 'حذف مصروف'),
  cashboxClosed('cashbox_closed', 'إغلاق الخزنة'),
  pinChanged('pin_changed', 'تغيير كلمة المرور'),
  validationFailed('validation_failed', 'فشل التحقق'),
  operationFailed('operation_failed', 'فشل العملية'),
  factoryReset('factory_reset', 'مسح جميع البيانات');

  final String value;
  final String label;

  const AuditEventType(this.value, this.label);

  static AuditEventType fromValue(String? value) => switch (value) {
    'opening_balance_set' => AuditEventType.openingBalanceSet,
    'income_recorded' => AuditEventType.incomeRecorded,
    'expense_added' => AuditEventType.expenseAdded,
    'expense_updated' => AuditEventType.expenseUpdated,
    'expense_deleted' => AuditEventType.expenseDeleted,
    'cashbox_closed' => AuditEventType.cashboxClosed,
    'pin_changed' => AuditEventType.pinChanged,
    'validation_failed' => AuditEventType.validationFailed,
    'operation_failed' => AuditEventType.operationFailed,
    'factory_reset' => AuditEventType.factoryReset,
    _ => AuditEventType.operationFailed,
  };
}
