enum OrderSearchType {
  all('الكل'),
  invoice('رقم الفاتورة'),
  phone('رقم الموبايل'),
  name('اسم العميل');

  final String label;
  const OrderSearchType(this.label);
}
