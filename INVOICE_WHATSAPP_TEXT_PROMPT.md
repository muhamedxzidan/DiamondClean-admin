# برومت كامل: التراجع عن محاولة الصورة + تطبيق إرسال الفاتورة كرسالة نصية على واتساب

## السياق
أنا كنت بحاول أستبدل آلية إرسال فاتورة الـ PDF بصورة PNG مولّدة من Flutter widget، وعملت أجزاء كتيرة في النص. الفكرة دي **اتلغت بالكامل**. عايز:
1. **التراجع** عن كل اللي اتعمل لمحاولة الصورة وحذف الملفات اللي مالهاش لازمة.
2. **تطبيق حل بديل**: إرسال الفاتورة كـ **رسالة نصية منسقة على واتساب** عن طريق `wa.me/<phone>?text=<message>`.

## المشروع
- Flutter app اسمه **Diamond Clean**.
- Working directory: `/home/m-zidan/my app/diamond_clean/diamond_clean`
- يتبع **2-layer architecture** صارم: `cubit/`, `data/`, `presentation/`.
- ❌ لا domain، لا repositories، لا use cases، لا Either.
- اقرأ `CLAUDE.md` في جذر المشروع والتزم بكل قواعده (خصوصاً: أقل تغيير ممكن، files صغيرة، const constructors، import ordering، no business logic in UI، الكود المشترك في `core/`).

## المرحلة 1: تنظيف وحذف بقايا محاولة الصورة

### 1) جرد ما هو موجود حالياً
- اقرأ `lib/core/utils/whatsapp_invoice_service.dart` كامل لتفهم وضعه الحالي (PDF ولا اتعدّل لصورة؟).
- ابحث في كل المشروع (`lib/`, `test/`) عن أي ملفات/كلاسات مرتبطة بمحاولة الصورة:
  - `RepaintBoundary`, `boundary.toImage`, `OverlayEntry` (لو أُضيفت لغرض الفاتورة)
  - أي ملف اسمه فيه `invoice_card`, `invoice_image`, `invoice_widget`, `invoice_renderer`, أو شبيه
  - أي import لـ `share_plus` أُضيف حديثاً
  - أي helper widgets أُنشئت في `lib/core/widgets/` لغرض رسم الفاتورة
- اعرض عليّ قائمة بالملفات المرشحة للحذف **قبل** ما تحذف أي حاجة، عشان أوافق.

### 2) احذف كل ما يخص محاولة الصورة
بعد موافقتي:
- احذف ملفات widget الفاتورة المُنشأة (invoice_card.dart وأي ملفات فرعية).
- احذف أي helpers أو services أُضيفت لغرض الـ off-screen rendering.
- شيل dependency `share_plus` من `pubspec.yaml` لو اتضافت ومش مستخدمة في مكان تاني.
- شيل أي imports غير مستخدمة من call sites.

### 3) قرر مصير الـ PDF القديم
- `pdf`, `printing`, `path_provider` في `pubspec.yaml` — ابحث في كل المشروع لو فيه استخدام تاني ليهم خارج `whatsapp_invoice_service.dart`.
- لو مفيش استخدام تاني، شيلهم من `pubspec.yaml`.
- خط `Amiri` في assets — لو مش مستخدم في مكان تاني (غير الـ PDF)، اسألني قبل حذف ملفات الخط.
- في `android/app/src/main/kotlin/com/example/diamond_clean/MainActivity.kt` فيه MethodChannel `diamond_clean/whatsapp` لإرسال PDF — مش هيُستخدم في الحل الجديد. اعرض عليّ محتواه واقترح إزالته (لا تحذف بدون إذن).

## المرحلة 2: تطبيق الحل الجديد (رسالة نصية على واتساب)

### الفكرة
نبني نص فاتورة منسق بشكل جميل (emojis + فواصل) ونفتح واتساب مباشرة عند رقم العميل بالنص جاهز عبر `https://wa.me/<phone>?text=<encoded>` باستخدام `url_launcher` (موجود بالفعل في `pubspec.yaml`).

### 1) أعد كتابة `lib/core/utils/whatsapp_invoice_service.dart` بالكامل
- اسم الكلاس يفضل `WhatsappInvoiceService` (للحفاظ على call sites — أقل تغيير).
- API بسيط:
  ```dart
  static Future<void> sendInvoice(OrderModel order);
  ```
- داخلياً:
  1. ابني نص الفاتورة باستخدام دالة `_buildInvoiceMessage(OrderModel order)` (private، pure function، قابلة للاختبار).
  2. طبّع رقم العميل لصيغة دولية (مصر: `20XXXXXXXXXX`) — احتفظ بمنطق `_normalizePhone` الموجود حالياً.
  3. لو الرقم مش صالح: ارمي exception واضح.
  4. ابني الـ URI: `Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}')`.
  5. افتحه بـ `url_launcher`:
     ```dart
     await launchUrl(uri, mode: LaunchMode.externalApplication);
     ```
  6. لو فشل الفتح: ارمي exception واضح.
- لا state، لا caching، لا dependencies على Flutter widgets — فقط dart + url_launcher.
- ملف صغير ومركز (target: < 150 سطر).

