<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Deposit Transactions - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; }
        
        /* 1. Header Gradient using the dark blues */
        .page-header { 
            background: linear-gradient(135deg, #001D39, #0A4174, #49769F); 
            color: white; 
            border-radius: 12px; 
            padding: 20px 24px; 
            margin-bottom: 24px; 
            box-shadow: 0 4px 12px rgba(0, 29, 57, 0.15);
        }
        
        .table-card  { border-radius: 14px; border: none; }
        
        /* 2. Table Header using Ice Blue & Very Dark Blue text */
        .table thead th { 
            background: #BDD8E9; 
            color: #001D39; 
            font-size: 12px; 
            font-weight: 700; 
            text-transform: uppercase; 
            letter-spacing: .5px; 
            border: none; 
        }
        
        /* 3. Table Hover using Sky Blue with opacity */
        .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); }
        
        .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }
        
        /* 4. Pagination using Dark Blue */
        .pagination .page-link { color: #0A4174; }
        .pagination .page-item.active .page-link { background: #0A4174; border-color: #0A4174; color: white; }
        .pagination .page-link:hover { background: #BDD8E9; color: #001D39; }
        
        /* 5. Balance Card strictly using the darkest brand colors */
        .balance-card { 
            background: linear-gradient(135deg, #001D39, #0A4174); 
            color: #fff; 
            border-radius: 14px; 
            border: none; 
            box-shadow: 0 4px 12px rgba(0, 29, 57, 0.15);
        }
    </style>
</head>
<body>
<%@ include file="../../navbar.jsp" %>

<div class="container-fluid">
<div class="row flex-nowrap admin-layout-row">
<%@ include file="../sidebar.jsp" %>
<main class="col admin-main px-4 py-4">

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1">
                <i class="bi bi-wallet2-fill me-2"></i>Deposit Transactions
                <c:if test="${not empty contractId}">
                    <span class="fs-6 opacity-75 ms-2">— Contract #${contractId}</span>
                </c:if>
            </h4>
            <small class="opacity-75" style="color: #BDD8E9;">Manage deposit, refund and deduction records</small>
        </div>
        <a href="${pageContext.request.contextPath}/deposit?action=form<c:if test='${not empty contractId}'>&amp;contractId=${contractId}</c:if>"
           class="btn btn-light fw-semibold text-dark">
            <i class="bi bi-plus-circle-fill me-1" style="color: #0A4174;"></i>New Transaction
        </a>
    </div>

    <%-- Balance card (shown when viewing a single contract) --%>
    <c:if test="${not empty contractId}">
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card balance-card shadow-sm p-3">
                    <div class="small opacity-75 mb-1" style="color: #BDD8E9;"><i class="bi bi-shield-check me-1"></i>Current Deposit Balance</div>
                    <div class="fw-bold fs-4">
                        <fmt:formatNumber value="${balance}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                    </div>
                </div>
            </div>
            <%-- Stat counts --%>
            <div class="col-md-2">
                <div class="card stat-card shadow-sm text-center">
                    <c:set var="depositCount" value="0"/>
                    <c:forEach var="dt" items="${deposits}">
                        <c:if test="${dt.transactionType == 'deposit'}"><c:set var="depositCount" value="${depositCount + 1}"/></c:if>
                    </c:forEach>
                    <div class="fw-bold fs-4 text-success">${depositCount}</div>
                    <div class="text-muted small">Deposits</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card shadow-sm text-center">
                    <c:set var="refundCount" value="0"/>
                    <c:forEach var="dt" items="${deposits}">
                        <c:if test="${dt.transactionType == 'refund'}"><c:set var="refundCount" value="${refundCount + 1}"/></c:if>
                    </c:forEach>
                    <div class="fw-bold fs-4 text-info">${refundCount}</div>
                    <div class="text-muted small">Refunds</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card shadow-sm text-center">
                    <c:set var="deductCount" value="0"/>
                    <c:forEach var="dt" items="${deposits}">
                        <c:if test="${dt.transactionType == 'deduction'}"><c:set var="deductCount" value="${deductCount + 1}"/></c:if>
                    </c:forEach>
                    <div class="fw-bold fs-4 text-warning">${deductCount}</div>
                    <div class="text-muted small">Deductions</div>
                </div>
            </div>
        </div>
    </c:if>

    <%-- Stat cards for overview (no contractId) --%>
    <c:if test="${empty contractId}">
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="card stat-card shadow-sm text-center">
                    <c:set var="depositCount" value="0"/>
                    <c:forEach var="dt" items="${deposits}">
                        <c:if test="${dt.transactionType == 'deposit'}"><c:set var="depositCount" value="${depositCount + 1}"/></c:if>
                    </c:forEach>
                    <div class="fw-bold fs-4 text-success">${depositCount}</div>
                    <div class="text-muted small">Deposits</div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-card shadow-sm text-center">
                    <c:set var="refundCount" value="0"/>
                    <c:forEach var="dt" items="${deposits}">
                        <c:if test="${dt.transactionType == 'refund'}"><c:set var="refundCount" value="${refundCount + 1}"/></c:if>
                    </c:forEach>
                    <div class="fw-bold fs-4 text-info">${refundCount}</div>
                    <div class="text-muted small">Refunds</div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-card shadow-sm text-center">
                    <c:set var="deductCount" value="0"/>
                    <c:forEach var="dt" items="${deposits}">
                        <c:if test="${dt.transactionType == 'deduction'}"><c:set var="deductCount" value="${deductCount + 1}"/></c:if>
                    </c:forEach>
                    <div class="fw-bold fs-4 text-warning">${deductCount}</div>
                    <div class="text-muted small">Deductions</div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-card shadow-sm text-center">
                    <div class="fw-bold fs-4" style="color: #001D39;">${deposits.size()}</div>
                    <div class="text-muted small">Total</div>
                </div>
            </div>
        </div>
    </c:if>

    <%-- Table --%>
    <div class="card table-card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Contract</th>
                            <th>Room</th>
                            <th class="text-center">Type</th>
                            <th class="text-end">Amount</th>
                            <th>Note</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty deposits}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-3 d-block mb-2" style="color: #6EA2B3;"></i>No transactions found.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="dt" items="${deposits}">
                                    <tr>
                                        <td class="ps-4 text-muted small fw-semibold">#${dt.depositId}</td>
                                        <td class="fw-semibold" style="color: #0A4174;">#${dt.contractId}</td>
                                        <td>
                                            <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-3">
                                                ${not empty dt.roomNumber ? dt.roomNumber : '—'}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${dt.transactionType == 'deposit'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3">Deposit</span>
                                                </c:when>
                                                <c:when test="${dt.transactionType == 'refund'}">
                                                    <span class="badge bg-info-subtle text-info border border-info-subtle rounded-pill px-3">Refund</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-3">Deduction</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end fw-semibold">
                                            <c:choose>
                                                <c:when test="${dt.transactionType == 'deposit'}">
                                                    <span class="text-success">
                                                        +<fmt:formatNumber value="${dt.amount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-danger">
                                                        -<fmt:formatNumber value="${dt.amount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted small">${not empty dt.note ? dt.note : '—'}</td>
                                        <td class="text-muted small">${not empty dt.createdAt ? dt.createdAt : '—'}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

<%@ include file="../../footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</main>
</div>
</div>
</body>
</html>