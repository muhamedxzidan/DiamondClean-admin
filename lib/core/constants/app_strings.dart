class AppStrings {
  // App
  static const String appName = 'Diamond Clean — Admin';

  // Auth
  static const String loginTitle = 'تسجيل الدخول';
  static const String loginButton = 'دخول';
  static const String logout = 'تسجيل الخروج';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String invalidCredentials =
      'بريد إلكتروني أو كلمة مرور غير صحيحة';

  // Navigation
  static const String dashboard = 'لوحة التحكم';
  static const String categories = 'الأصناف';
  static const String cars = 'السيارات';
  static const String orders = 'الطلبات';
  static const String customers = 'العملاء';
  static const String employees = 'الموظفون';
  static const String cashbox = 'الخزنة';

  // Employees
  static const String employeesTitle = 'الموظفون';
  static const String employeesSearchHint = 'ابحث باسم الموظف أو رقم الهاتف';
  static const String employeesEmpty = 'لا يوجد موظفون مضافون حتى الآن';
  static const String employeesAddEmployee = 'إضافة موظف';
  static const String employeesName = 'اسم الموظف';
  static const String employeesNationalId = 'الرقم القومي (اختياري)';
  static const String employeesCity = 'المدينة (اختياري)';
  static const String employeesSalaryCycle = 'دورة الراتب';
  static const String employeesSalaryAmount = 'قيمة الراتب';
  static const String employeesSalaryValidation = 'أدخل قيمة راتب صحيحة';
  static const String employeesSaved = 'تم حفظ بيانات الموظف';
  static const String employeesRemaining = 'المتبقي';
  static const String employeesAdvancesTotal = 'إجمالي السلف بالدورة';
  static const String employeesAdvancesCount = 'عدد مرات السلف';
  static const String employeesAddAdvance = 'إضافة سلفة';
  static const String employeesAdvanceAmount = 'قيمة السلفة';
  static const String employeesAdvanceValidation = 'أدخل قيمة سلفة صحيحة';
  static const String employeesAdvanceNote = 'ملاحظة';
  static const String employeesAdvanceAdded = 'تم تسجيل السلفة';
  static const String employeesAdvanceHistory = 'سجل السلف';
  static const String employeesNoAdvances = 'لا توجد سلف لهذا الموظف';
  static const String employeesNoNote = 'بدون ملاحظة';
  static const String employeesWarningTitle = 'تحذير';
  static const String employeesAmountExceedsRemaining =
      'المبلغ أكبر من المتبقي';
  static const String employeesPaySalary = 'قبض';
  static const String employeesPaidTotal = 'إجمالي المقبوض بالدورة';
  static const String employeesSalaryOutstanding = 'المتبقي للقبض';
  static const String employeesPayoutAdded = 'تم تسجيل القبض';
  static const String employeesPayoutMode = 'نوع القبض';
  static const String employeesPayoutFull = 'قبض كامل المتبقي';
  static const String employeesPayoutPartial = 'قبض جزء';
  static const String employeesPayoutAmount = 'مبلغ القبض';
  static const String employeesPayoutAmountValidation = 'أدخل مبلغ قبض صحيح';
  static const String employeesPayoutNote = 'ملاحظة قبض (اختياري)';

  static String employeesAdvanceRejected(double requested, double remaining) =>
      'السلفة (${requested.toStringAsFixed(2)} ج.م) أكبر من المتبقي (${remaining.toStringAsFixed(2)} ج.م)';

  static String employeesSalaryPayoutRejected(
    double requested,
    double remaining,
  ) =>
      'مبلغ القبض (${requested.toStringAsFixed(2)} ج.م) أكبر من المتبقي (${remaining.toStringAsFixed(2)} ج.م)';

  // Categories
  static const String categoriesTitle = 'الأصناف';
  static const String addCategory = 'إضافة صنف';
  static const String editCategory = 'تعديل صنف';
  static const String deleteCategory = 'حذف صنف';
  static const String categoryName = 'اسم الصنف';
  static const String noCategoriesFound = 'لا توجد أصناف';

  // Cars
  static const String carsTitle = 'السيارات';
  static const String addCar = 'إضافة سيارة';
  static const String editCar = 'تعديل سيارة';
  static const String deleteCar = 'حذف سيارة';
  static const String carNumber = 'رقم السيارة';
  static const String carPassword = 'كلمة مرور السيارة';
  static const String driverName = 'اسم المندوب';
  static const String carActive = 'نشطة';
  static const String carInactive = 'غير نشطة';
  static const String noCarsFound = 'لا توجد سيارات';
  static const String activateCar = 'تفعيل السيارة';
  static const String deactivateCar = 'إيقاف السيارة';
  static const String confirmDeactivateCar =
      'هل أنت متأكد من إيقاف هذه السيارة؟ لن يتمكن المندوب من استخدام التطبيق.';
  static const String confirmActivateCar = 'هل أنت متأكد من تفعيل هذه السيارة؟';

  // Orders
  static const String ordersTitle = 'الطلبات';
  static const String ordersSearchHint = 'ابحث برقم الهاتف أو الكود';
  static const String noOrdersFound = 'لا توجد طلبات';
  static const String noMatchingOrders = 'لا توجد طلبات مطابقة';
  static const String deliveryFee = 'التوصيل الدليفري';
  static const String orderPrice = 'السعر';
  static const String editPrice = 'تعديل السعر';
  static const String printOrder = 'طباعة الطلب';
  static const String noPriceSet = 'لم يُحدد السعر بعد';
  static const String orderRef = 'رقم الفاتورة';
  static const String currency = 'ج.م';
  static const String enterPrice = 'أدخل السعر';
  static const String statusPending = 'مرحله الغسيل قيد الانتظار';
  static const String statusConfirmed = 'تم الغسيل';
  static const String statusCompleted = 'تم التسليم';
  static const String statusCancelled = 'ملغي';
  static const String statusAll = 'الكل';
  static const String updateStatus = 'تحديث الحالة';
  static const String paymentMethodTitle = 'طريقة السداد';
  static const String paymentMethodCash = 'نقدي';
  static const String paymentMethodVodafoneCash = 'فودافون كاش';
  static const String paymentMethodInstapay = 'إنستا باي';
  static const String paymentMethodChoose = 'اختر طريقة السداد';
  static const String orderDetails = 'تفاصيل الطلب';
  static const String orderCustomer = 'العميل';
  static const String orderPhone = 'الهاتف';
  static const String orderAddress = 'العنوان';
  static const String orderService = 'الخدمة';
  static const String orderDriver = 'المندوب';
  static const String orderDate = 'التاريخ';
  static const String orderItems = 'الأصناف';
  static const String noItemsFound = 'لا توجد أصناف';
  static const String itemWidth = 'العرض (متر)';
  static const String itemHeight = 'الطول (متر)';
  static const String itemUnitPrice = 'سعر المتر';
  static const String itemTotal = 'الإجمالي';
  static const String orderTotal = 'إجمالي الطلب';
  static const String addPricing = 'تسعير الصنف';
  static const String notPricedYet = 'لم يُسعّر بعد';
  static const String piece = 'قطعة';
  static const String meter = 'م';
  static const String pricingAllItems = 'تسعير الأصناف';
  static const String unitLabel = 'القطعة';
  static const String quickPrint = 'طباعة سريعة';
  static const String sendWhatsapp = 'إرسال فاتورة';
  static const String whatsappNoPhone = 'لا يوجد رقم هاتف للعميل';

  // Partial Payment
  static const String paymentTypeFull = 'دفع كامل';
  static const String paymentTypePartial = 'دفع جزئي';
  static const String paymentTypeLabel = 'نوع الدفع';
  static const String paidAmountLabel = 'المبلغ المدفوع';
  static const String paidAmountHint = 'أدخل المبلغ المدفوع';
  static const String remainingAmountLabel = 'المتبقي';
  static const String payRemaining = 'سداد المتبقي';
  static const String orderFullyPaid = 'تم السداد الكامل';
  static const String orderPartiallyPaid = 'دفع جزئي';
  static const String outstandingOrders = 'عليها متبقي';
  static const String confirmRemainingPayment = 'تأكيد سداد المتبقي';
  static const String paidLabel = 'المدفوع';
  static const String invalidPaidAmount = 'المبلغ المدفوع غير صحيح';
  static const String paidAmountExceedsTotal = 'المبلغ المدفوع أكبر من الإجمالي';

  // Cashbox
  static const String cashboxTitle = 'الخزنة';
  static const String cashboxOpeningBalance = 'الرصيد الافتتاحي';
  static const String cashboxCurrentBalance = 'الرصيد الحالي';
  static const String cashboxDailyRevenue = 'إيراد اليوم';
  static const String cashboxDailyExpenses = 'مصروفات اليوم';
  static const String cashboxDailyNet = 'صافي اليوم';
  static const String cashboxSessionRevenue = 'إيراد الجلسة الحالية';
  static const String cashboxSessionExpenses = 'مصروفات الجلسة الحالية';
  static const String cashboxSetOpeningBalance = 'تحديد رصيد افتتاحي';
  static const String cashboxOpenedBy = 'تم الفتح بواسطة';
  static const String cashboxExpenseName = 'اسم المصروف';
  static const String cashboxExpenseAmount = 'قيمة المصروف';
  static const String cashboxAddExpense = 'إضافة مصروف';
  static const String cashboxEditExpense = 'تعديل مصروف';
  static const String cashboxClose = 'تصفير الخزنة';
  static const String cashboxClosedBy = 'تم التصفير بواسطة';
  static const String cashboxLastClose = 'آخر إقفال';
  static const String cashboxNoExpenses = 'لا توجد مصروفات لهذا اليوم';
  static const String cashboxNoClosures = 'لا يوجد سجل إقفال حتى الآن';
  static const String cashboxIncludeInCashbox = 'احتساب في الخزنة';
  static const String cashboxReport = 'التقرير اليومي';
  static const String cashboxDeliveredOrders = 'الأوردرات المسلّمة';
  static const String cashboxExpenseHistory = 'سجل المصروفات';
  static const String cashboxPaymentMethod = 'طريقة السداد';
  static const String cashboxUnknownPaymentMethod = 'غير محدد';
  static const String cashboxCloseTodayCta = 'إقفال الخزنة اليوم 🔒';
  static const String cashboxConfirmClose = 'تأكيد الإقفال';
  static const String cashboxNetToday = 'صافي اليوم';
  static const String cashboxClosuresLog = 'سجل الإقفالات';
  static const String cashboxTreasuryLog = 'سجل حركات الخزنة';
  static const String cashboxClosedByLabel = 'من أقفل';
  static const String cashboxClosedAtLabel = 'التوقيت';
  static const String cashboxClosedAmountLabel = 'المبلغ المُقفَل';
  static const String cashboxEventType = 'النوع';
  static const String cashboxEventTime = 'التوقيت';
  static const String cashboxEventAmount = 'المبلغ';
  static const String cashboxEventNote = 'ملاحظة';
  static const String cashboxEventOrderIncome = 'إيراد أوردر';
  static const String cashboxEventOrderFullPayment = 'سداد أوردر كامل';
  static const String cashboxEventOrderPartialPayment = 'دفعة مبدئية لأوردر';
  static const String cashboxEventOrderRemainingPayment = 'سداد متبقي أوردر';
  static const String cashboxEventExpense = 'مصروف';
  static const String cashboxEventClosure = 'إقفال';
  static const String cashboxNoLogEntries = 'لا توجد حركات مسجلة';
  static const String cashboxOrderCount = 'أوردر';
  static const String cashboxDeliveredOrdersToday = 'الأوردرات المسلَّمة اليوم';
  static const String cashboxClosedByRequired = 'يجب كتابة اسم من يقفل الخزنة';
  static const String cashboxClosureOpeningBalance = 'الرصيد الافتتاحي';
  static const String cashboxClosureTotalRevenue = 'إجمالي الإيرادات';
  static const String cashboxClosureTotalExpenses = 'إجمالي المصروفات';
  static const String cashboxClosureOrdersCount = 'عدد الأوردرات';
  static const String cashboxClosureExpensesBreakdown = 'تفصيل المصروفات';
  static const String cashboxRemainingAmount = 'الباقي';
  static const String cashboxPartialPayment = 'دفع جزئي';

  // Developer
  static const String developerTitle = 'عن المبرمج';
  static const String developerSubtitle = 'روابط التواصل';
  static const String developerFacebook = 'فيسبوك';
  static const String developerWhatsapp = 'واتساب';
  static const String developerLinkedIn = 'لينكدإن';
  static const String developerEmail = 'البريد الإلكتروني';
  static const String developerOpenLink = 'فتح الرابط';

  // Customers
  static const String customersTitle = 'العملاء';
  static const String customersSearchHint = 'ابحث بالكود أو رقم الهاتف';
  static const String customersEmptyState =
      'لا توجد عملاء مسجلة بعد من الطلبات';
  static const String customerPhone = 'رقم الهاتف';
  static const String customerAddress = 'العنوان';
  static const String customerVisits = 'عدد مرات الغسيل';
  static const String customerTotalSpent = 'إجمالي المبالغ';
  static const String firstVisit = 'أول تعامل';
  static const String lastVisit = 'آخر تعامل';
  static const String customerTransactionHistory = 'سجل الطلبات';
  static const String noCustomerTransactions =
      'لا توجد طلبات مسجلة لهذا العميل';

  // General
  static const String confirm = 'تأكيد';
  static const String cancel = 'إلغاء';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String success = 'تم بنجاح';
  static const String tryAgain = 'حاول مجدداً';
  static const String confirmDeleteMessage =
      'هل أنت متأكد من الحذف؟ لا يمكن التراجع عن هذا الإجراء.';
  static const String fieldRequired = 'هذا الحقل مطلوب';

  // Expense Category
  static const String cashboxExpenseCategory = 'نوع المصروف';

  // Treasury Report
  static const String treasuryReportTitle = 'تقرير الخزنة';
  static const String treasuryReportSelectPeriod = 'اختر فترة زمنية';
  static const String treasuryReportToday = 'اليوم';
  static const String treasuryReportWeek = 'الأسبوع';
  static const String treasuryReportMonth = 'الشهر';
  static const String treasuryReportThreeMonths = '3 شهور';
  static const String treasuryReportCustom = 'مخصص';
  static const String treasuryReportCashSummary = 'ملخص الخزنة';
  static const String treasuryReportOpeningBalance = 'رصيد الافتتاح';
  static const String treasuryReportTotalIncome = 'إجمالي الداخل';
  static const String treasuryReportTotalOutgoing = 'إجمالي الخارج';
  static const String treasuryReportClosingBalance = 'رصيد الإغلاق';
  static const String treasuryReportRevenue = 'الإيرادات';
  static const String treasuryReportOrdersRevenue = 'دخل الأوردرات المسلّمة';
  static const String treasuryReportDeliveryFees = 'رسوم التوصيل';
  static const String treasuryReportCashPayments = 'مدفوعات نقدية';
  static const String treasuryReportElectronicPayments = 'مدفوعات إلكترونية';
  static const String treasuryReportExpenses = 'المصاريف';
  static const String treasuryReportExpensesByCategory = 'تفصيل المصاريف';
  static const String treasuryReportOrders = 'الأوردرات';
  static const String treasuryReportCompleted = 'مسلّمة';
  static const String treasuryReportPending = 'في الانتظار';
  static const String treasuryReportConfirmed = 'تم الغسيل';
  static const String treasuryReportCancelled = 'ملغية';
  static const String treasuryReportProfitLoss = 'الربح والخسارة';
  static const String treasuryReportNetProfit = 'صافي الربح';
  static const String treasuryReportPendingValue = 'قيمة الأوردرات المعلّقة';

  // Cashbox PIN
  static const String cashboxPinLocked = 'الخزنة محمية';
  static const String cashboxPinEnterPrompt = 'أدخل الباسورد للدخول';
  static const String cashboxPinHint = 'الباسورد (4 أرقام)';
  static const String cashboxPinUnlock = 'دخول';
  static const String cashboxPinWrong = 'باسورد غير صحيح';
  static const String cashboxPinSet = 'تحديد باسورد للخزنة';
  static const String cashboxPinChange = 'تغيير الباسورد';
  static const String cashboxPinRemove = 'إزالة الباسورد';
  static const String cashboxPinNewHint = 'الباسورد الجديد (4 أرقام)';
  static const String cashboxPinCurrentHint = 'الباسورد الحالي';
  static const String cashboxPinConfirmHint = 'تأكيد الباسورد الجديد';
  static const String cashboxPinMismatch = 'الباسورد غير متطابق';
  static const String cashboxPinSaved = 'تم حفظ الباسورد';
  static const String cashboxPinRemoved = 'تم إزالة الباسورد';
}
