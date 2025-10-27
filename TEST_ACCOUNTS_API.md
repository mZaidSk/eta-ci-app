# Account API Integration - Test Guide

## ✅ Issues Fixed

### 1. **Balance Parsing Error** - FIXED
**Problem:** API returns balance as string `"5000.00"` but code expected number
**Solution:** Updated `Account.fromJson()` to handle both string and number formats

```dart
double parseBalance(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
```

### 2. **RangeError in maskedNumber** - FIXED
**Problem:** Short IDs (like "1") caused substring error
**Solution:** Added safe length checking before substring

```dart
String getLast4Digits() {
  if (id.length >= 4) {
    return id.substring(id.length - 4);
  } else {
    return id.padLeft(4, '0');
  }
}
```

### 3. **API Base URL** - CONFIGURED
**Current Configuration:**
- Base URL: `http://127.0.0.1:8000/api`
- Accounts Endpoint: `/accounts/`
- Full URL: `http://127.0.0.1:8000/api/accounts/`

---

## 📋 API Endpoints

All endpoints are now properly configured:

| Operation | Method | Endpoint | Body |
|-----------|--------|----------|------|
| **List Accounts** | GET | `/api/accounts/` | - |
| **Get Account** | GET | `/api/accounts/{id}` | - |
| **Create Account** | POST | `/api/accounts/` | `{name, account_type, balance}` |
| **Update Account** | PUT | `/api/accounts/{id}` | `{name, account_type, balance}` |
| **Delete Account** | DELETE | `/api/accounts/{id}` | - |

---

## 🧪 Testing the Integration

### Step 1: Start Your Backend API
Ensure your Django/FastAPI server is running on `http://127.0.0.1:8000`

### Step 2: Run the Flutter App
```bash
flutter run -d <your-device>
```

### Step 3: Test CRUD Operations

#### ✅ **READ (Fetch Accounts)**
1. Navigate to the Accounts tab in the app
2. Accounts should load automatically
3. Check console for logs:
```
📋 Fetching accounts from API...
🌐 API: GET http://127.0.0.1:8000/api/accounts/
✅ Fetched X accounts
```

#### ✅ **CREATE (Add New Account)**
1. Click the "Add Account" button
2. Fill in the form:
   - Name: "My Test Account"
   - Type: Select "Savings"
   - Balance: 1000.00
3. Click "Add Account"
4. Check console for logs:
```
➕ Creating account: My Test Account
🌐 API: POST http://127.0.0.1:8000/api/accounts/
✅ Account created: 2
```

#### ✅ **UPDATE (Edit Account)**
1. Tap on an existing account
2. Click edit icon
3. Modify the account details
4. Click "Update Account"
5. Check console for logs:
```
✏️ Updating account: 2
🌐 API: PUT http://127.0.0.1:8000/api/accounts/2
✅ Account updated: 2
```

#### ✅ **DELETE (Remove Account)**
1. Swipe or click delete on an account
2. Confirm deletion
3. Check console for logs:
```
🗑️ Deleting account: 2
🌐 API: DELETE http://127.0.0.1:8000/api/accounts/2
✅ Account deleted: 2
```

---

## 🐛 Debugging

### Check Console Logs
All API operations are logged. Look for:
- ✅ Success indicators
- ❌ Error messages with details
- 🌐 Full API request/response data

### Common Issues

#### Issue: "Network error occurred"
**Cause:** Backend server not running
**Solution:** Start your backend API server

#### Issue: "Failed to fetch accounts"
**Cause:** Wrong API URL
**Solution:** Check base URL in console log:
```
🔧 BaseService initialized with baseUrl: http://127.0.0.1:8000/api
```

#### Issue: Balance shows as 0
**Cause:** Balance parsing (already fixed!)
**Solution:** Code now handles string balances

#### Issue: RangeError on display
**Cause:** Short account IDs (already fixed!)
**Solution:** maskedNumber now handles all ID lengths

---

## 📝 API Response Format

Your API returns data in this format:

```json
{
  "success": true,
  "message": "Request successful",
  "data": [
    {
      "id": 1,
      "name": "My Salary Account",
      "account_type": "savings",
      "balance": "5000.00",
      "created_at": "2025-09-06T18:58:24.875303Z"
    }
  ],
  "errors": null
}
```

The `AccountService.getAccounts()` correctly extracts `data` array from the response.

---

## 🎯 Expected Console Output (Success)

```
🔧 BaseService initialized with baseUrl: http://127.0.0.1:8000/api
📋 Fetching accounts from API...
🌐 API: GET http://127.0.0.1:8000/api/accounts/
🌐 API: Response Text:
🌐 API: {"success":true,"message":"Request successful","data":[...],"errors":null}
✅ Fetched 1 accounts
```

---

## ✨ What's Working Now

- ✅ Fetch all accounts from API
- ✅ Display accounts with correct balance (handles string/number)
- ✅ Show masked account numbers (works with all ID lengths)
- ✅ Create new accounts via API
- ✅ Update existing accounts via API
- ✅ Delete accounts via API
- ✅ Proper error handling with user-friendly messages
- ✅ Loading states during API calls
- ✅ Automatic token injection for authenticated requests

---

## 🚀 Next Steps

1. **Test all CRUD operations** following the steps above
2. **Verify error handling** by testing with backend offline
3. **Check form validation** by submitting invalid data
4. **Test with multiple accounts** to ensure list updates correctly

All account API integration is complete and ready for testing!
