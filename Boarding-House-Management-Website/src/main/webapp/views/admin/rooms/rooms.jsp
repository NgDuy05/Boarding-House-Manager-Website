<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

<style>
    .page-header {
        background: linear-gradient(135deg, #062a4e, #0A4174, #1a6aad);
        color: #ffffff;
        border-radius: 12px;
        padding: 20px 24px;
        margin-bottom: 24px;
    }
    .page-header .btn-dark { background: rgba(255,255,255,0.15); border: none; color: #ffffff; font-weight: 600; }
    .page-header .btn-dark:hover { background: rgba(255,255,255,0.28); }
    .table-card  { border-radius: 14px; border: none; }
    .table thead th { background: #f8f9fa; color: #6c757d; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; border: none; }
    .table tbody tr:hover { background: #f0f4ff; }
    .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }
    .pagination .page-link { color: #0A4174; }
    .pagination .page-item.active .page-link { background: #0A4174; border-color: #0A4174; color: #ffffff; font-weight: 700; }
</style>

    <%-- Flash messages --%>
    <c:if test="${not empty sessionScope.roomSuccess}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.roomSuccess}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="roomSuccess" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.roomError}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.roomError}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="roomError" scope="session"/>
    </c:if>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-door-open-fill me-2"></i>Room List</h4>
            <small class="opacity-75">Manage all rooms and their availability</small>
        </div>
        <a href="${pageContext.request.contextPath}/room?action=create" class="btn btn-dark fw-semibold">
            <i class="bi bi-plus-circle-fill me-1"></i>Add Room
        </a>
    </div>

    <%-- Stats --%>
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-success">${availableCount}</div>
                <div class="text-muted small">Available</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-danger">${occupiedCount}</div>
                <div class="text-muted small">Occupied</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-warning">${maintenanceCount}</div>
                <div class="text-muted small">Maintenance</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-dark">${totalRooms}</div>
                <div class="text-muted small">Total</div>
            </div>
        </div>
    </div>

    <%-- Filter --%>
    <div class="card table-card shadow-sm mb-4">
        <div class="card-body p-3">
            <form action="${pageContext.request.contextPath}/room" method="get" class="row g-2 align-items-end">
                <input type="hidden" name="action" value="list">
                <div class="col-md-5">
                    <label class="form-label small fw-semibold text-muted mb-1">Search</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" name="search" class="form-control" placeholder="Room number..." value="${search}">
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold text-muted mb-1">Status</label>
                    <select name="status" class="form-select">
                        <option value="">All</option>
                        <option value="available"   ${statusFilter == 'available'   ? 'selected' : ''}>Available</option>
                        <option value="occupied"    ${statusFilter == 'occupied'    ? 'selected' : ''}>Occupied</option>
                        <option value="maintenance" ${statusFilter == 'maintenance' ? 'selected' : ''}>Maintenance</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn w-100 fw-semibold" style="background:#0A4174; border:none; color:#ffffff;">
                        <i class="bi bi-funnel me-1"></i>Filter
                    </button>
                </div>
                <div class="col-md-2">
                    <a href="${pageContext.request.contextPath}/room?action=list" class="btn btn-outline-secondary w-100">
                        <i class="bi bi-x-circle me-1"></i>Clear
                    </a>
                </div>
            </form>
        </div>
    </div>

    <%-- Table --%>
    <div class="card table-card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Room Number</th>
                            <th>Category</th>
                            <th class="text-center">Status</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="room" items="${rooms}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index + 1}</td>
                                <td>
                                    <div class="fw-semibold"><i class="bi bi-house me-1 text-secondary"></i>${room.roomNumber}</div>
                                </td>
                                <td>
                                    <div class="text-muted small">${not empty room.categoryName ? room.categoryName : '—'}</div>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${room.status == 'available'}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3">Available</span>
                                        </c:when>
                                        <c:when test="${room.status == 'occupied'}">
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3">Occupied</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-3">Maintenance</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="${pageContext.request.contextPath}/room?action=detail&id=${room.roomId}"
                                       class="btn btn-sm btn-outline-info me-1" title="Detail">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/room?action=edit&id=${room.roomId}"
                                       class="btn btn-sm btn-outline-primary me-1" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/room?action=delete&id=${room.roomId}"
                                       class="btn btn-sm btn-outline-danger" title="Delete"
                                       onclick="return confirm('Are you sure you want to delete room ${room.roomNumber}?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty rooms}">
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                    <i class="bi bi-inbox fs-3 d-block mb-2"></i>No rooms found.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <%-- Pagination --%>
            <c:if test="${totalPages > 1}">
                <div class="d-flex justify-content-between align-items-center px-4 py-3 border-top">
                    <div class="text-muted small">
                        Showing <strong>${(currentPage - 1) * pageSize + 1}</strong>–<strong>${(currentPage - 1) * pageSize + rooms.size()}</strong>
                        of <strong>${totalRooms}</strong> rooms
                    </div>
                    <nav><ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?action=list&page=${currentPage - 1}&status=${statusFilter}&search=${search}">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <li class="page-item active"><span class="page-link">${i}</span></li>
                                </c:when>
                                <c:when test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                    <li class="page-item"><a class="page-link" href="?action=list&page=${i}&status=${statusFilter}&search=${search}">${i}</a></li>
                                </c:when>
                                <c:when test="${(i == currentPage - 3 && currentPage > 4) || (i == currentPage + 3 && currentPage < totalPages - 3)}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?action=list&page=${currentPage + 1}&status=${statusFilter}&search=${search}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul></nav>
                </div>
            </c:if>
        </div>
    </div>

</t:layout>
