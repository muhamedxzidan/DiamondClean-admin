import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/whatsapp_invoice_service.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import 'pricing_dialog/order_pricing_header.dart';
import 'pricing_dialog/item_pricing_section.dart';
import 'pricing_dialog/pricing_number_field.dart';
import 'pricing_dialog/order_pricing_footer.dart';
import 'pricing_dialog/order_pricing_calculator.dart';

class OrderPricingDialog extends StatefulWidget {
  final OrderModel order;

  const OrderPricingDialog({super.key, required this.order});

  @override
  State<OrderPricingDialog> createState() => _OrderPricingDialogState();
}

class _OrderPricingDialogState extends State<OrderPricingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<GlobalKey<ItemPricingSectionState>> _sectionKeys;
  late final TextEditingController _deliveryFeeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(
      widget.order.items.length,
      (_) => GlobalKey<ItemPricingSectionState>(),
    );
    _deliveryFeeController = TextEditingController(
      text: widget.order.deliveryFee > 0
          ? widget.order.deliveryFee.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _deliveryFeeController.dispose();
    super.dispose();
  }

  double? _getTotal() {
    final items = _sectionKeys
        .map((k) => k.currentState?.buildItem())
        .whereType<OrderItemModel>()
        .toList();
    if (items.length != widget.order.items.length) return null;
    final deliveryFee = double.tryParse(_deliveryFeeController.text.trim());
    return OrderPricingCalculator.calculateTotal(items, deliveryFee);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final orderTotal = _getTotal();
    if (orderTotal == null) return;
    final items = _sectionKeys.map((k) => k.currentState!.buildItem()).toList();
    setState(() => _isSaving = true);
    await context.read<OrdersCubit>().updateOrderItems(
      widget.order.id,
      items,
      deliveryFee: double.parse(_deliveryFeeController.text.trim()),
      orderTotal: orderTotal,
      itemCount: widget.order.items.fold<int>(
        0,
        (count, item) => count + item.quantity,
      ),
      orderStatus: widget.order.status.name,
      orderDate: widget.order.createdAt,
      customerName: widget.order.customerName,
      customerPhone: widget.order.customerPhone,
      customerAddress: widget.order.address,
    );
    setState(() => _isSaving = false);
  }

  void _sendWhatsapp() {
    () async {
      try {
        await WhatsappInvoiceService.sendInvoice(widget.order);
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذّر إرسال الفاتورة، تأكد من تثبيت واتساب ومن صحة رقم العميل',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }();
  }

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'أدخل رقماً صحيحاً';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state is OrdersLoaded && _isSaving) {
          Navigator.of(context).pop();
        }
        if (state is OrdersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OrderPricingHeader(order: widget.order),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    children: [
                      for (var i = 0; i < widget.order.items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 16),
                        ItemPricingSection(
                          key: _sectionKeys[i],
                          item: widget.order.items[i],
                          validator: _validatePositiveNumber,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.deliveryFee,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PricingNumberField(
                        controller: _deliveryFeeController,
                        label: AppStrings.deliveryFee,
                        suffix: AppStrings.currency,
                        validator: _validatePositiveNumber,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                OrderPricingFooter(
                  total: _getTotal(),
                  isSaving: _isSaving,
                  onSave: _save,
                  onSendWhatsapp: _sendWhatsapp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
