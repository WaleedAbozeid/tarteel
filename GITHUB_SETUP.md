# تعليمات ربط المشروع بـ GitHub

## 🚀 خطوات ربط المشروع بـ GitHub

### 1. إنشاء Repository على GitHub

1. اذهب إلى [GitHub.com](https://github.com)
2. اضغط على زر **"New"** أو **"+"** في الأعلى
3. اختر **"New repository"**
4. املأ المعلومات التالية:
   - **Repository name**: `tarteel`
   - **Description**: `تطبيق ترتيل - تطبيق القرآن الكريم التفاعلي`
   - **Visibility**: اختر Public أو Private حسب رغبتك
   - **لا تضع علامة** على "Initialize this repository with a README"
5. اضغط **"Create repository"**

### 2. ربط المشروع المحلي بـ GitHub

بعد إنشاء Repository، ستظهر لك التعليمات. استخدم الأوامر التالية:

```bash
# إضافة Remote Repository
git remote add origin https://github.com/YOUR_USERNAME/tarteel.git

# رفع الكود إلى GitHub
git branch -M main
git push -u origin main
```

### 3. تحديث معلومات المستخدم (اختياري)

```bash
# تعيين اسم المستخدم
git config --global user.name "Your Name"

# تعيين البريد الإلكتروني
git config --global user.email "your-email@example.com"
```

### 4. التحقق من الربط

```bash
# عرض Remote Repositories
git remote -v

# يجب أن تظهر النتيجة:
# origin  https://github.com/YOUR_USERNAME/tarteel.git (fetch)
# origin  https://github.com/YOUR_USERNAME/tarteel.git (push)
```

## 📝 أوامر Git الأساسية

### رفع التحديثات
```bash
# إضافة التغييرات
git add .

# عمل Commit
git commit -m "وصف التحديثات"

# رفع التحديثات
git push origin main
```

### سحب التحديثات
```bash
# سحب التحديثات من GitHub
git pull origin main
```

### إنشاء فرع جديد
```bash
# إنشاء فرع جديد
git checkout -b feature/new-feature

# رفع الفرع الجديد
git push -u origin feature/new-feature
```

## 🔧 إعدادات إضافية

### إعداد GitHub CLI (اختياري)
```bash
# تثبيت GitHub CLI
# Windows: winget install GitHub.cli
# macOS: brew install gh

# تسجيل الدخول
gh auth login

# إنشاء Repository من سطر الأوامر
gh repo create tarteel --public --description "تطبيق ترتيل - تطبيق القرآن الكريم التفاعلي"
```

### إعداد GitHub Pages (للمشروع)
```bash
# إنشاء فرع gh-pages
git checkout -b gh-pages

# رفع الفرع
git push -u origin gh-pages
```

## 📋 قائمة التحقق

- [ ] إنشاء Repository على GitHub
- [ ] ربط المشروع المحلي بـ GitHub
- [ ] رفع الكود الأولي
- [ ] تحديث README.md بمعلومات GitHub
- [ ] إعداد GitHub Pages (اختياري)
- [ ] إضافة Topics للمشروع على GitHub
- [ ] إعداد GitHub Actions (اختياري)

## 🎯 النتيجة النهائية

بعد اتباع هذه الخطوات، ستحصل على:
- ✅ Repository منظم على GitHub
- ✅ تاريخ كامل للتغييرات
- ✅ إمكانية التعاون مع مطورين آخرين
- ✅ نسخة احتياطية من الكود
- ✅ إمكانية نشر التطبيق

## 📞 المساعدة

إذا واجهت أي مشاكل:
1. تحقق من صحة URL الخاص بـ Repository
2. تأكد من أن لديك صلاحيات الكتابة على Repository
3. تحقق من إعدادات Git المحلية
4. راجع [GitHub Help](https://help.github.com)

---

**ملاحظة**: استبدل `YOUR_USERNAME` باسم المستخدم الخاص بك على GitHub 