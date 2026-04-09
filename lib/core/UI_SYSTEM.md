# UI/UX System Documentation

## نظام المكونات الاحترافي

هذا النظام يوفر مكونات معاد استخدامها بدون hardcoding، مع اتباع أفضل الممارسات في Flutter.

### الملفات والمجلدات

```
core/
├── constants/
│   ├── app_dimensions.dart  (spacing, sizes, animations)
│   ├── app_strings.dart     (جميع النصوص)
│   └── firebase_constants.dart
├── extensions/
│   └── extensions.dart      (BuildContext, TextStyle, Color helpers)
├── widgets/
│   ├── custom_button.dart   (buttons مع loading state)
│   ├── custom_card.dart     (cards و dialogs)
│   ├── custom_text_field.dart (input fields)
│   ├── state_widgets.dart   (loading, error, empty states)
│   └── widgets.dart         (exports)
└── theme/
    └── app_theme.dart       (Material Design 3 theme)
```

### استخدام سريع

#### 1️⃣ CustomButton
```dart
CustomButton(
  label: 'حفظ',
  onPressed: () => print('Pressed'),
  isLoading: false,
  isEnabled: true,
)

OutlineCustomButton(
  label: 'إلغاء',
  onPressed: () => Navigator.pop(context),
  leadingIcon: Icons.close,
)
```

#### 2️⃣ CustomTextField
```dart
CustomTextField(
  label: 'البريد الإلكتروني',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
)
```

#### 3️⃣ LoadingWidget
```dart
BlocListener<CategoryCubit, CategoryState>(
  listener: (context, state) {
    // Handle state
  },
  child: BlocBuilder<CategoryCubit, CategoryState>(
    builder: (context, state) => state is CategoryLoading
      ? const LoadingWidget(message: 'جاري التحميل...')
      : CategoryList(),
  ),
)
```

#### 4️⃣ ErrorWidget
```dart
state is CategoryError
  ? ErrorWidget(
      message: state.message,
      onRetry: () => context.read<CategoryCubit>().getCategories(),
    )
  : CategoryList()
```

#### 5️⃣ CustomCard
```dart
CustomCard(
  onTap: () => print('Card tapped'),
  padding: const EdgeInsets.all(AppDimensions.paddingLg),
  child: Column(
    children: [
      Text('Card Title', style: context.textTheme.headlineSmall),
      const SizedBox(height: AppDimensions.paddingMd),
      Text('Card content'),
    ],
  ),
)
```

#### 6️⃣ CustomDialog
```dart
showDialog(
  context: context,
  builder: (_) => CustomDialog(
    title: 'تأكيد',
    message: 'هل تريد الحذف؟',
    confirmLabel: 'حذف',
    cancelLabel: 'إلغاء',
    isDangerous: true,
    onConfirm: () => cubit.deleteItem(id),
  ),
)
```

### Extensions المفيدة

#### BuildContext Extensions
```dart
// الوصول السهل للـ theme
context.textTheme.headlineLarge
context.colorScheme.primary
context.theme.scaffoldBackgroundColor

// معلومات الشاشة
context.screenWidth    // عرض الشاشة
context.isSmallScreen  // هاتف؟
context.isMediumScreen // tablet؟
context.isLandscape    // landscape mode؟
```

#### Widget Extensions
```dart
// Padding سهل
CustomButton(label: 'Click').paddingSymmetric(horizontal: 16, vertical: 12)
Text('Hello').paddingAll(8)

// Center, Expanded, Flexible
CustomCard(child: Text('Content')).center().expanded()
```

### AppDimensions (الفراغات والأحجام)

| Variable | Value | الاستخدام |
|----------|-------|----------|
| `paddingSm` | 8.0 | فراغات أصغر |
| `paddingMd` | 12.0 | فراغ قياسي |
| `paddingLg` | 16.0 | فراغ أساسي |
| `radiusMd` | 12.0 | نصف قطر الحدود |
| `iconMd` | 24.0 | حجم الأيقونة |
| `elevationMd` | 4.0 | ارتفاع الظل |
| `durationNormal` | 300ms | مدة الرسوم المتحركة |

### ألوان الـ Theme (AppTheme)

- **Primary**: `#2563EB` — الزر الرئيسي، الـ AppBar
- **Secondary**: `#10B981` — Accent colors
- **Error**: `#DC2626` — رسائل الخطأ
- **Success**: `#10B981` — رسائل النجاح
- **Warning**: `#F59E0B` — تنبيهات

### قواعد الاستخدام

✅ **افعل:**
- استخدم `AppDimensions` للـ spacing
- استخدم `CustomButton` & `CustomTextField` بدلاً من البناء من الصفر
- استخدم extensions للوصول السهل للـ theme
- استخدم `LoadingWidget`, `ErrorWidget`, `EmptyStateWidget` للـ states

❌ **لا تفعل:**
- لا تستخدم hardcoded padding/margin قيم (مثل `12.0` مباشرة)
- لا تكرر الـ TextField أو Button styling
- لا تضع أيقونات في الـ UI مباشرة بدون Icon class
- لا تستخدم قيم ألوان hardcoded

### ملاحظات مهمة

1. **الأداء**: جميع الـ widgets تستخدم `const` constructors حيث يمكن
2. **RTL**: الـ app يدعم العربية بشكل كامل
3. **Material Design 3**: الـ theme يتبع معايير Google الحديثة
4. **State Management**: استخدم Cubit فقط للـ data flow، لا تضع business logic في UI
5. **مشاركة المكونات**: أي مكون مستخدم في أكثر من feature يجب أن يكون في `core/widgets`

---

**آخر تحديث:** April 8, 2026
