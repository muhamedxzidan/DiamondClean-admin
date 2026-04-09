import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:diamond_clean/features/orders/data/models/order_model.dart';

class WhatsappInvoiceService {
  const WhatsappInvoiceService._();

  static Future<void> sendInvoice(OrderModel order) async {
    final message = buildInvoiceMessage(order);
    final phone = normalizePhone(order.customerPhone);

    if (phone.isEmpty) {
      throw const WhatsappInvoiceException('رقم العميل غير صحيح أو غير موجود');
    }

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    late final bool launched;

    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      throw const WhatsappInvoiceException(
        'تعذّر فتح واتساب. تأكد من تثبيته على الجهاز.',
      );
    }

    if (!launched) {
      throw const WhatsappInvoiceException(
        'تعذّر فتح واتساب. تأكد من تثبيته على الجهاز.',
      );
    }
  }
}

@visibleForTesting
String buildInvoiceMessage(OrderModel order) {
  final buffer = StringBuffer()
    ..writeln('Diamond Clean')
    ..writeln('رقم الفاتورة: ${_formatOrderNumber(order.id)}')
    ..writeln('التاريخ: ${_formatDate(order.createdAt)}')
    ..writeln('--------------------')
    ..writeln('العميل: ${order.customerName}')
    ..writeln('كود العميل: ${_formatValue(order.customerCode)}')
    ..writeln('الهاتف: ${order.customerPhone}');

  if (order.address.trim().isNotEmpty) {
    buffer.writeln('العنوان: ${order.address.trim()}');
  }
  if (order.driverName.trim().isNotEmpty || order.carNumber.trim().isNotEmpty) {
    buffer.writeln(
      'المندوب: ${_formatValue(order.driverName)} (${_formatValue(order.carNumber)})',
    );
  }
  if (order.categoryName.trim().isNotEmpty) {
    buffer.writeln('الخدمة: ${order.categoryName.trim()}');
  }

  buffer.writeln('--------------------');
  buffer.writeln('الأصناف:');
  if (order.items.isEmpty) {
    buffer.writeln('- لا توجد أصناف');
  } else {
    for (final item in order.items) {
      buffer.writeln('- ${item.name} × ${item.quantity}');
      if (!item.hasPricing) {
        buffer.writeln('   غير مسعّر بعد');
      } else {
        for (final unit in item.expandedUnits) {
          buffer.writeln(
            '   - ${_formatMeasure(unit.width)} × ${_formatMeasure(unit.height)} م = ${_formatMoney(unit.total)}',
          );
        }
        buffer.writeln('   الإجمالي: ${_formatMoney(item.itemTotal)}');
      }
      buffer.writeln();
    }
  }

  buffer.writeln('--------------------');
  if (order.deliveryFee > 0) {
    buffer.writeln('التوصيل: ${_formatMoney(order.deliveryFee)}');
  }
  buffer.writeln(
    'الإجمالي: ${order.totalPrice != null ? _formatMoney(order.totalPrice) : 'لم يُسعّر بعد'}',
  );

  if (order.notes != null && order.notes!.trim().isNotEmpty) {
    buffer.writeln();
    buffer.writeln('ملاحظات: ${order.notes!.trim()}');
  }

  buffer.writeln();
  buffer.writeln('شكراً لثقتكم');
  return buffer.toString().trimRight();
}

@visibleForTesting
String normalizePhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';

  if (digits.startsWith('20') && digits.length == 12) return digits;
  if (digits.startsWith('0') && digits.length == 11) {
    return '20${digits.substring(1)}';
  }
  if (digits.length == 10) return '20$digits';

  return '';
}

String _formatDate(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year/$month/$day';
}

String _formatValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? 'غير محدد' : trimmed;
}

String _formatOrderNumber(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 'غير متاح' : digits;
}

String _formatMeasure(double? value) => value?.toStringAsFixed(2) ?? '-';

String _formatMoney(double? value) {
  return value == null ? 'لم يُسعّر بعد' : '${value.toStringAsFixed(2)} ج.م';
}

class WhatsappInvoiceException implements Exception {
  final String message;

  const WhatsappInvoiceException(this.message);

  @override
  String toString() => message;
}
