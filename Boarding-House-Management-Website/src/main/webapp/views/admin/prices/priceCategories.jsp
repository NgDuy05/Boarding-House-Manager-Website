<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t"   tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<t:layout>

<style>
    /* 1. Header Gradient using the dark blues */
    .page-header {
        background: linear-gradient(135deg, #001D39, #0A4174, #49769F);
        color: #fff;
        border-radius: 12px;
        padding: 20px 24px;
        margin-bottom: 24px;
        box-shadow: 0 4px 12px rgba(0, 29, 57, 0.15);
    }
    .page-header .btn-light { background: #fff; border: none; color: #001D39; font-weight: 600; }
    .page-header .btn-light:hover { background: #BDD8E9; color: #001D39; }

    /* 2. Filter tabs */
    .filter-tabs { border-bottom: 2px solid #BDD8E9; margin-bottom: 20px; }
    .filter-tabs .nav-link {
        color: #49769F; border: none; border-bottom: 2px solid transparent;
        margin-bottom: -2px; padding: 8px 16px; font-weight: 500; border-radius: 0;
        transition: all 0.2s;
    }
    .filter-tabs .nav-link:hover { color: #0A4174; border-bottom: 2px solid #7BBDE8; }
    .filter-tabs .nav-link.active { color: #001D39; border-bottom-color: #001D39; background: transparent; font-weight: 700; }

    /* 3. Table styling */
    .table-card { border-radius: 14px; border: none; }
    .table thead th { background: #BDD8E9; color: #001D39; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; border: none; }
    .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); }
    .stat-card { border-radius: 12px; border: none; padding: 14px 20px; }

    /* 4. Custom Theme Badges for Filter Tabs */
    .badge-theme-rent { background-color: #001D39; color: white; }
    .badge-theme-utility { background-color: #4E8EA2; color: white; }
    .badge-theme-service { background-color: #49769F; color: white; }
    .badge-theme-facility { background-color: #6EA2B3; color: white; }

    /* 5. Custom Subtle Badges for Table Rows */
    .badge-subtle-rent { background-color: rgba(0, 29, 57, 0.1); color: #001D39; border: 1px solid rgba(0, 29, 57, 0.2); }
    .badge-subtle-utility { background-color: rgba(78, 142, 162, 0.1); color: #4E8EA2; border: 1px solid rgba(78, 142, 162, 0.2); }
    .badge-subtle-service { background-color: rgba(73, 118, 159, 0.1); color: #49769F; border: 1px solid rgba(73, 118, 159, 0.2); }
    .badge-subtle-facility { background-color: rgba(110, 162, 179, 0.1); color: #6EA2B3; border: 1px solid rgba(110, 162, 179, 0.2); }

    /* 6. Custom Buttons */
    .btn-outline-action-edit { border-color: #0A4174; color: #0A4174; }
    .btn-outline-action-edit:hover { background-color: #0A4174; color: white; }
</style>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-tags-fill me-2"></i>Categories Price</h4>
            <small class="opacity-75" style="color: #BDD8E9;">Manage pricing categories for rent, utilities, services and facilities</small>
        </div>
        <a href="${pageContext.request.contextPath}/price?action=create" class="btn btn-light fw-semibold">
            <i class="bi bi-plus-circle-fill me-1" style="color: #0A4174;"></i>Add Category
        </a>
    </div>

    <%-- Stat cards --%>
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card stat-card shadow-sm text-center">
                <div class="fw-bold fs-4" style="color: #001D39;">${fn:length(categories)}</div>
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
                <span class="badge badge-theme-rent rounded-pill">Rent</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'utility' ? 'active' : ''}"
               href="?action=categories&type=utility">
                <span class="badge badge-theme-utility rounded-pill">Utility</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'service' ? 'active' : ''}"
               href="?action=categories&type=service">
                <span class="badge badge-theme-service rounded-pill">Service</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'facility' ? 'active' : ''}"
               href="?action=categories&type=facility">
                <span class="badge badge-theme-facility rounded-pill">Facility</span>
            </a>
        </li>
    </ul>

    <%-- Table --%>
    <div class="card table-card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
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
                                                <div class="rounded-circle p-2" style="background:rgba(123, 189, 232, 0.2);">
                                                    <i class="bi bi-tag" style="color:#0A4174;"></i>
                                                </div>
                                                <span class="fw-semibold" style="color: #0A4174;">${cat.categoryCode}</span>
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge rounded-pill px-3
                                                ${cat.categoryType == 'rent'    ? 'badge-subtle-rent' :
                                                  cat.categoryType == 'utility' ? 'badge-subtle-utility' :
                                                  cat.categoryType == 'service' ? 'badge-subtle-service' :
                                                                                  'badge-subtle-facility'}">
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
                                               class="btn btn-sm btn-outline-action-edit me-1" title="Edit">
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
                                        <i class="bi bi-inbox fs-3 d-block mb-2" style="color: #6EA2B3;"></i>No price categories found.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- Footer total --%>
            <div class="px-4 py-3 border-top text-muted small">
                Total: <strong style="color: #001D39;">${fn:length(categories)}</strong> category(ies)
            </div>
        </div>
    </div>

</t:layout>