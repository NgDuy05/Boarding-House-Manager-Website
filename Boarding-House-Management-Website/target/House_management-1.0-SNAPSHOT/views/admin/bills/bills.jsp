<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Bills - AKDD House</title>
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
        
        /* 2. Table Header using Light Blue & Very Dark Blue text */
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
        .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); } /* #7BBDE8 nhạt */
        
        .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }
        
        /* 4. Pagination using Dark Blue */
        .pagination .page-link { color: #0A4174; }
        .pagination .page-item.active .page-link { background: #0A4174; border-color: #0A4174; color: white; }
        .pagination .page-link:hover { background: #BDD8E9; color: #001D39; }

        /* 5. Custom Buttons to match the palette */
        .btn-theme-dark { background-color: #001D39; color: white; border: none; }
        .btn-theme-dark:hover { background-color: #0A4174; color: white; }

        .btn-outline-theme { border-color: #49769F; color: #49769F; }
        .btn-outline-theme:hover { background-color: #49769F; color: white; }

        .btn-outline-action-view { border-color: #4E8EA2; color: #4E8EA2; }
        .btn-outline-action-view:hover { background-color: #4E8EA2; color: white; }

        .btn-outline-action-edit { border-color: #0A4174; color: #0A4174; }
        .btn-outline-action-edit:hover { background-color: #0A4174; color: white; }
    </style>
</head>
<body>
<%@ include file="../../navbar.jsp" %>

<div class="container-fluid">
<div class="row flex-nowrap admin-layout-row">
<%@ include file="../sidebar.jsp" %>
<main class="col admin-main px-4 py-4">

    <%-- Flash messages --%>
    <c:if test="${not empty sessionScope.billSuccess}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.billSuccess}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("billSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.billError}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.billError}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("billError"); %>
    </c:if>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-receipt-fill me-2"></i>Bills</h4>
            <small class="opacity-75" style="color: #BDD8E9;">Manage all bills and payment statuses</small>
        </div>
        <a href="${pageContext.request.contextPath}/bill?action=create" class="btn btn-light fw-semibold text-dark">
            <i class="bi bi-plus-circle-fill me-1" style="color: #0A4174;"></i>Create Bill
        </a>
    </div>

    <%-- Stats --%>
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4" style="color: #001D39;">${totalItems}</div>
                <div class="text-muted small">Total</div>
            </div>
        </div>

        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-success">${paidCount}</div>
                <div class="text-muted small">Paid</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-danger">${unpaidCount}</div>
                <div class="text-muted small">Unpaid</div>
            </div>
        </div>
    </div>

    <%-- Filter --%>
    <div class="card table-card shadow-sm mb-4">
        <div class="card-body p-3">
            <form action="${pageContext.request.contextPath}/bill" method="get" class="row g-2 align-items-end">
                <input type="hidden" name="action" value="list">
                <div class="col-md-5">
                    <label class="form-label small fw-semibold text-muted mb-1">Search</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="search" class="form-control" placeholder="Contract ID, period..." value="${search}">
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold text-muted mb-1">Status</label>
                    <select name="status" class="form-select">
                        <option value="">All</option>
                        <option value="paid"    ${statusFilter == 'paid'    ? 'selected' : ''}>Paid</option>
                        <option value="pending" ${statusFilter == 'pending' ? 'selected' : ''}>Unpaid</option>
                    </select>
                </div>
                <div class="col-md-2"><button type="submit" class="btn btn-theme-dark w-100"><i class="bi bi-funnel me-1"></i>Filter</button></div>
                <div class="col-md-2"><a href="${pageContext.request.contextPath}/bill?action=list" class="btn btn-outline-theme w-100"><i class="bi bi-x-circle me-1"></i>Clear</a></div>
            </form>
        </div>
    </div>

    <%-- Table --%>
    <div class="card table-card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Contract</th>
                            <th>Period</th>
                            <th>Due Date</th>
                            <th class="text-end">Total</th>
                            <th class="text-center">Status</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty bills}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-3 d-block mb-2" style="color: #6EA2B3;"></i>No bills found.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="b" items="${bills}">
                                    <tr>
                                        <td class="ps-4 text-muted small fw-semibold">#${b.billId}</td>
                                        <td>
                                            <div class="fw-semibold" style="color: #0A4174;">#${b.contractId}</div>
                                        </td>
                                        <td class="small">${b.period}</td>
                                        <td class="small text-muted">${b.dueDate}</td>
                                        <td class="text-end fw-semibold small">
                                            <c:if test="${not empty b.totalAmount}">
                                                <fmt:formatNumber value="${b.totalAmount}"
                                                    groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </c:if>
                                            <c:if test="${empty b.totalAmount}">—</c:if>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${b.status == 'paid'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3">Paid</span>
                                                </c:when>
                                                <c:when test="${b.status == 'pending'}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3">Unpaid</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-3">${b.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center pe-4">
                                            <a href="${pageContext.request.contextPath}/bill?action=detail&id=${b.billId}"
                                               class="btn btn-sm btn-outline-action-view me-1" title="View">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/bill?action=edit&id=${b.billId}"
                                               class="btn btn-sm btn-outline-action-edit me-1" title="Edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/bill?action=delete&id=${b.billId}"
                                               class="btn btn-sm btn-outline-danger" title="Delete"
                                               onclick="return confirm('Delete bill #${b.billId}?')">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- Pagination --%>
            <c:if test="${totalPages > 1}">
                <div class="d-flex justify-content-between align-items-center px-4 py-3 border-top">
                    <div class="text-muted small">
                        Showing <strong>${(currentPage - 1) * pageSize + 1}</strong>–<strong>${(currentPage - 1) * pageSize + bills.size()}</strong>
                        of <strong>${totalItems}</strong> bills
                    </div>
                    <nav><ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/bill?action=list&page=${currentPage - 1}&status=${statusFilter}&search=${search}">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:choose>
                                <c:when test="${p == currentPage}"><li class="page-item active"><span class="page-link">${p}</span></li></c:when>
                                <c:when test="${p == 1 || p == totalPages || (p >= currentPage - 2 && p <= currentPage + 2)}">
                                    <li class="page-item"><a class="page-link" href="${pageContext.request.contextPath}/bill?action=list&page=${p}&status=${statusFilter}&search=${search}">${p}</a></li>
                                </c:when>
                                <c:when test="${(p == currentPage - 3 && currentPage > 4) || (p == currentPage + 3 && currentPage < totalPages - 3)}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/bill?action=list&page=${currentPage + 1}&status=${statusFilter}&search=${search}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul></nav>
                </div>
            </c:if>
        </div>
    </div>

<%@ include file="../../footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</main>
</div>
</div>
</body>
</html>