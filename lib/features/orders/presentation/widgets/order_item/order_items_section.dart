import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';
import 'order_item_row.dart';

class OrderItemsSection extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onOpenPricing;
  final Future<void> Function() onSendInvoice;

  const OrderItemsSection({
    super.key,
    required this.order,
    required this.onOpenPricing,
    required this.onSendInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.orderItems,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: onOpenPricing,
              icon: const Icon(Icons.calculate_outlined, size: 18),
              label: const Text(AppStrings.pricingAllItems),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                textStyle: textTheme.labelMedium,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            _QuickInvoiceButton(order: order, onSendInvoice: onSendInvoice),
          ],
        ),
        const SizedBox(height: 6),
        ...order.items.map(
          (item) => OrderItemRow(item: item),
        ),
      ],
    );
  }
}

class _QuickInvoiceButton extends StatefulWidget {
  final OrderModel order;
  final Future<void> Function() onSendInvoice;

  const _QuickInvoiceButton({required this.order, required this.onSendInvoice});

  @override
  _QuickInvoiceButtonState createState() => _QuickInvoiceButtonState();
}

class _QuickInvoiceButtonState extends State<_QuickInvoiceButton> {
  bool _sending = false;

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    await widget.onSendInvoice();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.order.customerPhone.trim().isNotEmpty;

    return OutlinedButton.icon(
      onPressed: canSend && !_sending ? _send : null,
      icon: _sending
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.message_outlined, size: 18),
      label: Text(AppStrings.sendWhatsapp),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: const Color(0xFF128C7E),
        side: const BorderSide(color: Color(0xFF128C7E)),
      ),
    );
  }
}
