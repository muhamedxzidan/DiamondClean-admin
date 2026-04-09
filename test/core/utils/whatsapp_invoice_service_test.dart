import 'package:diamond_clean/core/utils/whatsapp_invoice_service.dart';
import 'package:diamond_clean/features/orders/data/models/item_unit_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildInvoiceMessage formats a fully priced order', () {
    final order = _pricedOrder();

    expect(
      buildInvoiceMessage(order),
      'Diamond Clean\n'
      'رقم الفاتورة: 100\n'
      'التاريخ: 2026/04/09\n'
      '--------------------\n'
      'العميل: أحمد علي\n'
      'كود العميل: C-100\n'
      'الهاتف: 01000000000\n'
      'العنوان: القاهرة\n'
      'المندوب: محمد (12)\n'
      'الخدمة: ستائر\n'
      '--------------------\n'
      'الأصناف:\n'
      '- ستارة × 2\n'
      '   - 1.00 × 2.00 م = 20.00 ج.م\n'
      '   - 1.50 × 2.00 م = 36.00 ج.م\n'
      '   الإجمالي: 56.00 ج.م\n'
      '\n'
      '--------------------\n'
      'التوصيل: 15.00 ج.م\n'
      'الإجمالي: 71.00 ج.م\n'
      '\n'
      'ملاحظات: ملاحظة\n'
      '\n'
      'شكراً لثقتكم',
    );
  });

  test('buildInvoiceMessage hides delivery and notes when absent', () {
    final order = _pricedOrder(deliveryFee: 0, notes: null);

    final message = buildInvoiceMessage(order);

    expect(message, contains('الإجمالي: 56.00 ج.م'));
    expect(message, isNot(contains('التوصيل:')));
    expect(message, isNot(contains('ملاحظات:')));
  });

  test('buildInvoiceMessage shows unpriced items and pending total', () {
    final order = OrderModel(
      id: 'order-200',
      customerCode: 'C-200',
      customerName: 'عميل بدون تسعير',
      customerPhone: '01000000000',
      address: 'الجيزة',
      categoryName: 'ستائر',
      carNumber: '',
      driverName: '',
      items: const [OrderItemModel(name: 'ستارة', quantity: 1)],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 4, 9),
    );

    final message = buildInvoiceMessage(order);

    expect(message, contains('- ستارة × 1'));
    expect(message, contains('غير مسعّر بعد'));
    expect(message, contains('الإجمالي: لم يُسعّر بعد'));
    expect(message, contains('كود العميل: C-200'));
    expect(message, contains('رقم الفاتورة: 200'));
  });

  test('normalizePhone formats Egyptian numbers', () {
    expect(normalizePhone('201000000000'), '201000000000');
    expect(normalizePhone('01000000000'), '201000000000');
    expect(normalizePhone('1000000000'), '201000000000');
    expect(normalizePhone('+20 100 000 0000'), '201000000000');
    expect(normalizePhone('1234'), '');
  });

  test('sendInvoice throws when customer phone is missing', () async {
    final order = _pricedOrder();

    final invalidOrder = OrderModel(
      id: order.id,
      customerCode: order.customerCode,
      customerName: order.customerName,
      customerPhone: '',
      address: order.address,
      categoryName: order.categoryName,
      carNumber: order.carNumber,
      driverName: order.driverName,
      items: order.items,
      status: order.status,
      notes: order.notes,
      deliveryFee: order.deliveryFee,
      includeInCashbox: order.includeInCashbox,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
    );

    await expectLater(
      WhatsappInvoiceService.sendInvoice(invalidOrder),
      throwsA(isA<WhatsappInvoiceException>()),
    );
  });
}

OrderModel _pricedOrder({double deliveryFee = 15, String? notes = 'ملاحظة'}) {
  return OrderModel(
    id: 'order-100',
    customerCode: 'C-100',
    customerName: 'أحمد علي',
    customerPhone: '01000000000',
    address: 'القاهرة',
    categoryName: 'ستائر',
    carNumber: '12',
    driverName: 'محمد',
    items: const [
      OrderItemModel(
        name: 'ستارة',
        quantity: 2,
        units: [
          ItemUnitModel(width: 1, height: 2, unitPrice: 10),
          ItemUnitModel(width: 1.5, height: 2, unitPrice: 12),
        ],
      ),
    ],
    status: OrderStatus.completed,
    deliveryFee: deliveryFee,
    notes: notes,
    createdAt: DateTime(2026, 4, 9),
  );
}
