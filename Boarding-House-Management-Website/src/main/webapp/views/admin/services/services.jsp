<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
    
    .page-header .btn-outline-light { border: 1px solid rgba(255,255,255,0.5); color: #fff; font-weight: 600; }
    .page-header .btn-outline-light:hover { background: rgba(255,255,255,0.15); border-color: #fff; color: #fff; }

    /* 2. Table styling */
    .table-card { border-radius: 14px; border: none; overflow: hidden; }
    .table thead th { 
        background: #BDD8E9 !important; 
        color: #001D39 !important; 
        font-size: 12px; 
        font-weight: 700; 
        text-transform: uppercase; 
        letter-spacing: .5px; 
        border: none; 
    }
    .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); }
    
    /* 3. Pagination */
    .pagination .page-link { color: #0A4174; border-color: #dee2e6; }
    .pagination .page-item.active .page-link { background-color: #0A4174; border-color: #0A4174; color: white; }
    .pagination .page-link:hover { background-color: #BDD8E9; color: #001D39; }

    /* 4. Custom Buttons & Elements */
    .btn-theme-dark { background-color: #001D39; color: white; border: none; }
    .btn-theme-dark:hover { background-color: #0A4174; color: white; }

    .btn-outline-action-edit { border-color: #0A4174; color: #0A4174; }
    .btn-outline-action-edit:hover { background-color: #0A4174; color: white; }
    
    .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }
</style>

    <%-- Page header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-gear-wide-connected me-2"></i>Manage Services</h4>
            <small class="opacity-75" style="color: #BDD8E9;">Add, edit, or remove services offered to tenants</small>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/services?action=requestList"
               class="btn btn-outline-light">
                <i class="bi bi-list-check me-1"></i>Service Request List
            </a>
            <a href="${pageContext.request.contextPath}/services?action=create"
               class="btn btn-light text-dark">
                <i class="bi bi-plus-circle me-1" style="color: #0A4174;"></i>Add Service
            </a>
        </div>
    </div>

    <%-- Stats bar --%>
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card stat-card shadow-sm">
                <div class="card-body d-flex align-items-center gap-3 p-0">
                    <div class="rounded-circle p-3" style="background: rgba(10, 65, 116, 0.1);">
                        <i class="bi bi-grid-3x3-gap-fill fs-4" style="color: #0A4174;"></i>
                    </div>
                    <div>
                        <div class="fs-4 fw-bold" style="color: #001D39;">${services.size() - hiddenCount}</div>
                        <div class="text-muted small">Active Services</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card stat-card shadow-sm">
                <div class="card-body d-flex align-items-center gap-3 p-0">
                    <div class="rounded-circle p-3" style="background:#fee2e2">
                        <i class="bi bi-eye-slash-fill fs-4" style="color:#dc2626"></i>
                    </div>
                    <div>
                        <div class="fs-4 fw-bold text-danger">${hiddenCount}</div>
                        <div class="text-muted small">Hidden Services</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Service table --%>
    <div class="card table-card shadow-sm border-0">
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty services}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-4">#</th>
                                    <th>Service Name</th>
                                    <th>Category</th>
                                    <th>Price</th>
                                    <th>Description</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-center pe-4">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="svc" items="${services}" varStatus="st">
                                    <tr class="${svc.isDeleted ? 'table-secondary text-muted' : ''}">
                                        <td class="ps-4 text-muted small">${st.count}</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle p-2
                                                     ${svc.isDeleted
                                                         ? 'bg-secondary bg-opacity-10'
                                                         : ''}"
                                                     style="${!svc.isDeleted ? 'background: rgba(10, 65, 116, 0.1);' : ''}">
                                                    <i class="bi bi-lightning-charge
                                                       ${svc.isDeleted ? 'text-secondary' : ''}"
                                                       style="${!svc.isDeleted ? 'color: #0A4174;' : ''}"></i>
                                                </div>
                                                <span class="fw-semibold
                                                     ${svc.isDeleted ? 'text-decoration-line-through text-muted' : ''}"
                                                      style="${!svc.isDeleted ? 'color: #0A4174;' : ''}">
                                                    ${svc.serviceName}
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge border" style="background: rgba(73, 118, 159, 0.1); color: #49769F; border-color: rgba(73, 118, 159, 0.2) !important;">
                                                Cat. ${svc.categoryId}
                                            </span>
                                        </td>
                                        <td>
                                            <c:set var="price" value="${priceMap[svc.categoryId]}"/>
                                            <c:set var="unit"  value="${unitMap[svc.categoryId]}"/>
                                            <c:choose>
                                                <c:when test="${not empty price and price > 0}">
                                                    <span class="fw-semibold" style="color: #001D39;">
                                                        <fmt:formatNumber value="${price}" type="number" maxFractionDigits="0"/> đ
                                                    </span>
                                                    <c:if test="${not empty unit}">
                                                        <span class="text-muted small">/ ${unit}</span>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted small">
                                            <c:choose>
                                                <c:when test="${not empty svc.description}">${svc.description}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${svc.isDeleted}">
                                                    <span class="badge rounded-pill bg-danger bg-opacity-10 text-danger border border-danger-subtle px-3">
                                                        <i class="bi bi-eye-slash me-1"></i>Hidden
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge rounded-pill bg-success bg-opacity-10 text-success border border-success-subtle px-3">
                                                        <i class="bi bi-eye me-1"></i>Active
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center pe-4">
                                            <div class="d-flex justify-content-center gap-1">
                                                <c:if test="${not svc.isDeleted}">
                                                    <a href="${pageContext.request.contextPath}/services?action=edit&id=${svc.serviceId}"
                                                       class="btn btn-sm btn-outline-action-edit" title="Edit">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/services?action=hide&id=${svc.serviceId}"
                                                       class="btn btn-sm btn-outline-danger" title="Hide from customers"
                                                       onclick="return confirm('Hide service \'${svc.serviceName}\' from customers?')">
                                                        <i class="bi bi-eye-slash"></i>
                                                    </a>
                                                </c:if>
                                                <c:if test="${svc.isDeleted}">
                                                    <a href="${pageContext.request.contextPath}/services?action=restore&id=${svc.serviceId}"
                                                       class="btn btn-sm btn-outline-success" title="Restore service"
                                                       onclick="return confirm('Restore service \'${svc.serviceName}\'?')">
                                                        <i class="bi bi-eye"></i> Restore
                                                    </a>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-inbox fs-1 d-block mb-3" style="color: #6EA2B3;"></i>
                        <p class="mb-3">No services found.</p>
                        <a href="${pageContext.request.contextPath}/services?action=create"
                           class="btn btn-theme-dark">
                            <i class="bi bi-plus-circle me-1"></i>Add First Service
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white d-flex justify-content-between align-items-center border-top px-4 py-3">
                <div class="text-muted small">
                    Page <strong>${currentPage}</strong> of <strong>${totalPages}</strong>
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?action=adminList&page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <a class="page-link" href="?action=adminList&page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?action=adminList&page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>

</t:layout>