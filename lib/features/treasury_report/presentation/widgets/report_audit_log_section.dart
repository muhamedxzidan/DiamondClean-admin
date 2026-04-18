import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';

class ReportAuditLogSection extends StatelessWidget {
  final List<CashboxAuditLogModel> auditLogs;

  const ReportAuditLogSection({super.key, required this.auditLogs});

  @override
  Widget build(BuildContext context) {
    if (auditLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    final timeFormatter = DateFormat('HH:mm:ss');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجل التدقيق',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'جميع العمليات المنفذة مع من قام بها ومتى',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          SizedBox(
            height: 300,
            child: ListView.separated(
              itemCount: auditLogs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _AuditLogListItem(
                  log: auditLogs[index],
                  timeFormatter: timeFormatter,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogListItem extends StatelessWidget {
  const _AuditLogListItem({
    required this.log,
    required this.timeFormatter,
  });

  final CashboxAuditLogModel log;
  final DateFormat timeFormatter;

  @override
  Widget build(BuildContext context) {
    final isValid = log.isValid;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.eventType.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isValid ? null : Colors.red[700],
                                ),
                          ),
                        ),
                        if (!isValid)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(
                                color: Colors.red[300]!,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'فشل',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.red[700],
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.description ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (log.amount != 0)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${log.amount > 0 ? '+' : ''}${log.amount}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: log.amount > 0 ? Colors.green : Colors.red,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'بواسطة: ${log.performedBy}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timeFormatter.format(log.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          if (log.validationError != null &&
              log.validationError!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'خطأ: ${log.validationError}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.red[700]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
