import 'package:cloud_firestore/cloud_firestore.dart';

class CashboxSettingsModel {
  final double openingBalance;
  final DateTime openedAt;
  final String? openedBy;
  final DateTime? lastClosedAt;
  final String? lastClosedBy;
  final double? lastClosingBalance;
  final String? ownerPin;

  const CashboxSettingsModel({
    required this.openingBalance,
    required this.openedAt,
    this.openedBy,
    this.lastClosedAt,
    this.lastClosedBy,
    this.lastClosingBalance,
    this.ownerPin,
  });

  factory CashboxSettingsModel.initial() {
    final now = DateTime.now();
    return CashboxSettingsModel(
      openingBalance: 0,
      openedAt: DateTime(now.year, now.month, now.day),
    );
  }

  factory CashboxSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashboxSettingsModel(
      openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0,
      openedAt: data['openedAt'] != null
          ? (data['openedAt'] as Timestamp).toDate()
          : DateTime.now(),
      openedBy: data['openedBy'] as String?,
      lastClosedAt: data['lastClosedAt'] != null
          ? (data['lastClosedAt'] as Timestamp).toDate()
          : null,
      lastClosedBy: data['lastClosedBy'] as String?,
      lastClosingBalance: (data['lastClosingBalance'] as num?)?.toDouble(),
      ownerPin: data['ownerPin'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'openingBalance': openingBalance,
    'openedAt': Timestamp.fromDate(openedAt),
    if (openedBy != null) 'openedBy': openedBy,
    if (lastClosedAt != null) 'lastClosedAt': Timestamp.fromDate(lastClosedAt!),
    if (lastClosedBy != null) 'lastClosedBy': lastClosedBy,
    if (lastClosingBalance != null) 'lastClosingBalance': lastClosingBalance,
    if (ownerPin != null) 'ownerPin': ownerPin,
  };

  CashboxSettingsModel copyWith({
    double? openingBalance,
    DateTime? openedAt,
    String? openedBy,
    DateTime? lastClosedAt,
    String? lastClosedBy,
    double? lastClosingBalance,
    Object? ownerPin = _sentinel,
  }) {
    return CashboxSettingsModel(
      openingBalance: openingBalance ?? this.openingBalance,
      openedAt: openedAt ?? this.openedAt,
      openedBy: openedBy ?? this.openedBy,
      lastClosedAt: lastClosedAt ?? this.lastClosedAt,
      lastClosedBy: lastClosedBy ?? this.lastClosedBy,
      lastClosingBalance: lastClosingBalance ?? this.lastClosingBalance,
      ownerPin: ownerPin == _sentinel ? this.ownerPin : ownerPin as String?,
    );
  }
}

const _sentinel = Object();
