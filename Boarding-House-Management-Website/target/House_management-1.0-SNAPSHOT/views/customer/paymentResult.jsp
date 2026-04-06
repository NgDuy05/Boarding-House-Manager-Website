<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Payment Result - AKDD House</title>
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
    <main class="col p-4">
      <h4 class="mb-4"><i class="bi bi-credit-card me-2"></i>Payment Result</h4>

      <div class="card shadow-sm border-0" style="max-width: 600px;">
        <div class="card-body p-4">

          <c:choose>
            <c:when test="${paymentSuccess == true}">
              <div class="alert alert-success d-flex align-items-center gap-2 mb-4">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <span>Payment successful! Your bill has been updated.</span>
              </div>
            </c:when>
            <c:otherwise>
              <div class="alert alert-danger d-flex align-items-center gap-2 mb-4">
                <i class="bi bi-x-circle-fill fs-5"></i>
                <span>Payment failed or cancelled.</span>
              </div>
            </c:otherwise>
          </c:choose>

          <c:if test="${not empty bill}">
            <div class="mb-3">
              <div class="row g-2">
                <div class="col-6">
                  <div class="text-muted small">Bill ID</div>
                  <div class="fw-semibold">#${bill.billId}</div>
                </div>
                <div class="col-6">
                  <div class="text-muted small">Status</div>
                  <div>
                    <c:choose>
                      <c:when test="${bill.status == 'paid'}">
                        <span class="badge bg-success">Paid</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-danger">Unpaid</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
                <div class="col-6">
                  <div class="text-muted small">Period</div>
                  <div class="fw-semibold">${bill.period}</div>
                </div>
                <div class="col-6">
                  <div class="text-muted small">Amount</div>
                  <div class="fw-bold text-primary">
                    <c:if test="${not empty bill.totalAmount}">
                      <fmt:formatNumber value="${bill.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                    </c:if>
                  </div>
                </div>
              </div>
            </div>
          </c:if>

          <a href="${pageContext.request.contextPath}/bill?action=mybill"
             class="btn btn-outline-primary mt-2">
            <i class="bi bi-list-ul me-1"></i>View My Bills
          </a>
        </div>
      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