### 2) شكل النص المقترح
```
🧾 *Diamond Clean*
رقم الفاتورة: #{id}
التاريخ: {yyyy/MM/dd}
━━━━━━━━━━━━━━
👤 العميل: {name}
📞 الهاتف: {phone}
📍 العنوان: {address}
🚗 المندوب: {driver} ({car})
🧰 الخدمة: {category}
━━━━━━━━━━━━━━
*الأصناف:*
• {itemName} × {qty}
   - {w} × {h} م = {amount} ج.م
   - {w} × {h} م = {amount} ج.م
   الإجمالي: {itemTotal} ج.م

• {itemName2} × {qty}
   ...
━━━━━━━━━━━━━━
🚚 التوصيل: {fee} ج.م
💰 *الإجمالي: {total} ج.م*

📝 ملاحظات: {notes}

شكراً لثقتكم 💎
```
- لو الـ delivery fee = 0، لا تعرض السطر.
- لو الـ notes فاضية أو null، لا تعرض السطر.
- لو الصنف مش مسعّر، اعرض "غير مسعّر بعد" بدل التفاصيل.
- لو الإجمالي null، اعرض "لم يُسعّر بعد".

### 3) حدّث call sites
- `lib/features/orders/presentation/widgets/print_preview_dialog.dart`:
  - شيل زرار "طباعة PDF" بالكامل (والـ import لـ `printing`) — هو ميعملش معنى مع الحل الجديد. **اسألني قبل حذف الزرار** لو شاكك.
  - زرار واتساب يفضل ينادي `WhatsappInvoiceService.sendInvoice(widget.order)` زي ما هو.
  - غيّر أيقونة الزرار من `Icons.picture_as_pdf_outlined` إلى `Icons.chat_outlined` أو `Icons.message_outlined`.
- `lib/features/orders/presentation/widgets/order_pricing_dialog.dart`: تأكد إن الاستدعاء لسه شغّال.
- `lib/features/orders/presentation/screens/orders_screen.dart`: تأكد إن الاستدعاء لسه شغّال.
- معالجة الأخطاء في الـ presentation: عرض snackbar بـ "تعذّر إرسال الفاتورة، تأكد من تثبيت واتساب ومن صحة رقم العميل".

### 4) حدّث الاختبارات
- `test/core/utils/whatsapp_invoice_service_test.dart`:
  - شيل أي اختبارات تخص PDF bytes أو `buildInvoicePdfBytes` أو `buildInvoiceData` (لو الدوال دي اتشالت).
  - أضف اختبارات للـ `_buildInvoiceMessage` (هتحتاج تخليها `@visibleForTesting` أو تستخرجها لـ top-level function في نفس الملف):
    - حالة طلب مسعّر بالكامل
    - حالة طلب غير مسعّر
    - حالة بدون توصيل
    - حالة بدون ملاحظات
    - حالة عميل بدون رقم → exception
  - اختبارات لـ `_normalizePhone` (مصر، يبدأ بـ 20، يبدأ بـ 0، إلخ).

## قواعد صارمة
- **اقرأ كل ملف قبل تعديله أو حذفه** — لا تخمن المحتوى.
- **اسألني قبل أي حذف** لملفات أو dependencies أو assets.
- **أقل تغيير ممكن** — لا ترفاكتر كود مالوش علاقة.
- التزم بـ import ordering: Dart → Flutter → Package → Project (سطر فاضي بين كل مجموعة).
- لا comments إلا لو النية مش واضحة.
- const constructors في كل حتة ممكنة.
- لا business logic في UI.
- الخدمة في `core/` — لا تعتمد على أي feature.

## خطة التنفيذ المطلوبة منك
نفّذها بالترتيب ده، **وقف عند كل checkpoint** للحصول على موافقتي:

1. **Checkpoint 1 — جرد**: اعرض قائمة كاملة بـ:
   - الملفات اللي هتحذف (محاولة الصورة)
   - Dependencies اللي هتشيل
   - Assets اللي شاكك فيها
   - الـ MainActivity.kt MethodChannel وقرارك بشأنه
   ⏸️ **انتظر موافقتي**.

2. **Checkpoint 2 — تنظيف**: نفّذ كل عمليات الحذف اللي وافقت عليها. اعرض الملفات اللي اتحذفت.
   ⏸️ **انتظر موافقتي**.

3. **Checkpoint 3 — إعادة كتابة الخدمة**: اكتب `whatsapp_invoice_service.dart` الجديد. اعرضه عليّ.
   ⏸️ **انتظر موافقتي**.

4. **Checkpoint 4 — تحديث call sites**: حدّث الـ 3 ملفات (print_preview_dialog، order_pricing_dialog، orders_screen).
   ⏸️ **انتظر موافقتي**.

5. **Checkpoint 5 — اختبارات**: حدّث/أعد كتابة الاختبارات.

6. **Checkpoint 6 — تحقق نهائي**: شغّل `flutter analyze` و `flutter test` واعرض النتائج.

## التحقق النهائي
- [ ] `flutter analyze` بدون errors/warnings
- [ ] `flutter test` كل الاختبارات تمر
- [ ] لا imports غير مستخدمة
- [ ] لا dependencies ميتة في `pubspec.yaml`
- [ ] الـ call sites الـ 3 شغّالة
- [ ] المعمارية محفوظة (2-layer)
- [ ] الكود نظيف ومختصر

## التسليم
بعد ما أوافق إن المهمة تمت، قدّم:
- **Branch name**: `refactor/invoice-as-whatsapp-text-message`
- **Commit message** (conventional commits format)
- **PR title** قصير وواضح
- **PR description** بصيغة markdown مختصرة فيها:
  - Summary (إيه اللي اتعمل)
  - Motivation (ليه — مشاكل PDF + محاولة الصورة المُلغاة)
  - Changes (الملفات المعدّلة/المحذوفة)
