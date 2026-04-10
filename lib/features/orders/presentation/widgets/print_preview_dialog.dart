import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/whatsapp_invoice_service.dart';
import '../../data/models/order_model.dart';
import 'print_dialog/print_item_row.dart';
import 'print_dialog/print_row.dart';

class PrintPreviewDialog extends StatelessWidget {
  final OrderModel order;

  const PrintPreviewDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dt = order.createdAt;
    final dateStr =
        '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}'
        ' — ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.receipt_long_outlined),
          SizedBox(width: 8),
          Text(AppStrings.orderDetails),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrintRow(label: AppStrings.orderRef, value: order.displayRef),
              PrintRow(
                label: AppStrings.orderCustomer,
                value: order.customerName,
              ),
              PrintRow(
                label: AppStrings.orderPhone,
                value: order.customerPhone,
              ),
              PrintRow(label: AppStrings.orderAddress, value: order.address),
              PrintRow(
                label: AppStrings.orderDriver,
                value: '${order.driverName} (${order.carNumber})',
              ),
              PrintRow(label: AppStrings.orderDate, value: dateStr),
              if (order.notes != null && order.notes!.isNotEmpty)
                PrintRow(label: 'ملاحظات', value: order.notes!),
              if (order.items.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  AppStrings.orderItems,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => PrintItemRow(item: item),
                ),
              ],
              if (order.deliveryFee > 0) ...[
                const Divider(height: 24),
                PrintRow(
                  label: AppStrings.deliveryFee,
                  value:
                      '${order.deliveryFee.toStringAsFixed(2)} ${AppStrings.currency}',
                ),
              ],
              const Divider(height: 24),
              _buildTotalRow(context),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        _WhatsappButton(order: order),
      ],
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.orderTotal,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          order.totalPrice != null
              ? '${order.totalPrice!.toStringAsFixed(2)} ${AppStrings.currency}'
              : AppStrings.notPricedYet,
          style: textTheme.titleMedium?.copyWith(
            color: order.totalPrice != null
                ? colorScheme.primary
                : colorScheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _WhatsappButton extends StatefulWidget {
  final OrderModel order;

  const _WhatsappButton({required this.order});

  @override
  State<_WhatsappButton> createState() => _WhatsappButtonState();
}

class _WhatsappButtonState extends State<_WhatsappButton> {
  bool _loading = false;

  Future<void> _send() async {
    setState(() => _loading = true);
    try {
      await WhatsappInvoiceService.sendInvoice(widget.order);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تعذّر إرسال الفاتورة، تأكد من تثبيت واتساب ومن صحة رقم العميل',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.message_outlined),
      label: const Text(AppStrings.sendWhatsapp),
      onPressed: _loading ? null : _send,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
        foregroundColor: const Color(0xFF128C7E),
      ),
    );
  }
}
