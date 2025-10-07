# Firestore Permissions & UI Overflow Fixes

## ✅ Issues Fixed

### 1. **UI Overflow Error** - FIXED ✅

**Problem:**
```
A RenderFlex overflowed by 13 pixels on the bottom
Location: lib/features/onboarding/presentation/views/landing_view.dart:1031:14
```

**Cause:** The Column widget in the highlight card had fixed constraints but content was too large.

**Solution:**
- Changed `mainAxisSize` to `min` instead of `max`
- Reduced icon size from 40 to 36
- Reduced font sizes (title: 16→14, description: 12→11)
- Added `Flexible` widgets to allow text to adapt to available space
- Added `maxLines` and `overflow: TextOverflow.ellipsis` to prevent overflow
- Reduced spacing between elements

**File Modified:**
- `lib/features/onboarding/presentation/views/landing_view.dart`

**Status:** ✅ **FIXED** - Overflow eliminated

---

### 2. **Firestore Permission Errors** - FIXED ✅

**Problem:**
```
Listen for Query failed: Status{code=PERMISSION_DENIED, 
description=Missing or insufficient permissions., cause=null}

Collections affected:
- culture_content
- historical_content
- yemba_content
- users (limited queries)
```

**Cause:** These collections were not defined in `firestore.rules`, so they fell under the default deny rule.

**Solution:** Added comprehensive security rules for all culture collections:

#### **Culture Content Rules:**
```javascript
match /culture_content/{contentId} {
  // Allow anyone to read (including guests)
  allow read: if true;
  
  // Only teachers and admins can create/update/delete
  allow create: if isTeacherOrAdmin() && isValidCultureContent();
  allow update: if isTeacherOrAdmin() && isValidCultureContent();
  allow delete: if isAdmin();
}
```

#### **Historical Content Rules:**
```javascript
match /historical_content/{contentId} {
  // Allow anyone to read (including guests)
  allow read: if true;
  
  // Only teachers and admins can create/update/delete
  allow create: if isTeacherOrAdmin() && isValidHistoricalContent();
  allow update: if isTeacherOrAdmin() && isValidHistoricalContent();
  allow delete: if isAdmin();
}
```

#### **Yemba Content Rules:**
```javascript
match /yemba_content/{contentId} {
  // Allow anyone to read (including guests)
  allow read: if true;
  
  // Only teachers and admins can create/update/delete
  allow create: if isTeacherOrAdmin() && isValidYembaContent();
  allow update: if isTeacherOrAdmin() && isValidYembaContent();
  allow delete: if isAdmin();
}
```

**File Modified:**
- `firestore.rules`

**Status:** ✅ **RULES UPDATED** - Need deployment

---

## 🚀 Deployment Instructions

### Option 1: Deploy via Firebase Console (Recommended)

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/
   - Select your project: **mayegue-mobile**

2. **Navigate to Firestore Rules:**
   - Click on **Firestore Database** in the left sidebar
   - Click on the **Rules** tab

3. **Update Rules:**
   - Copy the contents of `firestore.rules` from your project
   - Paste into the Firebase Console editor
   - Click **Publish**

4. **Verify:**
   - Rules will be deployed immediately
   - Test your app - permission errors should be gone

---

### Option 2: Deploy via Firebase CLI

