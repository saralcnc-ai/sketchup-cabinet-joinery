# راهنمای نصب کامل (Complete Installation Guide)

## Windows 10/11

### روش 1: نصب خودکار (Recommended)
1. فایل `cabinet_finger_joint.rb` را دانلود کنید
2. درایو C: روی File Manager کلیک کنید
3. مسیر زیر را جستجو کنید:
   ```
   C:\Users\YOUR_USERNAME\AppData\Roaming\SketchUp\SketchUp 2024\SketchUp\Plugins
   ```
   (عدد نسخه SketchUp خودتان را جایگزین کنید)

4. فایل `cabinet_finger_joint.rb` را اینجا کپی کنید
5. SketchUp را ببندید (اگر باز بود)
6. SketchUp را دوباره باز کنید

### روش 2: از طریق SketchUp
1. SketchUp را باز کنید
2. به Window → Preferences → Extensions برید
3. "Install Extension" کلیک کنید
4. فایل `cabinet_finger_joint.rb` را انتخاب کنید
5. SketchUp را دوباره شروع کنید

## Mac OS

### برای SketchUp 2023 و جدیدتر
1. Finder را باز کنید
2. Applications → SketchUp روی SketchUp دو بار کلیک کنید
3. "Show Package Contents" انتخاب کنید
4. مسیر زیر را باز کنید:
   ```
   Contents/Resources/en-US/Plugins
   ```
5. فایل `cabinet_finger_joint.rb` را اینجا قرار دهید
6. SketchUp را ببندید و دوباره باز کنید

## تأیید نصب موفق

1. SketchUp را باز کنید
2. به Plugins منو برید
3. "Cabinet Finger Joint" را ببینید
   - اگر موجود است: نصب موفق بود ✅
   - اگر موجود نیست: مراحل را دوباره بررسی کنید

## حذف پلاگین

### Windows
1. به مسیر Plugins برید (مانند بالا)
2. فایل `cabinet_finger_joint.rb` را حذف کنید
3. SketchUp را دوباره شروع کنید

### Mac
1. Package Contents را باز کنید
2. فایل `cabinet_finger_joint.rb` را به سطل زباله بریزید
3. SketchUp را دوباره شروع کنید

## مشکلات رایج

### خطا: "Plugin not found"
- ✅ اطمینان حاصل کنید نسخه SketchUp شما ۲۰۲۳ یا جدیدتر است
- ✅ فایل را دوباره بارگذاری کنید
- ✅ SketchUp را کامل ببندید و دوباره باز کنید

### خطا: "Permission denied"
- ✅ مطمئن شوید دسترسی رایتر به پوشه Plugins دارید
- ✅ فایل را با Run as Administrator کپی کنید

### پلاگین کار نمی‌کند
- ✅ Console را بررسی کنید: Window → Ruby Console
- ✅ حرف‌های خطا را کپی کنید و جستجو کنید
- ✅ مدل را ذخیره‌نشده دوباره بار کنید
