# Cabinet Finger Joint Plugin for SketchUp

**نمایه‌های اتصال کابینت با فینجر جوینت**

## 📋 مشخصات (Specifications)

### Features
- ✅ **Interactive Workflow**: مرحله به مرحله انتخاب کمپوننت‌ها
- ✅ **Live Preview**: پیش‌نمایش قبل از اعمال
- ✅ **2 Fingers**: یکی جلویی، یکی عقبی
- ✅ **12cm Finger Length**: طول انگشت 120 میلی‌متر
- ✅ **8mm Width**: عرض 8 میلی‌متر
- ✅ **10mm Pocket Depth**: عمق جای انگشت 10 میلی‌متر
- ✅ **0.5mm Clearance**: فضای خالی برای جای خالی
- ✅ **6cm Edge Distance**: فاصله 60 میلی‌متر از لبه‌ها
- ✅ **Symmetrical**: متقارن روی قطعه شلف
- ✅ **Auto Pocket Creation**: ایجاد خودکار جای‌های انگشت روی بدنه

## 🔧 نصب (Installation)

### Windows
1. فایل `cabinet_finger_joint.rb` را دانلود کنید
2. این مسیر را باز کنید:
   ```
   C:\Users\YOUR_USERNAME\AppData\Roaming\SketchUp\SketchUp 2023\SketchUp\Plugins
   ```
   (یا نسخه SketchUp شما را جایگزین کنید)
3. فایل `cabinet_finger_joint.rb` را در این پوشه قرار دهید
4. SketchUp را دوباره شروع کنید

### Mac
1. فایل `cabinet_finger_joint.rb` را دانلود کنید
2. Finder → Applications → SketchUp
3. روی SketchUp راست‌کلیک → Show Package Contents
4. به این مسیر برید: `Contents/Resources/en-US/Plugins`
5. فایل را اینجا قرار دهید
6. SketchUp را دوباره شروع کنید

## 📖 راهنمای استفاده (Usage Guide)

### مرحله‌ها (Steps)

1. **در SketchUp مدل خودتان را باز کنید**
   - داخل مدل باید 2 کمپوننت وجود داشته باشند:
     - `bace part` (بدنه کابینت)
     - `shelf` (قطعه شلف)

2. **منوی Plugins را باز کنید**
   - Plugins → Cabinet Finger Joint

3. **مرحله 1: بدنه را انتخاب کنید**
   - OK روی پیام کلیک کنید
   - کمپوننت `bace part` را در مدل کلیک کنید

4. **مرحله 2: شلف را انتخاب کنید**
   - OK روی پیام کلیک کنید
   - کمپوننت `shelf` را در مدل کلیک کنید

5. **ابعاد را بررسی کنید**
   - پلاگین ابعاد تشخیص داده شده را نمایش می‌دهد
   - OK کلیک کنید

6. **پیش‌نمایش را بررسی کنید**
   - انگشت‌ها در Preview نمایش داده می‌شوند
   - اگر درست بود: Yes کلیک کنید
   - اگر غلط بود: No کلیک کنید

7. **نتیجه نهایی**
   - انگشت‌ها روی شلف ایجاد می‌شوند
   - جای‌های انگشت روی بدنه حفر می‌شوند

## 📏 ابعاد و مشخصات (Dimensions)

```
انگشت‌ها (Fingers):
├── طول (Length): 120 mm (12 cm)
├── عرض (Width): 8 mm
├── عمق (Depth): 10 mm
└── تعداد: 2 عدد (Front + Back)

فاصله از لبه‌ها (Edge Distance):
├── جلو: 60 mm (6 cm)
└── پشت: 60 mm (6 cm)

جای انگشت‌ها (Pockets):
├── عمق: 10.5 mm (شامل 0.5mm clearance)
└── متقارن روی شلف
```

## ⚙️ پارامترهای کد (Code Parameters)

اگر می‌خواهید اندازه‌های پلاگین را تغییر دهید، این خطوط را ویرایش کنید:

```ruby
FINGER_LENGTH = 120      # 12cm
FINGER_WIDTH = 8         # 8mm
FINGER_DEPTH = 10        # 10mm on body
EDGE_DISTANCE = 60       # 6cm from edges
EXTRA_CLEARANCE = 0.5    # 0.5mm extra for easy fit
```

## 🐛 رفع اشکالات (Troubleshooting)

### مشکل: پلاگین در منوی Plugins ظاهر نمی‌شود
**راه‌حل:**
- SketchUp را بطور کامل ببندید
- SketchUp را دوباره باز کنید
- اطمینان حاصل کنید فایل در پوشه Plugins صحیح قرار دارد

### مشکل: خطا هنگام انتخاب کمپوننت‌ها
**راه‌حل:**
- اطمینان حاصل کنید انتخاب کمپوننت واقعی هستند (نه گروپ)
- نام‌های کمپوننت را بررسی کنید
- اگر مشکل ادامه یافت، Undo کنید و دوباره سعی کنید

### مشکل: پیش‌نمایش غلط است
**راه‌حل:**
- No کلیک کنید (preview حذف می‌شود)
- ابعاد کمپوننت‌ها را بررسی کنید
- اطمینان حاصل کنید شلف داخل بدنه قرار می‌گیرد

## 📝 نسخه (Version)

**Version 2.0**
- Interactive workflow
- Live preview
- Dimension detection
- Symmetrical finger joints

## 📄 مجوز (License)

MIT License - آزاد برای استفاده و تعدیل

## 👨‍💻 توسعه‌دهنده (Developer)

ساخته شده برای طراحی کابینت با استفاده از SketchUp

## 📞 پشتیبانی (Support)

اگر سوالی دارید یا مشکل پیدا کردید:
1. اطمینان حاصل کنید تمام مراحل را دنبال کرده‌اید
2. Undo کنید و دوباره سعی کنید
3. مدل را ذخیره‌نشده بار کنید و دوباره سعی کنید

---

**Enjoy! 🎉**