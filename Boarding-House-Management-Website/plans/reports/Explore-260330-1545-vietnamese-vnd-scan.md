# Vietnamese Text & VND Price Format Scan Report

**Date:** 2026-03-30  
**Scope:** `src/main/webapp/views/` (all JSP files)  
**Status:** Complete

## Summary

Found significant inconsistencies in Vietnamese text and VND price formatting across the project:
- 34 files using `&#8363;` (Vietnamese Dong HTML entity)
- 6 files using `₫` (Vietnamese Dong Unicode character U+20AB)
- 3 files using plain text formats: `d/thang`, `đ/tháng`, `/month`
- 5 files using VND text labels
- Multiple Vietnamese labels in forms and UI text

## KEY INCONSISTENCIES

### 1. Price Currency Symbol

**Three different formats found:**
- `&#8363;` (34 occurrences) — HTML entity for dong
- `₫` (6 occurrences) — Unicode character  
- Text: `đ`, `d`, `VND`, `VNĐ`

### 2. Period Format

**Four different formats found:**
- `d/thang` (2 files) — ASCII approximation, unprofessional
- `đ/tháng` (1 file) — Proper Vietnamese
- `/month` (1 file) — English
- `VND/mo` (5 files in home.jsp)

### 3. UI Text Language

- English labels mostly in admin pages
- Vietnamese labels in customer pages
- Mixed Vietnamese/English in some pages

## FILES WITH INCONSISTENCIES

### Group A: Files using `&#8363;` (34 instances)

Admin Bills (7): billDetail.jsp, bills.jsp, billStatus.jsp, ownerBillList.jsp
Admin Contracts (5): contractDetail.jsp, createContract.jsp, editContract.jsp
Admin Deposits (5): depositForm.jsp (2 lines), depositList.jsp (3 lines)
Admin Rooms (1): roomDetail.jsp
Admin Services (1): serviceDetail.jsp
Admin Facilities (1): facilities.jsp
Customer Bills (5): billDetail.jsp (3 lines), bills.jsp
Customer Contracts (4): contractDetail.jsp (2 lines), contracts.jsp (2 lines)
Customer Dashboard (2): dashboard.jsp, paymentResult.jsp
Customer Rooms (3): roomDetail.jsp (2 lines), rooms.jsp, roomCategories.jsp
Customer Services (1): serviceDetail.jsp

### Group B: Files using `₫` (6 instances)

- `admin/services/manageRequests.jsp:171`
- `admin/services/requestList.jsp:154, 157`
- `customer/serviceHistory.jsp:148, 199, 203`

### Group C: Mixed Formats (3 instances)

Text-based formats:
- `admin/facilities/facilities.jsp:60` — `d/thang`
- `admin/facilities/facilityDetail.jsp:44` — `d/thang`
- `customer/signContract.jsp:152` — `đ/tháng`

### Group D: VND Labels (10 instances)

- `admin/facilities/createFacility.jsp:42` — "Giá / tháng (VNĐ)"
- `admin/facilities/editFacility.jsp:48` — "Giá / tháng (VNĐ)"
- `admin/utilities/addPrice.jsp:35` — "Price (VND / unit)"
- `admin/utilities/editPrice.jsp:36` — "Price (VND)"
- `admin/utilities/utilityDetail.jsp:76` — "VND/unit"
- `home.jsp:759, 908, 931, 954, 977` — "VND/mo" (5 times)

### Group E: Dashboard Revenue (2 instances)

- `admin/dashboard.jsp:89` — uses ` đ` (space-prefixed)
- `admin/dashboard.jsp:104` — uses ` đ` (space-prefixed)

## VIETNAMESE UI TEXT FOUND

**Form Labels:**
- "Hợp đồng / Phòng" (Contract / Room)
- "Kỳ thanh toán" (Payment period)
- "Ngày đến hạn" (Due date)
- "Các mục hóa đơn" (Bill items)
- "Loại" (Type)
- "Mô tả" (Description)
- "Thành tiền" (Subtotal)
- "TỔNG CỘNG" (Total)
- "Giá / tháng" (Price / month)
- "Tiền phòng" (Room rent)
- "Tiện ích phòng" (Room amenities)
- "Tiện ích mong muốn" (Desired amenities)

**Status Messages:**
- "Hóa đơn tháng này đã tồn tại" (Bill for this month already exists)
- "Chưa có hợp đồng thuê phòng" (No active rental contract)

**Files with Vietnamese content:**
- admin/bills/createBill.jsp — lang="vi"
- admin/contracts/createContract.jsp
- admin/dashboard.jsp
- admin/facilities/createFacility.jsp, editFacility.jsp
- customer/signContract.jsp
- customer/billDetail.jsp
- customer/requestService.jsp
- customer/serviceHistory.jsp

## JAVASCRIPT FORMATTING FUNCTIONS

Two custom VND formatting functions found:

1. `admin/bills/createBill.jsp:300`
   - Function: `fmtVnd(n)`
   - Usage: Formats bill item totals

2. `customer/signContract.jsp:302`
   - Function: `formatVnd(n)`
   - Usage: Formats contract price previews

## ISSUES & RECOMMENDATIONS

### Issue 1: Inconsistent Currency Symbol

**Current State:**
- 34 instances of `&#8363;` (HTML entity)
- 6 instances of `₫` (Unicode)
- Additional text variations

**Recommendation:**
- Standardize to one format: prefer `₫` (Unicode U+20AB)
- Update all 40+ occurrences for consistency
- Remove custom formatting functions if using standard formatting

### Issue 2: Unprofessional Text Formats

**Current State:**
- `d/thang` appears in 2 files (ASCII approximation)
- Should be `đ/tháng` (Vietnamese) or `/month` (English)

**Recommendation:**
- Update facilities.jsp and facilityDetail.jsp
- Use proper Vietnamese diacriticals or English consistently
- Choose single language for period format

### Issue 3: Language Mix

**Current State:**
- VND labels in Vietnamese (VNĐ) and English (VND)
- Form text is Vietnamese in customer pages, English in admin
- Home page uses English "VND/mo"

**Recommendation:**
- Define language strategy: Vietnamese OR English throughout
- Extract all text to resource bundle (i18n)
- Apply consistently across all modules

## STATISTICS

Total price format instances: 54
Files affected: 25+
Unique formats: 6
Language mix: Yes

## NEXT STEPS

1. Prioritize standardizing currency symbol (34 vs 6 conflict)
2. Fix text formats in facilities module (d/thang issue)
3. Evaluate language strategy for entire application
