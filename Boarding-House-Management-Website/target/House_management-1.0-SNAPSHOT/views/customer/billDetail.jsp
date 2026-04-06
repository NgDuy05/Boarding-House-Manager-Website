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
</head>
<body class="bg-light" style="overflow-x:hidden;">
<%@ include file="../navbar.jsp" %>

<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4" style="max-width:860px;">

      <a href="${pageContext.request.contextPath}/bill?action=mybill"
         class="btn btn-sm btn-outline-secondary mb-3">
        <i class="bi bi-arrow-left me-1"></i>Back to Bill List
      </a>

      <c:if test="${empty bill}">
        <div class="alert alert-danger">Bill not found.</div>
      </c:if>

      <c:if test="${not empty bill}">

        <%-- ── Header card ── --%>
        <div class="card shadow-sm border-0 mb-3">
          <div class="card-header bg-white d-flex justify-content-between align-items-center">
            <span class="fw-bold fs-5">
              <i class="bi bi-receipt me-2"></i>Invoice #${bill.billId}
            </span>
            <c:choose>
              <c:when test="${bill.status eq 'paid'}">
                <span class="badge bg-success fs-6">Paid</span>
              </c:when>
              <c:when test="${bill.status eq 'overdue'}">
                <span class="badge bg-danger fs-6">Overdue</span>
              </c:when>
              <c:otherwise>
                <span class="badge bg-warning text-dark fs-6">Pending Payment</span>
              </c:otherwise>
            </c:choose>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-6 col-md-3">
                <div class="text-muted small mb-1">Billing Period</div>
                <div class="fw-semibold">${bill.period}</div>
              </div>
              <div class="col-6 col-md-3">
                <div class="text-muted small mb-1">Due Date</div>
                <div class="fw-semibold">${bill.dueDate}</div>
              </div>
              <div class="col-6 col-md-3">
                <div class="text-muted small mb-1">Room Number</div>
                <div class="fw-semibold">${not empty bill.roomNumber ? bill.roomNumber : '#'.concat(bill.contractId)}</div>
              </div>
              <div class="col-6 col-md-3">
                <div class="text-muted small mb-1">Total Amount</div>
                <div class="fw-bold text-primary fs-5">
                  <fmt:formatNumber value="${bill.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                </div>
              </div>
            </div>
          </div>
        </div>

        <%-- ── Bill items breakdown ── --%>
        <div class="card shadow-sm border-0 mb-3">
          <div class="card-header bg-white fw-semibold">
            <i class="bi bi-list-ul me-2"></i>Bill Details
          </div>
          <div class="card-body p-0">
            <c:choose>
              <c:when test="${empty billItems}">
                <p class="text-muted text-center py-4 mb-0">No bill details found.</p>
              </c:when>
              <c:otherwise>
                <table class="table table-hover mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Description</th>
                      <th class="text-center" style="width:90px;">Quantity</th>
                      <th class="text-end"    style="width:130px;">Unit Price</th>
                      <th class="text-end"    style="width:130px;">Amount</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%-- Group rows by source_type with a sub-header --%>
                    <c:set var="lastType" value="" />
                    <c:forEach var="item" items="${billItems}">
                      <c:if test="${item.sourceType ne lastType}">
                        <c:set var="lastType" value="${item.sourceType}" />
                        <tr class="table-secondary">
                          <td colspan="4" class="fw-semibold small py-1 ps-3">
                            <c:choose>
                              <c:when test="${item.sourceType eq 'room'}">
                                <i class="bi bi-house me-1"></i>Room Rent
                              </c:when>
                              <c:when test="${item.sourceType eq 'amenity'}">
                                <i class="bi bi-stars me-1"></i>Room Amenities
                              </c:when>
                              <c:when test="${item.sourceType eq 'utility'}">
                                <i class="bi bi-lightning-charge me-1"></i>Utilities
                              </c:when>
                              <c:when test="${item.sourceType eq 'service'}">
                                <i class="bi bi-tools me-1"></i>Services
                              </c:when>
                              <c:otherwise>
                                <i class="bi bi-plus-circle me-1"></i>Other
                              </c:otherwise>
                            </c:choose>
                          </td>
                        </tr>
                      </c:if>
                      <tr>
                        <td>${item.description}</td>
                        <td class="text-center">
                          <fmt:formatNumber value="${item.quantity}" maxFractionDigits="2"/>
                        </td>
                        <td class="text-end">
                          <fmt:formatNumber value="${item.unitPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                        </td>
                        <td class="text-end fw-semibold">
                          <fmt:formatNumber value="${item.quantity * item.unitPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                  <tfoot class="table-light">
                    <tr>
                      <td colspan="3" class="text-end fw-bold">Grand Total</td>
                      <td class="text-end fw-bold text-primary">
                        <fmt:formatNumber value="${bill.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <%-- ── Pay button (pending or overdue only) ── --%>
        <c:if test="${bill.status eq 'pending' or bill.status eq 'overdue'}">
          <form method="post" action="${pageContext.request.contextPath}/payment">
            <input type="hidden" name="action"  value="pay"/>
            <input type="hidden" name="billId"  value="${bill.billId}"/>
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-credit-card me-2"></i>Pay via VNPay
            </button>
          </form>
        </c:if>

        <%-- ── Already paid notice ── --%>
        <c:if test="${bill.status eq 'paid'}">
          <div class="alert alert-success d-flex align-items-center">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            This bill has been fully paid.
          </div>
        </c:if>

      </c:if><%-- end not empty bill --%>

    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