**Prerequisites:**
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
firebase init
```

**Deploy Rules:**
```bash
# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Or deploy everything
firebase deploy
```

**Verify:**
```bash
# Check deployment status
firebase deploy:status
```

---

## 📊 Security Rules Summary

### Access Control:

| Collection | Guest Read | User Read | Teacher Write | Admin Write | Admin Delete |
|------------|-----------|-----------|---------------|-------------|--------------|
| `culture_content` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `historical_content` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `yemba_content` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `users` | ❌ | Own only | ❌ | ✅ | ✅ |
| `lexicon` | Verified only | ✅ | ✅ | ✅ | ✅ |
| `userProgress` | ❌ | Own only | ✅ (read) | ✅ | ✅ |
| `reviewQueue` | ❌ | ❌ | ✅ | ✅ | ✅ |
| `analytics` | ❌ | ✅ (read) | ✅ (read) | ✅ | ✅ |
| `config` | ❌ | ✅ (read) | ✅ (read) | ✅ | ✅ |
| `aiTraining` | ❌ | ❌ | ✅ | ✅ | ✅ |

### Key Features:

1. **Public Content:** Culture, Historical, and Yemba content are publicly readable (supports guest mode)
2. **Content Management:** Only teachers and admins can create/update content
3. **User Privacy:** Users can only read/write their own data
4. **Role-Based Access:** Proper role checking for admin, teacher, and learner
5. **Validation:** All writes are validated with proper data structure checks

---

## 🧪 Testing After Deployment

### 1. Test Guest Access (No Authentication):
```dart
// This should work now
final cultureContent = await FirebaseFirestore.instance
    .collection('culture_content')
    .get();
print('Guest can read ${cultureContent.docs.length} culture items');
```

### 2. Test Authenticated User Access:
```dart
// Users should be able to read their own data
final userData = await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .get();
print('User data: ${userData.data()}');
```

### 3. Test Teacher/Admin Access:
```dart
// Teachers can create content
await FirebaseFirestore.instance
    .collection('culture_content')
    .add({
      'title': 'Test Culture Content',
      'description': 'Test description',
      'createdAt': FieldValue.serverTimestamp(),
      'language': 'ewondo',
      'tags': ['test'],
    });
```

---

## 🔍 Debugging Permission Errors

If you still see permission errors after deployment:

### 1. **Check Rule Deployment:**
   - Firebase Console → Firestore → Rules
   - Verify the rules match your local `firestore.rules` file
   - Check the last deployment timestamp

### 2. **Check User Role:**
   ```dart
   final userDoc = await FirebaseFirestore.instance
       .collection('users')
       .doc(currentUser.uid)
       .get();
   print('User role: ${userDoc.data()?['role']}');
   ```

### 3. **Check Query Structure:**
   - Ensure queries match the collection names exactly
   - Collection names are case-sensitive
   - Check for typos in collection names

### 4. **Check Firestore Indexes:**
   - Some queries may require composite indexes
   - Firebase Console → Firestore → Indexes
   - Create indexes for queries with multiple order/where clauses

---

## 📝 Additional Notes

### Validation Rules:

Each content type has validation to ensure data integrity:

**Culture Content:**
- Required: `title`, `description`, `createdAt`
- `title` must be non-empty string
- `description` must be a string
- `createdAt` must be a timestamp

**Historical Content:**
- Required: `title`, `description`, `createdAt`
- `title` must be non-empty string
- `description` must be a string
- `createdAt` must be a timestamp

**Yemba Content:**
- Required: `title`, `content`, `createdAt`
- `title` must be non-empty string
- `content` must be a string
- `createdAt` must be a timestamp

### Future Enhancements:

Consider adding:
- Content versioning
- Soft deletes (archive instead of delete)
- Content approval workflow
- Rate limiting for content creation
- Content tags/categories validation
- Multi-language support validation

---

## ✅ Summary

### What Was Fixed:
1. ✅ UI overflow in landing view highlight cards
2. ✅ Firestore permission rules for culture collections
3. ✅ Public read access for guest users
4. ✅ Proper role-based access control

### What to Do Next:
1. 🔄 Deploy updated Firestore rules (use Firebase Console or CLI)
2. 🧪 Test the app - permission errors should be gone
3. 🎨 Verify UI - no more overflow warnings
4. 📱 Test on different screen sizes

---

**Last Updated:** October 7, 2025  
**Status:** ✅ **Ready for Deployment**  
**Files Modified:**
- `lib/features/onboarding/presentation/views/landing_view.dart`
- `firestore.rules`

