<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Bill Detail - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* 1. Import Font Pretendard */
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css");

        /* 2. Ocean Palette Variables */
        :root {
            --ocean-900: #03045E;
            --ocean-800: #023E8A;
            --ocean-700: #0077B6;
            --ocean-600: #0096C7;
            --ocean-500: #00B4D8;
            --ocean-400: #48CAE4;
            --ocean-300: #90E0EF;
            --ocean-200: #ADE8F4;
            --ocean-100: #CAF0F8;
            --ds-bg: #f4f7f9;
            --ds-text: #292A2D;
        }

        body { 
            font-family: 'Pretendard', sans-serif !important;
            background-color: var(--ds-bg); 
            color: var(--ds-text);
            overflow-x: hidden;
        }

        /* 3. Layout & Cards */
        .card {
            border-radius: 18px;
            border: none;
            box-shadow: 0 4px 16px rgba(0,0,0,0.04);
            background-color: #ffffff;
            overflow: hidden;
        }
        .card-header {
            background-color: #ffffff;
            border-bottom: 1px dashed var(--ocean-200);
            padding: 24px;
        }

        /* 4. Status Badges */
        .badge-status {
            padding: 8px 16px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .badge-paid { background-color: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .badge-overdue { background-color: #fee2e2; color: #dc2626; border: 1px solid #fecaca; }
        .badge-pending { background-color: #fef9c3; color: #ca8a04; border: 1px solid #fef08a; }

        /* 5. Buttons */
        .btn-back {
            color: var(--ocean-700);
            font-weight: 600;
            border-radius: 10px;
            padding: 8px 16px;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }
        .btn-back:hover { background-color: var(--ocean-100); color: var(--ocean-900); }

        .btn-vnpay {
            background: linear-gradient(135deg, var(--ocean-700), var(--ocean-900));
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 700;
            font-size: 16px;
            padding: 14px 28px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            box-shadow: 0 6px 16px rgba(2, 62, 138, 0.25);
        }
        .btn-vnpay:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(2, 62, 138, 0.35);
            color: white;
        }

        /* 6. Table Styling */
        .table { margin-bottom: 0; }
        .table thead th {
            background-color: var(--ocean-100) !important;
            color: var(--ocean-900) !important;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px;
            border: none;
        }
        .table tbody td {
            padding: 16px;
            vertical-align: middle;
            border-bottom: 1px solid #f0f4f8;
        }
        .table-group-header td {
            background-color: rgba(144, 224, 239, 0.15) !important;
            color: var(--ocean-800);
            font-weight: 700;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .table tfoot td {
            background-color: #ffffff;
            padding: 20px 16px;
            border-top: 2px solid var(--ocean-200);
        }

        .summary-label { color: #5A5C63; font-size: 13px; font-weight: 500; margin-bottom: 4px; }
        .summary-value { color: var(--ocean-900); font-weight: 700; font-size: 16px; }
    </style>
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4 d-flex justify-content-center">
      <div style="width: 100%; max-width: 900px;">

      <a href="${pageContext.request.contextPath}/bill?action=mybill" class="btn-back mb-4">
        <i class="bi bi-arrow-left me-2"></i>Back to Bill List
      </a>

      <c:if test="${empty bill}">
        <div class="alert alert-danger" style="border-radius: 14px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Bill not found.
        </div>
      </c:if>

      <c:if test="${not empty bill}">

        <%-- ── Header card (Invoice Summary) ── --%>
        <div class="card mb-4">
          <div class="card-header d-flex justify-content-between align-items-center">
            <span class="fw-bold fs-4" style="color: var(--ocean-900);">
              <i class="bi bi-receipt-cutoff me-2" style="color: var(--ocean-600);"></i>Invoice #${bill.billId}
            </span>
            <c:choose>
              <c:when test="${bill.status eq 'paid'}">
                <span class="badge-status badge-paid"><i class="bi bi-check-circle-fill"></i> Paid</span>
              </c:when>
              <c:when test="${bill.status eq 'overdue'}">
                <span class="badge-status badge-overdue"><i class="bi bi-exclamation-triangle-fill"></i> Overdue</span>
              </c:when>
              <c:otherwise>
                <span class="badge-status badge-pending"><i class="bi bi-clock-fill"></i> Pending Payment</span>
              </c:otherwise>
            </c:choose>
          </div>
          <div class="card-body p-4">
            <div class="row g-4">
              <div class="col-6 col-md-3">
                <div class="summary-label">Billing Period</div>
                <div class="summary-value">${bill.period}</div>
              </div>
              <div class="col-6 col-md-3">
                <div class="summary-label">Due Date</div>
                <div class="summary-value">${bill.dueDate}</div>
              </div>
              <div class="col-6 col-md-3">
                <div class="summary-label">Room Number</div>
                <div class="summary-value">
                    <i class="bi bi-door-closed me-1" style="color: var(--ocean-400);"></i>
                    ${not empty bill.roomNumber ? bill.roomNumber : '#'.concat(bill.contractId)}
                </div>
              </div>
              <div class="col-6 col-md-3">
                <div class="summary-label">Total Amount</div>
                <div class="fw-bold fs-4" style="color: var(--ocean-700);">
                  <fmt:formatNumber value="${bill.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                </div>
              </div>
            </div>
          </div>
        </div>

        <%-- ── Bill items breakdown ── --%>
        <div class="card mb-4">
          <div class="card-header border-0 pt-4 px-4 pb-0 bg-white">
            <h5 class="fw-bold mb-0" style="color: var(--ocean-900);">
                <i class="bi bi-list-columns-reverse me-2" style="color: var(--ocean-600);"></i>Bill Details
            </h5>
          </div>
          <div class="card-body p-0 mt-3">
            <c:choose>
              <c:when test="${empty billItems}">
                <div class="text-muted text-center py-5">
                    <i class="bi bi-inbox fs-1 d-block mb-3" style="color: var(--ocean-200);"></i>
                    No details found for this bill.
                </div>
              </c:when>
              <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-borderless table-hover">
                      <thead>
                        <tr>
                          <th class="ps-4">Description</th>
                          <th class="text-center" style="width:120px;">Quantity</th>
                          <th class="text-end"    style="width:160px;">Unit Price</th>
                          <th class="text-end pe-4" style="width:160px;">Amount</th>
                        </tr>
                      </thead>
                      <tbody>
                        <%-- Group rows by source_type with a sub-header --%>
                        <c:set var="lastType" value="" />
                        <c:forEach var="item" items="${billItems}">
                          <c:if test="${item.sourceType ne lastType}">
                            <c:set var="lastType" value="${item.sourceType}" />
                            <tr class="table-group-header">
                              <td colspan="4" class="ps-4">
                                <c:choose>
                                  <c:when test="${item.sourceType eq 'room'}">
                                    <i class="bi bi-house-door-fill me-2 fs-6"></i>Room Rent
                                  </c:when>
                                  <c:when test="${item.sourceType eq 'amenity'}">
                                    <i class="bi bi-stars me-2 fs-6"></i>Room Amenities
                                  </c:when>
                                  <c:when test="${item.sourceType eq 'utility'}">
                                    <i class="bi bi-lightning-charge-fill me-2 fs-6"></i>Utilities
                                  </c:when>
                                  <c:when test="${item.sourceType eq 'service'}">
                                    <i class="bi bi-tools me-2 fs-6"></i>Services
                                  </c:when>
                                  <c:otherwise>
                                    <i class="bi bi-plus-circle-fill me-2 fs-6"></i>Other
                                  </c:otherwise>
                                </c:choose>
                              </td>
                            </tr>
                          </c:if>
                          <tr>
                            <td class="ps-4 text-dark" style="font-weight: 500;">${item.description}</td>
                            <td class="text-center text-muted">
                              <fmt:formatNumber value="${item.quantity}" maxFractionDigits="2"/>
                            </td>
                            <td class="text-end text-muted">
                              <fmt:formatNumber value="${item.unitPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                            </td>
                            <td class="text-end fw-bold pe-4" style="color: var(--ocean-800);">
                              <fmt:formatNumber value="${item.quantity * item.unitPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                            </td>
                          </tr>
                        </c:forEach>
                      </tbody>
                      <tfoot>
                        <tr>
                          <td colspan="3" class="text-end fw-bold fs-5 text-dark" style="padding-right: 24px;">Grand Total</td>
                          <td class="text-end fw-bold fs-4 pe-4" style="color: var(--ocean-900);">
                            <fmt:formatNumber value="${bill.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                          </td>
                        </tr>
                      </tfoot>
                    </table>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <%-- ── Action Area (Pay button or Success notice) ── --%>
        <div class="d-flex justify-content-end mt-4">
            <c:if test="${bill.status eq 'pending' or bill.status eq 'overdue'}">
              <form method="post" action="${pageContext.request.contextPath}/payment">
                <input type="hidden" name="action"  value="pay"/>
                <input type="hidden" name="billId"  value="${bill.billId}"/>
                <button type="submit" class="btn-vnpay">
                  <i class="bi bi-credit-card-fill me-2"></i>Pay via VNPay
                </button>
              </form>
            </c:if>

            <c:if test="${bill.status eq 'paid'}">
              <div class="alert alert-success d-inline-flex align-items-center mb-0 shadow-sm" style="border-radius: 12px; border:none; background:#d1fae5; color:#065f46; font-weight: 600; padding: 14px 24px;">
                <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                This invoice has been fully paid. Thank you!
              </div>
            </c:if>
        </div>

      </c:if><%-- end not empty bill --%>

      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>