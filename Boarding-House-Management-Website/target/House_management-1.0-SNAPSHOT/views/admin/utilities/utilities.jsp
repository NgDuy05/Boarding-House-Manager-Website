<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t"   tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

<style>
    /* 1. Header Gradient using the dark blues */
    .page-header {
        background: linear-gradient(135deg, #001D39, #0A4174, #49769F);
        color: white;
        border-radius: 12px;
        padding: 20px 24px;
        margin-bottom: 24px;
        box-shadow: 0 4px 12px rgba(0, 29, 57, 0.15);
    }
    .page-header .btn-light { background: #fff; border: none; color: #001D39; font-weight: 600; }
    .page-header .btn-light:hover { background: #BDD8E9; color: #001D39; }
    
    /* 2. Table styling */
    .table-card { border-radius: 14px; border: none; }
    .table thead th { 
        background: #BDD8E9; 
        color: #001D39; 
        font-size: 12px; 
        font-weight: 700; 
        text-transform: uppercase; 
        letter-spacing: .5px; 
        border: none; 
    }
    .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); }
    .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }
    
    /* 3. Pagination using Dark Blue */
    .pagination .page-link { color: #0A4174; border-color: #dee2e6; }
    .pagination .page-item.active .page-link { background-color: #0A4174; border-color: #0A4174; color: white; }
    .pagination .page-link:hover { background: #BDD8E9; color: #001D39; }

    /* 4. Custom Action Buttons */
    .btn-outline-action-view { border-color: #4E8EA2; color: #4E8EA2; }
    .btn-outline-action-view:hover { background-color: #4E8EA2; color: white; }

    .btn-outline-action-edit { border-color: #0A4174; color: #0A4174; }
    .btn-outline-action-edit:hover { background-color: #0A4174; color: white; }
</style>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-lightning-charge-fill me-2"></i>Utilities</h4>
            <small class="opacity-75" style="color: #BDD8E9;">Manage usage-based services: Electricity, Water, Gas, etc.</small>
        </div>
        <a href="${pageContext.request.contextPath}/utility?action=create" class="btn btn-light fw-semibold text-dark">
            <i class="bi bi-plus-circle-fill me-1" style="color: #0A4174;"></i>Add Utility
        </a>
    </div>

    <%-- Stats --%>
    <c:set var="activeCount" value="0"/>
    <c:forEach var="u" items="${utilities}">
        <c:if test="${not u.isDeleted}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
    </c:forEach>

    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-success">${activeCount}</div>
                <div class="text-muted small">Active</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-danger">${utilities.size() - activeCount}</div>
                <div class="text-muted small">Hidden</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4" style="color: #001D39;">${utilities.size()}</div>
                <div class="text-muted small">Total</div>
            </div>
        </div>
    </div>

    <%-- Table --%>
    <div class="card table-card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Name</th>
                            <th>Unit</th>
                            <th>Description</th>
                            <th class="text-center">Status</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty utilities}">
                                <c:forEach var="u" items="${utilities}" varStatus="st">
                                    <tr class="${u.isDeleted ? 'table-secondary' : ''}">
                                        <td class="ps-4 text-muted small">${st.count}</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle p-2 ${u.isDeleted ? 'bg-secondary bg-opacity-10' : ''}"
                                                     style="${not u.isDeleted ? 'background: rgba(123, 189, 232, 0.2);' : ''}">
                                                    <i class="bi bi-lightning-charge ${u.isDeleted ? 'text-secondary' : ''}"
                                                       style="${not u.isDeleted ? 'color:#0A4174;' : ''}"></i>
                                                </div>
                                                <span class="fw-semibold ${u.isDeleted ? 'text-decoration-line-through text-muted' : ''}"
                                                      style="${not u.isDeleted ? 'color: #0A4174;' : ''}">
                                                    ${u.utilityName}
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge border" style="background: rgba(73, 118, 159, 0.1); color: #49769F; border-color: rgba(73, 118, 159, 0.2) !important;">
                                                ${u.unit}
                                            </span>
                                        </td>
                                        <td class="text-muted small">
                                            <c:choose>
                                                <c:when test="${not empty u.description}">${u.description}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${u.isDeleted}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3">
                                                        <i class="bi bi-eye-slash me-1"></i>Hidden
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3">
                                                        <i class="bi bi-eye me-1"></i>Active
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center pe-4">
                                            <c:if test="${not u.isDeleted}">
                                                <a href="${pageContext.request.contextPath}/utility?action=detail&id=${u.utilityId}"
                                                   class="btn btn-sm btn-outline-action-view me-1" title="View">
                                                    <i class="bi bi-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/utility?action=edit&id=${u.utilityId}"
                                                   class="btn btn-sm btn-outline-action-edit me-1" title="Edit">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/utility?action=hide&id=${u.utilityId}"
                                                   class="btn btn-sm btn-outline-secondary" title="Hide"
                                                   onclick="return confirm('Hide utility \'${u.utilityName}\'?')">
                                                    <i class="bi bi-eye-slash"></i>
                                                </a>
                                            </c:if>
                                            <c:if test="${u.isDeleted}">
                                                <a href="${pageContext.request.contextPath}/utility?action=restore&id=${u.utilityId}"
                                                   class="btn btn-sm btn-outline-action-view" title="Restore"
                                                   onclick="return confirm('Restore utility \'${u.utilityName}\'?')">
                                                    <i class="bi bi-arrow-counterclockwise me-1"></i>Restore
                                                </a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-3 d-block mb-2" style="color: #6EA2B3;"></i>No utilities found.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- Pagination --%>
            <c:if test="${totalPages > 1}">
                <div class="d-flex justify-content-between align-items-center px-4 py-3 border-top">
                    <div class="text-muted small">
                        Page <strong>${currentPage}</strong> of <strong>${totalPages}</strong>
                    </div>
                    <nav><ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <li class="page-item active"><span class="page-link">${i}</span></li>
                                </c:when>
                                <c:when test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                    <li class="page-item"><a class="page-link" href="?page=${i}">${i}</a></li>
                                </c:when>
                                <c:when test="${(i == currentPage - 3 && currentPage > 4) || (i == currentPage + 3 && currentPage < totalPages - 3)}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a>
                        </li>
                    </ul></nav>
                </div>
            </c:if>
        </div>
    </div>

</t:layout>