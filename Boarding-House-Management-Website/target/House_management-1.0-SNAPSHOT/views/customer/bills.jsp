<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>My Bills - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css");

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
        }

        .page-header {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            color: white;
            border-radius: 16px;
            padding: 24px 28px;
            margin-bottom: 24px;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }

        .table-card { 
            border-radius: 16px; 
            border: none; 
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
            overflow: hidden;
        }
        .table thead th { 
            background-color: var(--ocean-100) !important; 
            color: var(--ocean-900) !important; 
            font-size: 13px; 
            font-weight: 700; 
            text-transform: uppercase; 
            letter-spacing: 0.5px; 
            border: none; 
            padding: 14px 16px;
        }
        .table tbody tr:hover { background-color: rgba(0, 119, 182, 0.05) !important; }
        .table td { padding: 14px 16px; vertical-align: middle; }

        .status-badge {
            font-size: 12px;
            padding: 6px 14px;
            border-radius: 20px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-paid    { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .badge-unpaid  { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; }

        /* ── Final Bill ── */
        .badge-final   { background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7;
                         font-size: 10px; padding: 3px 8px; border-radius: 20px;
                         font-weight: 700; letter-spacing: .4px; }
        .final-row     { background-color: rgba(220,53,69,.04) !important; }
        .final-row:hover { background-color: rgba(220,53,69,.09) !important; }

        .btn-outline-ocean {
            color: var(--ocean-600);
            border-color: var(--ocean-500);
            font-weight: 600;
            border-radius: 8px;
        }
        .btn-outline-ocean:hover {
            background-color: var(--ocean-600);
            border-color: var(--ocean-600);
            color: white;
        }
        .btn-pay {
            background-color: #198754;
            color: white;
            font-weight: 600;
            border-radius: 8px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .btn-pay:hover {
            background-color: #157347;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(25, 135, 84, 0.3);
        }

        .pagination .page-link { color: var(--ocean-800); border-color: #dee2e6; font-weight: 500; }
        .pagination .page-item.active .page-link { background-color: var(--ocean-800); border-color: var(--ocean-800); color: white; font-weight: 700; }
        .pagination .page-link:hover { background-color: var(--ocean-100); color: var(--ocean-900); }
    </style>
</head>
<body style="overflow-x:hidden;">
<%@ include file="../navbar.jsp" %>

<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4">
    
    <div class="page-header d-flex justify-content-between align-items-center">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-receipt me-2"></i>My Bills</h4>
            <div class="opacity-75 small">Review your billing history and payments</div>
        </div>
    </div>

    <div class="card table-card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table mb-0 align-middle">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Period</th>
                            <th>Due Date</th>
                            <th class="text-end">Total</th>
                            <th class="text-center">Status</th>
                            <th class="text-center">Detail</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty bills}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-5">
                                        <i class="bi bi-inbox fs-1 d-block mb-3" style="color: var(--ocean-200);"></i>
                                        <h6 class="fw-semibold" style="color: var(--ocean-800);">No bills yet.</h6>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="b" items="${bills}">
                                    <c:set var="isFinal" value="${billContractStatus[b.billId] == 'terminated'}" />
                                    <tr class="${isFinal ? 'final-row' : ''}">
                                        <td class="ps-4 text-muted small fw-semibold">#${b.billId}</td>
                                        <td class="fw-semibold" style="color: var(--ocean-900);">
                                            ${b.period}
                                            <c:if test="${isFinal}">
                                                <span class="badge-final ms-1">
                                                    <i class="bi bi-flag-fill me-1"></i>Final Bill
                                                </span>
                                            </c:if>
                                        </td>
                                        <td class="text-muted small">${b.dueDate}</td>
                                        <td class="text-end fw-bold" style="color: var(--ocean-800); font-size: 15px;">
                                            <c:choose>
                                                <c:when test="${not empty b.totalAmount}">
                                                    <fmt:formatNumber value="${b.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${b.status == 'paid'}">
                                                    <span class="badge status-badge badge-paid">
                                                        <i class="bi bi-check-circle-fill me-1"></i>Paid
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge status-badge badge-unpaid">
                                                        <i class="bi bi-exclamation-circle-fill me-1"></i>Unpaid
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/bill?action=detail&id=${b.billId}"
                                               class="btn btn-sm btn-outline-ocean" title="View Detail">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                        </td>
                                        <td class="text-center pe-4">
                                            <c:choose>
                                                <c:when test="${b.status eq 'pending'}">
                                                  <form method="post" action="${pageContext.request.contextPath}/payment" style="display:inline">
                                                    <input type="hidden" name="action" value="pay"/>
                                                    <input type="hidden" name="billId" value="${b.billId}"/>
                                                    <button type="submit" class="btn btn-sm btn-pay px-3">
                                                        <i class="bi bi-credit-card me-1"></i>Pay Now
                                                    </button>
                                                  </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        
        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white d-flex justify-content-between align-items-center px-4 py-3 border-top">
                <div class="text-muted small">
                    Showing <strong>${(currentPage - 1) * pageSize + 1}</strong>–<strong>${(currentPage - 1) * pageSize + bills.size()}</strong>
                    of <strong>${totalItems}</strong> bills
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/bill?action=mybill&page=${currentPage - 1}">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:choose>
                                <c:when test="${p == currentPage}">
                                    <li class="page-item active"><span class="page-link">${p}</span></li>
                                </c:when>
                                <c:when test="${p == 1 || p == totalPages || (p >= currentPage - 2 && p <= currentPage + 2)}">
                                    <li class="page-item">
                                        <a class="page-link" href="${pageContext.request.contextPath}/bill?action=mybill&page=${p}">${p}</a>
                                    </li>
                                </c:when>
                                <c:when test="${(p == currentPage - 3 && currentPage > 4) || (p == currentPage + 3 && currentPage < totalPages - 3)}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/bill?action=mybill&page=${currentPage + 1}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
    
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
