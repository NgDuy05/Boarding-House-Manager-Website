<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t"   tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<t:layout>

<style>
    .page-header {
        background: linear-gradient(135deg, #3d7d91, #6EA2B3, #9dc3d0);
        color: #fff;
        border-radius: 12px;
        padding: 20px 24px;
        margin-bottom: 24px;
    }
    .page-header .btn-light { background: rgba(255,255,255,0.2); border: none; color: #fff; font-weight: 600; }
    .page-header .btn-light:hover { background: rgba(255,255,255,0.35); }

    /* Filter tabs */
    .filter-tabs { border-bottom: 2px solid #e0edf1; margin-bottom: 20px; }
    .filter-tabs .nav-link {
        color: #6c757d; border: none; border-bottom: 2px solid transparent;
        margin-bottom: -2px; padding: 8px 16px; font-weight: 500; border-radius: 0;
    }
    .filter-tabs .nav-link:hover { color: #6EA2B3; }
    .filter-tabs .nav-link.active { color: #6EA2B3; border-bottom-color: #6EA2B3; background: transparent; }

    .table-card { border-radius: 14px; border: none; }
    .table thead th { background: #f8f9fa; color: #6c757d; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; border: none; }
    .table tbody tr:hover { background: #edf5f8; }
    .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }
</style>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-tags-fill me-2"></i>Categories Price</h4>
            <small class="opacity-75">Manage pricing categories for rent, utilities, services and facilities</small>
        </div>
        <a href="${pageContext.request.contextPath}/price?action=create" class="btn btn-light fw-semibold">
            <i class="bi bi-plus-circle-fill me-1"></i>Add Category
        </a>
    </div>

    <%-- Stat cards --%>
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4 text-dark">${fn:length(categories)}</div>
                <div class="text-muted small">Total</div>
            </div>
        </div>
    </div>

    <%-- Filter tabs --%>
    <c:set var="type" value="${param.type}"/>
    <ul class="nav filter-tabs">
        <li class="nav-item">
            <a class="nav-link ${empty type ? 'active' : ''}"
               href="${pageContext.request.contextPath}/price?action=categories">All</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'rent' ? 'active' : ''}"
               href="?action=categories&type=rent">
                <span class="badge bg-primary rounded-pill">Rent</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'utility' ? 'active' : ''}"
               href="?action=categories&type=utility">
                <span class="badge bg-info text-dark rounded-pill">Utility</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'service' ? 'active' : ''}"
               href="?action=categories&type=service">
                <span class="badge bg-success rounded-pill">Service</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'facility' ? 'active' : ''}"
               href="?action=categories&type=facility">
                <span class="badge bg-secondary rounded-pill">Facility</span>
            </a>
        </li>
    </ul>

    <%-- Table --%>
    <div class="card table-card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Category Code</th>
                            <th class="text-center">Type</th>
                            <th>Unit</th>
                            <th>Current Price</th>
                            <th>Future Price</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty categories}">
                                <c:forEach var="cat" items="${categories}" varStatus="s">
                                    <tr>
                                        <td class="ps-4 text-muted small">${s.index + 1}</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle p-2" style="background:rgba(110,162,179,0.15);">
                                                    <i class="bi bi-tag" style="color:#6EA2B3;"></i>
                                                </div>
                                                <span class="fw-semibold">${cat.categoryCode}</span>
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge rounded-pill px-3
                                                ${cat.categoryType == 'rent'    ? 'bg-primary-subtle text-primary border border-primary-subtle' :
                                                  cat.categoryType == 'utility' ? 'bg-info-subtle text-info border border-info-subtle' :
                                                  cat.categoryType == 'service' ? 'bg-success-subtle text-success border border-success-subtle' :
                                                                                  'bg-secondary-subtle text-secondary border border-secondary-subtle'}">
                                                ${cat.categoryType}
                                            </span>
                                        </td>
                                        <td class="text-muted small">${not empty cat.unit ? cat.unit : '—'}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${currentMap[cat.categoryId] != null}">
                                                    <span class="fw-semibold text-success">
                                                        <fmt:formatNumber value="${currentMap[cat.categoryId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${futureMap[cat.categoryId] != null}">
                                                    <span class="fw-semibold text-warning">
                                                        <fmt:formatNumber value="${futureMap[cat.categoryId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center pe-4">
                                            <a href="price?action=edit&id=${cat.categoryId}"
                                               class="btn btn-sm btn-outline-primary me-1" title="Edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="price?action=delete&id=${cat.categoryId}"
                                               class="btn btn-sm btn-outline-danger" title="Delete"
                                               onclick="return confirm('Delete category \'${cat.categoryCode}\'?')">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-3 d-block mb-2"></i>No price categories found.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- Footer total --%>
            <div class="px-4 py-3 border-top text-muted small">
                Total: <strong>${fn:length(categories)}</strong> category(ies)
            </div>
        </div>
    </div>

</t:layout>
