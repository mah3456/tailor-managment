# **تطبيق إدارة الخياطين (Tailor Management System) 🧵📱**

تطبيق Flutter متكامل لإدارة عملاء الخياطين، قطع العملاء، والمزامنة السحابية مع نظام المصادقة الحيوية.

![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3+-blue?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green?logo=supabase)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 📸 لقطات التطبيق

| الشاشة الرئيسية | إضافة عميل | تفاصيل العميل | إدارة القطع |
|----------------|-----------|--------------|------------|
| <img width="120" height="220" alt="home_screen" src="https://github.com/user-attachments/assets/2c727200-ba68-48d9-89b5-c2ba38240ede" />] 
|  <img width="120" height="200" alt="add_customer" src="https://github.com/user-attachments/assets/56b91f27-cf80-4bdb-a6f2-86930acfe947" />

| ![Customer Details]  <img width="1466" height="3101" alt="customer_details" src="https://github.com/user-attachments/assets/6d6ccfbc-7bc9-4395-9960-b14802c85693" />
| ![Manage Pieces](https://via.placeholder.com/300x600/F59E0B/FFFFFF?text=Manage+Pieces) |

| المصادقة بالبصمة | النسخ الاحتياطي | المدفوعات | الإعدادات |
|-----------------|----------------|-----------|----------|
| ![Fingerprint](https://via.placeholder.com/300x600/EF4444/FFFFFF?text=Fingerprint+Auth) | ![Backup](https://via.placeholder.com/300x600/3B82F6/FFFFFF?text=Cloud+Backup) | ![Payments](https://via.placeholder.com/300x600/EC4899/FFFFFF?text=Payments) | ![Settings](https://via.placeholder.com/300x600/6B7280/FFFFFF?text=Settings) |

## ✨ الميزات الرئيسية

### 🔐 **الأمان والمصادقة**
- **المصادقة بالبصمة** للوصول الآمن للتطبيق
- إعدادات أمان قابلة للتخصيص

### 👥 **إدارة العملاء**
- إضافة/تعديل/حذف العملاء
- عرض تفاصيل العملاء الكاملة
- تصفية وترتيب العملاء

### 👕 **إدارة قطع العملاء**
- إضافة/تعديل/حذف للقطع

### ☁️ **المزامنة السحابية**
- تخزين البيانات على **Supabase** (PostgreSQL)
- **تصدير واستيراد** البيانات من/إلى السحابة
- نسخ احتياطي تلقائي/يدوي
- حل النزاعات عند المزامنة

### 💰 **النظام المالي**
- تسجيل المدفوعات والدفعات المقدمة
- حساب المتبقي على كل عميل


## 🏗️ بنية المشروع

```
lib/
├── app/
│   ├── theme/
│   │   ├── theme.dart          # إعدادات السمة الرئيسية
│   │   ├── theme_data.dart     # بيانات الألوان والخطوط
│   │   └── env_config.dart     # إعدادات البيئة والمفاتيح
│   └── ...
├── data/
│   ├── models/
│   │   ├── customer_model.dart # نموذج بيانات العميل
│   │   └── piece_model.dart    # نموذج بيانات القطعة
│   └── services/
│       ├── database_helper.dart # قاعدة البيانات المحلية (SQLite)
│       └── supabase_service.dart # خدمة Supabase السحابية
├── FingPrint/
│   ├── AuthService.dart        # خدمة المصادقة بالبصمة
│   ├── AuthView.dart          # واجهة المصادقة
│   ├── controller.dart        # تحكم المصادقة
│   ├── Middleware.dart        # طبقة حماية المسارات
│   └── settings.dart          # إعدادات الأمان
├── presentation/
│   ├── controllers/
│   │   ├── backup/            # تحكم النسخ الاحتياطي
│   │   │   ├── backup_dashboard.dart
│   │   │   ├── customers_controller.dart
│   │   │   ├── Local_pieces.dart
│   │   │   └── pieces_backup_data.dart
│   │   ├── customer_controller.dart
│   │   ├── home_controller.dart
│   │   └── piece_controller.dart
│   └── views/
│       ├── backup/            # واجهات النسخ الاحتياطي
│       │   ├── backup_dashboard.dart
│       │   ├── backup_pieces_data.dart
│       │   ├── customers_data.dart
│       │   └── local_pieces.dart
│       ├── add_customer_view.dart
│       ├── add_piece_view.dart
│       ├── customer_details_page.dart
│       ├── home_view.dart
│       └── payment_view.dart
├── widgets/
│   ├── customer/
│   │   ├── edit_client.dart   # widget تعديل العميل
│   │   └── info_header.dart   # رأس معلومات العميل
│   └── pieces/
│       ├── pay_button.dart    # زر الدفع
│       └── show_pieces.dart   # عرض القطع
├── functions.dart             # دوال مساعدة
└── main.dart                  # نقطة دخول التطبيق
```

## ⚙️ متطلبات التشغيل

### المتطلبات الأساسية
- **Flutter SDK**: الإصدار 3.19 أو أعلى
- **Dart**: الإصدار 3.3 أو أعلى
- **Android**: API 23+ (Android 6.0+)
- **iOS**: iOS 11.0+

### التبعيات الرئيسية
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.1.0      # للتكامل مع Supabase
  local_auth: ^2.1.6           # للمصادقة بالبصمة
  sqflite: ^2.3.0              # قاعدة بيانات محلية
  Get: ^6.1.1             # إدارة الحالة
  intl: ^0.19.0                # التنسيق الدولي
  excel: ^2.0.0-null-safety-3  # تصدير Excel
```

## 🚀 التثبيت والإعداد

### 1. استنساخ المشروع
```bash
git clone https://github.com/yourusername/tailor-management-app.git
cd tailor-management-app
```

### 2. تثبيت التبعيات
```bash
flutter pub get
```

### 3. إعداد Supabase
1. أنشئ مشروع جديد على [Supabase](https://supabase.com)
2. احصل على `anon key` و `URL`
3. أنشئ الجداول التالية:
```sql
-- جدول العملاء
CREATE TABLE customers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- جدول القطع
CREATE TABLE pieces (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_phone REFERENCES customers(phone),
    type TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    paid  TEXT NOT NULL,
    length TEXT NOT NULL,
    width TEXT NOT NULL,
    notes TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);


### 4. تكوين البيئة
أنشئ ملف `.env` في مجلد `assets`:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 5. تشغيل التطبيق
```bash
flutter run
```

## 📱 كيفية الاستخدام

### التسجيل لأول مرة
1. قم بتشغيل التطبيق
2. سجل بصمتك للمصادقة
4. ابدأ بإضافة العملاء

### إضافة عميل جديد
1. من الشاشة الرئيسية، اضغط على زر "+"
2. املأ بيانات العميل
3. احفظ المعلومات

### إضافة قطعة خياطة
1. اختر العميل من القائمة
2. اضغط على "إضافة قطعة"
3. حدد نوع القطعة ومواصفاتها
4. عين السعر 

### النسخ الاحتياطي
1. انتقل إلى "ادراة النسخ الاحتياطي"
2. اختر "تصدير إلى السحابة"
4. تأكد من المزامنة الناجحة

## 🔧 التخصيص

### تغيير الألوان
قم بتعديل `app/theme/theme_data.dart`:
```dart
class AppColors {
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
}
```

## 🧪 الاختبار

```bash
# تشغيل جميع الاختبارات
flutter test

# اختبار واجهة معينة
flutter test test/presentation/views/home_view_test.dart

# اختبار الأداء
flutter drive --target=test_driver/app.dart
```

## 📦 بناء التطبيق

### بناء للأندرويد
```bash
flutter build apk --split-per-abi
```

### بناء لـ iOS
```bash
flutter build ios --release
```
