# Vietnamese Text & Currency Format Analysis Report

**Analysis Date:** 2026-03-30  
**Status:** READ-ONLY AUDIT - No file edits performed  
**Purpose:** Identify all Vietnamese text and VND currency formats for standardization fix

## CRITICAL FINDINGS - FACILITIES MODULE

### File: facilities.jsp (Line 60 & 65)
Line 60: d/thang (WRONG - missing diacritics)
Line 65: Chua co gia (WRONG - missing diacritics: should be "Chưa có giá")

### File: facilityDetail.jsp (Line 39, 44, 48)
Line 39: Gia / thang (phu thu) (WRONG)
Line 44: d/thang (WRONG - should be "đ/tháng")
Line 48: Mien phi (0d) (WRONG - should be "Miễn phí (0đ)")

### File: createFacility.jsp (Line 42, 45)
Line 42: "Giá / tháng (VNĐ)" - CORRECT with diacritics
Line 45: "Phụ thu cộng vào tiền phòng mỗi tháng" - CORRECT

### File: editFacility.jsp (Line 48, 51)
Line 48: "Giá / tháng (VNĐ)" - CORRECT with diacritics
Line 51: "Phụ thu cộng vào tiền phòng mỗi tháng" - CORRECT

## CURRENCY SYMBOLS - SYSTEM-WIDE AUDIT

### HTML Entity &#8363; (18 files):
- dashboard.jsp:123
- depositList.jsp:42, 94, 99
- editContract.jsp:56
- ownerBillList.jsp:59
- paymentResult.jsp:68
- roomDetail.jsp:325, 470
- depositForm.jsp:34, 77
- billStatus.jsp:68
- createContract.jsp:78
- contracts.jsp:107, 113
- serviceDetail.jsp:47
- roomCategories.jsp:306
- bills.jsp:62
- bills.jsp:53
- contractDetail.jsp:84, 85, 86
- rooms.jsp:369
- billDetail.jsp:67, 128, 131, 140
- billDetail.jsp:64, 94, 98
- roomDetail.jsp:52
- contractDetail.jsp:55, 62
- serviceDetail.jsp:42

### Unicode ₫ symbol (8 files):
- serviceHistory.jsp:148, 199, 203
- manageRequests.jsp:171
- requestList.jsp:154, 157
- contracts.jsp:113

### Label formats "VNĐ|VND" (10 files):
- home.jsp:759, 908, 931, 954, 977 (VND/mo - English)
- utilityDetail.jsp:76 (VND/)
- facilities/editFacility.jsp:48 (VNĐ - correct)
- facilities/createFacility.jsp:42 (VNĐ - correct)
- utilities/editPrice.jsp:36 (VND)
- utilities/addPrice.jsp:35 (VND/)

### Month format usage:
- facilities.jsp:60 = d/thang (WRONG)
- facilityDetail.jsp:44 = d/thang (WRONG)
- signContract.jsp:152 = đ/tháng (CORRECT)

## VIETNAMESE LANGUAGE DECLARATION
Only createBill.jsp has: lang="vi"
Recommendation: Add to other files with Vietnamese content

## RECOMMENDATION PRIORITY FIX LIST

FACILITIES MODULE (CRITICAL):
1. facilities.jsp Line 60: d/thang → đ/tháng
2. facilities.jsp Line 65: Chua co gia → Chưa có giá
3. facilityDetail.jsp Line 39: Gia / thang (phu thu) → Giá / tháng (phụ thu)
4. facilityDetail.jsp Line 44: d/thang → đ/tháng
5. facilityDetail.jsp Line 48: Mien phi (0d) → Miễn phí (0đ)

VERIFY AS CORRECT:
- createFacility.jsp - All Vietnamese proper
- editFacility.jsp - All Vietnamese proper
- signContract.jsp - All Vietnamese proper
- createBill.jsp - All Vietnamese proper + locale formatter

SYSTEM-WIDE STANDARDIZATION:
- Replace &#8363; with Unicode đ or ₫
- Standardize VND labels (use VNĐ for Vietnamese context)
- Add lang="vi" to all Vietnamese content files

