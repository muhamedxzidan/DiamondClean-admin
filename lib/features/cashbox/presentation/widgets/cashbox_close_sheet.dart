import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/cashbox_expense_model.dart';
import 'cashbox_sheet_row.dart';

class CashboxCloseSheet extends StatefulWidget {
  final double openingBalance;
  final double sessionRevenue;
  final double sessionExpenses;
  final List<CashboxExpenseModel> sessionExpenseEntries;
  final double sessionBalance;
  final Future<void> Function(String closedBy) onConfirm;

  const CashboxCloseSheet({
    super.key,
    required this.openingBalance,
    required this.sessionRevenue,
    required this.sessionExpenses,
    required this.sessionExpenseEntries,
    required this.sessionBalance,
    required this.onConfirm,
  });

  @override
  State<CashboxCloseSheet> createState() => _CashboxCloseSheetState();
}

class _CashboxCloseSheetState extends State<CashboxCloseSheet> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormFieldState<String>>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (!_formKey.currentState!.validate()) return;
    widget.onConfirm(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netToday = widget.sessionBalance;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.cashboxClose, style: theme.textTheme.titleLarge),
          const Divider(height: 24),
          CashboxSheetRow(
            label: AppStrings.cashboxOpeningBalance,
            value: widget.openingBalance.toStringAsFixed(2),
          ),
          const SizedBox(height: 8),
          CashboxSheetRow(
            label: AppStrings.cashboxSessionRevenue,
            value: widget.sessionRevenue.toStringAsFixed(2),
          ),
          const SizedBox(height: 8),
          CashboxSheetRow(
            label: AppStrings.cashboxSessionExpenses,
            value: widget.sessionExpenses.toStringAsFixed(2),
          ),
          if (widget.sessionExpenseEntries.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                children: widget.sessionExpenseEntries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '• ${e.title}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              e.amount.toStringAsFixed(2),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          CashboxSheetRow(
            label: AppStrings.cashboxNetToday,
            value: netToday.toStringAsFixed(2),
            bold: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: _formKey,
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.cashboxClosedBy,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.cashboxClosedByRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _handleConfirm,
                  child: const Text(AppStrings.cashboxConfirmClose),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
