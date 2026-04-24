<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Rental Contracts - AKDD House</title>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
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
    <c:if test="${not empty sessionScope.contractSuccess}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.contractSuccess}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("contractSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.contractError}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.contractError}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("contractError"); %>
    </c:if>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-file-earmark-text-fill me-2"></i>Rental Contracts</h4>
            <small class="opacity-75" style="color: #BDD8E9;">Manage all rental contracts, tenants and billing</small>
        </div>
        <a href="${pageContext.request.contextPath}/contract?action=create" class="btn btn-light fw-semibold text-dark">
            <i class="bi bi-plus-circle-fill me-1" style="color: #0A4174;"></i>New Contract
        </a>
    </div>

    <%-- Stats --%>
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-success">${activeCount}</div>
                <div class="text-muted small">Active</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-danger">${terminatedCount}</div>
                <div class="text-muted small">Terminated</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4" style="color: #001D39;">${totalItems}</div>
                <div class="text-muted small">Total</div>
            </div>
        </div>
    </div>

    <%-- Filter --%>
    <div class="card table-card shadow-sm mb-4">
        <div class="card-body p-3">
            <form action="${pageContext.request.contextPath}/contract" method="get" class="row g-2 align-items-end">
                <input type="hidden" name="action" value="list">
                <div class="col-md-5">
                    <label class="form-label small fw-semibold text-muted mb-1">Search</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="search" class="form-control" placeholder="Room number, tenant name..." value="${search}">
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold text-muted mb-1">Status</label>
                    <select name="status" class="form-select">
                        <option value="">All</option>
                        <option value="active"     ${statusFilter == 'active'     ? 'selected' : ''}>Active</option>
                        <option value="terminated" ${statusFilter == 'terminated' ? 'selected' : ''}>Terminated</option>
                        <option value="expired"    ${statusFilter == 'expired'    ? 'selected' : ''}>Expired</option>
                    </select>
                </div>
                <div class="col-md-2"><button type="submit" class="btn btn-theme-dark w-100"><i class="bi bi-funnel me-1"></i>Filter</button></div>
                <div class="col-md-2"><a href="${pageContext.request.contextPath}/contract?action=list" class="btn btn-outline-theme w-100"><i class="bi bi-x-circle me-1"></i>Clear</a></div>
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
                            <th>Room</th>
                            <th>Primary Tenant</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                            <th>Deposit</th>
                            <th class="text-center">Tenants</th>
                            <th class="text-center">Status</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty contracts}">
                                <tr><td colspan="9" class="text-center py-5 text-muted">
                                    <i class="bi bi-file-earmark-x fs-3 d-block mb-2" style="color: #6EA2B3;"></i>No contracts found
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="c" items="${contracts}">
                                    <tr>
                                        <td class="ps-4 text-muted small fw-semibold">#${c.contractId}</td>
                                        <td>
                                            <div class="fw-semibold" style="color: #0A4174;">Room ${not empty c.roomNumber ? c.roomNumber : c.roomId}</div>
                                            <div class="text-muted small">${c.categoryName}</div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty c.primaryTenantName}">
                                                    <div class="fw-semibold">${c.primaryTenantName}</div>
                                                    <div class="text-muted small">@${c.primaryTenantUsername}</div>
                                                </c:when>
                                                <c:otherwise><span class="text-muted small">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small">${c.startDate}</td>
                                        <td class="small text-muted">${not empty c.endDate ? c.endDate : '—'}</td>
                                        <td class="small fw-semibold">${c.deposit}&#8363;</td>
                                        <td class="text-center">
                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill">${c.tenantCount}</span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-${c.statusColor}-subtle text-${c.statusColor} border border-${c.statusColor}-subtle rounded-pill px-3">
                                                ${c.statusLabel}
                                            </span>
                                        </td>
                                        <td class="text-center pe-4">
                                            <a href="${pageContext.request.contextPath}/contract?action=detail&id=${c.contractId}"
                                               class="btn btn-sm btn-outline-action-view me-1" title="View Detail"><i class="bi bi-eye"></i></a>
                                            <a href="${pageContext.request.contextPath}/contract?action=edit&id=${c.contractId}"
                                               class="btn btn-sm btn-outline-action-edit me-1" title="Edit"><i class="bi bi-pencil"></i></a>
                                            <c:if test="${c.status == 'active'}">
                                                <button class="btn btn-sm btn-outline-danger me-1" title="Terminate"
                                                    onclick="confirmTerminate(${c.contractId}, ${c.roomId}, '${c.roomNumber}')">
                                                    <i class="bi bi-x-circle"></i>
                                                </button>
                                            </c:if>
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
                        Showing <strong>${(currentPage-1)*pageSize+1}</strong>–<strong>${(currentPage-1)*pageSize+contracts.size()}</strong>
                        of <strong>${totalItems}</strong> contracts
                    </div>
                    <nav><ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage==1?'disabled':''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/contract?action=list&page=${currentPage-1}&status=${statusFilter}&search=${search}"><i class="bi bi-chevron-left"></i></a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:choose>
                                <c:when test="${p==currentPage}"><li class="page-item active"><span class="page-link">${p}</span></li></c:when>
                                <c:when test="${p==1||p==totalPages||(p>=currentPage-2&&p<=currentPage+2)}">
                                    <li class="page-item"><a class="page-link" href="${pageContext.request.contextPath}/contract?action=list&page=${p}&status=${statusFilter}&search=${search}">${p}</a></li>
                                </c:when>
                                <c:when test="${(p==currentPage-3&&currentPage>4)||(p==currentPage+3&&currentPage<totalPages-3)}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage==totalPages?'disabled':''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/contract?action=list&page=${currentPage+1}&status=${statusFilter}&search=${search}"><i class="bi bi-chevron-right"></i></a>
                        </li>
                    </ul></nav>
                </div>
            </c:if>
        </div>
    </div>
</div>

<%-- Terminate modal --%>
<div class="modal fade" id="terminateModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold text-danger"><i class="bi bi-x-circle me-2"></i>Terminate Contract</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="text-muted">Are you sure you want to terminate contract <strong id="termId"></strong> for <strong id="termRoom"></strong>?
                This will free the room and cannot be undone.</p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                <a id="termBtn" href="#" class="btn btn-danger"><i class="bi bi-x-circle me-1"></i>Terminate</a>
            </div>
        </div>
    </div>
</div>

<script>
function confirmTerminate(id, roomId, roomNum) {
    document.getElementById('termId').textContent = '#' + id;
    document.getElementById('termRoom').textContent = 'Room ' + roomNum;
    document.getElementById('termBtn').href =
        '${pageContext.request.contextPath}/contract?action=terminate&id=' + id + '&roomId=' + roomId;
    new bootstrap.Modal(document.getElementById('terminateModal')).show();
}
</script>
<%@ include file="../../footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</main>
</div>
</div>
</body>
</html>