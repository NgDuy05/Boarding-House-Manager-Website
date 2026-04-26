<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t"   tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<t:layout>

<style>
    .page-header {
        background: linear-gradient(135deg, #001D39, #0A4174, #49769F);
        color: #fff; border-radius: 12px; padding: 20px 24px;
        margin-bottom: 24px; box-shadow: 0 4px 12px rgba(0,29,57,.15);
    }
    .page-header .btn-light { background:#fff; border:none; color:#001D39; font-weight:600; }
    .page-header .btn-light:hover { background:#BDD8E9; color:#001D39; }

    .filter-tabs { border-bottom: 2px solid #BDD8E9; margin-bottom: 20px; }
    .filter-tabs .nav-link {
        color:#49769F; border:none; border-bottom:2px solid transparent;
        margin-bottom:-2px; padding:8px 18px; font-weight:500; border-radius:0; transition:all .2s;
    }
    .filter-tabs .nav-link:hover { color:#0A4174; border-bottom:2px solid #7BBDE8; }
    .filter-tabs .nav-link.active { color:#001D39; border-bottom-color:#001D39; background:transparent; font-weight:700; }

    .table-card { border-radius: 14px; border: none; overflow: hidden; }
    .table thead th {
        background: #BDD8E9; color: #001D39; font-size: 11px;
        font-weight: 700; text-transform: uppercase; letter-spacing: .5px; border: none;
    }
    .table tbody tr:hover { background: rgba(123,189,232,.12); }
    .table td { border-color: rgba(189,216,233,.4); vertical-align: middle; }

    /* Type badges */
    .badge-theme-rent      { background: #001D39; color: #fff; }
    .badge-theme-utility   { background: #4E8EA2; color: #fff; }
    .badge-theme-service   { background: #49769F; color: #fff; }
    .badge-theme-facility  { background: #6EA2B3; color: #fff; }

    .badge-subtle-rent     { background: rgba(0,29,57,.1);    color:#001D39; border:1px solid rgba(0,29,57,.25); }
    .badge-subtle-utility  { background: rgba(78,142,162,.12);color:#4E8EA2; border:1px solid rgba(78,142,162,.3); }
    .badge-subtle-service  { background: rgba(73,118,159,.12);color:#49769F; border:1px solid rgba(73,118,159,.3); }
    .badge-subtle-facility { background: rgba(110,162,179,.12);color:#6EA2B3;border:1px solid rgba(110,162,179,.3); }

    .btn-outline-action-edit { border-color:#0A4174; color:#0A4174; }
    .btn-outline-action-edit:hover { background:#0A4174; color:#fff; }

    /* Price cells */
    .price-current { color:#198754; font-weight:600; }
    .price-future  { color:#e6a817; font-weight:600; }
    .price-none    { color:#adb5bd; font-style:italic; font-size:.88rem; }

    .future-pill {
        font-size:10px; padding:1px 6px; border-radius:20px;
        background:#fff3cd; color:#856404; border:1px solid #ffc107; margin-left:4px;
    }

    /* Section header inside All tab */
    .section-label {
        display:flex; align-items:center; gap:8px;
        font-size:.78rem; font-weight:700; text-transform:uppercase;
        letter-spacing:.6px; color:#fff; padding:6px 14px;
        border-radius:6px; margin: 20px 0 8px;
    }
    .sl-rent     { background:#001D39; }
    .sl-utility  { background:#4E8EA2; }
    .sl-service  { background:#49769F; }
    .sl-facility { background:#6EA2B3; }

    /* Stat mini cards */
    .stat-mini { border-radius:10px; padding:12px 16px; border:none; }
</style>

    <%-- ===== Header ===== --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-tags-fill me-2"></i>Categories Price</h4>
            <small class="opacity-75" style="color:#BDD8E9;">
                Manage pricing for rent, utilities, services and facilities
            </small>
        </div>
        <c:set var="activeType" value="${param.type}"/>
        <c:if test="${empty activeType or activeType == 'service'}">
            <a href="${pageContext.request.contextPath}/price?action=create" class="btn btn-light fw-semibold">
                <i class="bi bi-plus-circle-fill me-1" style="color:#0A4174;"></i>Add Price Category
            </a>
        </c:if>
    </div>

    <%-- ===== Filter Tabs ===== --%>
    <c:set var="type" value="${param.type}"/>
    <ul class="nav filter-tabs">
        <li class="nav-item">
            <a class="nav-link ${empty type ? 'active' : ''}"
               href="${pageContext.request.contextPath}/price?action=categories">
                All
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'rent' ? 'active' : ''}" href="?action=categories&type=rent">
                <span class="badge badge-theme-rent rounded-pill px-3">Rent</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'utility' ? 'active' : ''}" href="?action=categories&type=utility">
                <span class="badge badge-theme-utility rounded-pill px-3">Utility</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'service' ? 'active' : ''}" href="?action=categories&type=service">
                <span class="badge badge-theme-service rounded-pill px-3">Service</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${type == 'facility' ? 'active' : ''}" href="?action=categories&type=facility">
                <span class="badge badge-theme-facility rounded-pill px-3">Facility</span>
            </a>
        </li>
    </ul>

    <%-- ================================================================
         TAB: ALL — Summary table of 4 types, each showing old + new price
         ================================================================ --%>
    <c:if test="${empty type}">

        <%-- Stat mini cards --%>
        <div class="row g-3 mb-3">
            <div class="col-6 col-md-3">
                <div class="card stat-mini shadow-sm text-center" style="border-left:4px solid #001D39;">
                    <div class="fw-bold fs-5" style="color:#001D39;">${fn:length(roomCategories)}</div>
                    <div class="text-muted" style="font-size:.78rem;">Room Types (Rent)</div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-mini shadow-sm text-center" style="border-left:4px solid #4E8EA2;">
                    <div class="fw-bold fs-5" style="color:#4E8EA2;">${fn:length(utilities)}</div>
                    <div class="text-muted" style="font-size:.78rem;">Utilities</div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-mini shadow-sm text-center" style="border-left:4px solid #49769F;">
                    <div class="fw-bold fs-5" style="color:#49769F;">${fn:length(categories)}</div>
                    <div class="text-muted" style="font-size:.78rem;">Services</div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-mini shadow-sm text-center" style="border-left:4px solid #6EA2B3;">
                    <div class="fw-bold fs-5" style="color:#6EA2B3;">${fn:length(facilities)}</div>
                    <div class="text-muted" style="font-size:.78rem;">Facilities</div>
                </div>
            </div>
        </div>

        <%-- ---- RENT section ---- --%>
        <div class="section-label sl-rent">
            <i class="bi bi-house-fill"></i> Rent — Room Types
        </div>
        <div class="card table-card shadow-sm mb-4">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Room Type</th>
                            <th class="text-center">Type</th>
                            <th>Current Price (Monthly)</th>
                            <th>Daily Price</th>
                            <th>Rooms</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="rc" items="${roomCategories}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index+1}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle p-2" style="background:rgba(0,29,57,.1);">
                                            <i class="bi bi-house" style="color:#001D39;"></i>
                                        </div>
                                        <span class="fw-semibold" style="color:#001D39;">${rc.categoryName}</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge rounded-pill badge-subtle-rent px-3">rent</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${rc.basePrice != null and rc.basePrice > 0}">
                                            <span class="price-current">
                                                <fmt:formatNumber value="${rc.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${rc.pricePerDay != null and rc.pricePerDay > 0}">
                                            <span class="price-future">
                                                <fmt:formatNumber value="${rc.pricePerDay}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="badge bg-secondary rounded-pill">${rc.roomCount}</span>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="price?action=editRoomCategory&id=${rc.categoryId}"
                                       class="btn btn-sm btn-outline-action-edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty roomCategories}">
                            <tr><td colspan="7" class="text-center py-4 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- ---- UTILITY section ---- --%>
        <div class="section-label sl-utility">
            <i class="bi bi-lightning-fill"></i> Utility — Utilities
        </div>
        <div class="card table-card shadow-sm mb-4">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Utility</th>
                            <th class="text-center">Type</th>
                            <th>Unit</th>
                            <th>Current Price</th>
                            <th>Upcoming Price</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${utilities}" varStatus="s">
                            <c:if test="${!u.isDeleted}">
                                <tr>
                                    <td class="ps-4 text-muted small">${s.index+1}</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="rounded-circle p-2" style="background:rgba(78,142,162,.15);">
                                                <i class="bi bi-lightning" style="color:#4E8EA2;"></i>
                                            </div>
                                            <span class="fw-semibold" style="color:#4E8EA2;">${u.utilityName}</span>
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge rounded-pill badge-subtle-utility px-3">utility</span>
                                    </td>
                                    <td class="text-muted small">${not empty u.unit ? u.unit : '—'}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${utilityCurrentMap[u.utilityId] != null}">
                                                <span class="price-current">
                                                    <fmt:formatNumber value="${utilityCurrentMap[u.utilityId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                </span>
                                            </c:when>
                                            <c:otherwise><span class="price-none">No price set</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${utilityFutureMap[u.utilityId] != null}">
                                                <span class="price-future">
                                                    <fmt:formatNumber value="${utilityFutureMap[u.utilityId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                </span>
                                                <span class="future-pill">upcoming</span>
                                            </c:when>
                                            <c:otherwise><span class="price-none">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center pe-4">
                                        <a href="price?action=editUtilityPrice&id=${u.utilityId}"
                                           class="btn btn-sm btn-outline-action-edit">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:if>
                        </c:forEach>
                        <c:if test="${empty utilities}">
                            <tr><td colspan="7" class="text-center py-4 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- ---- SERVICE section ---- --%>
        <div class="section-label sl-service">
            <i class="bi bi-tag-fill"></i> Service — Services (via price_history)
        </div>
        <div class="card table-card shadow-sm mb-4">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Category Code</th>
                            <th class="text-center">Type</th>
                            <th>Unit</th>
                            <th>Current Price</th>
                            <th>Upcoming Price</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cat" items="${categories}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index+1}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle p-2" style="background:rgba(73,118,159,.12);">
                                            <i class="bi bi-tag" style="color:#49769F;"></i>
                                        </div>
                                        <span class="fw-semibold" style="color:#49769F;">${cat.categoryCode}</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge rounded-pill px-3
                                        ${cat.categoryType == 'rent'    ? 'badge-subtle-rent'     :
                                          cat.categoryType == 'utility' ? 'badge-subtle-utility'  :
                                          cat.categoryType == 'service' ? 'badge-subtle-service'  :
                                                                          'badge-subtle-facility'}">
                                        ${cat.categoryType}
                                    </span>
                                </td>
                                <td class="text-muted small">${not empty cat.unit ? cat.unit : '—'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${currentMap[cat.categoryId] != null and currentMap[cat.categoryId] > 0}">
                                            <span class="price-current">
                                                <fmt:formatNumber value="${currentMap[cat.categoryId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${futureMap[cat.categoryId] != null and futureMap[cat.categoryId] > 0}">
                                            <span class="price-future">
                                                <fmt:formatNumber value="${futureMap[cat.categoryId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                            <span class="future-pill">upcoming</span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="price?action=edit&id=${cat.categoryId}"
                                       class="btn btn-sm btn-outline-action-edit me-1">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="price?action=delete&id=${cat.categoryId}"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Delete category \'${cat.categoryCode}\'?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty categories}">
                            <tr><td colspan="7" class="text-center py-4 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- ---- FACILITY section ---- --%>
        <div class="section-label sl-facility">
            <i class="bi bi-box-seam-fill"></i> Facility — Facilities
        </div>
        <div class="card table-card shadow-sm mb-4">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Facility</th>
                            <th class="text-center">Type</th>
                            <th>Current Price (Monthly)</th>
                            <th>New Price</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="f" items="${facilities}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index+1}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <c:choose>
                                            <c:when test="${not empty f.image}">
                                                <img src="${pageContext.request.contextPath}/assets/images/facility/${f.image}"
                                                     style="width:30px;height:30px;object-fit:cover;border-radius:6px;" alt="">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded-circle p-2" style="background:rgba(110,162,179,.15);">
                                                    <i class="bi bi-box" style="color:#6EA2B3;"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="fw-semibold" style="color:#6EA2B3;">${f.facilityName}</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge rounded-pill badge-subtle-facility px-3">facility</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${f.monthlyPrice != null and f.monthlyPrice > 0}">
                                            <span class="price-current">
                                                <fmt:formatNumber value="${f.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">No price set</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <%-- Facility has no future price mechanism, display — --%>
                                    <span class="price-none">—</span>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="price?action=editFacilityPrice&id=${f.facilityId}"
                                       class="btn btn-sm btn-outline-action-edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty facilities}">
                            <tr><td colspan="6" class="text-center py-4 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </c:if><%-- end ALL --%>

    <%-- ================================================================
         TAB: RENT
         ================================================================ --%>
    <c:if test="${type == 'rent'}">
        <div class="card table-card shadow-sm">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Room Type</th>
                            <th>Description</th>
                            <th>Current Price / month</th>
                            <th>Price / day</th>
                            <th>Rooms</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="rc" items="${roomCategories}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index+1}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle p-2" style="background:rgba(0,29,57,.1);">
                                            <i class="bi bi-house" style="color:#001D39;"></i>
                                        </div>
                                        <span class="fw-semibold" style="color:#001D39;">${rc.categoryName}</span>
                                    </div>
                                </td>
                                <td class="text-muted small">${not empty rc.description ? rc.description : '—'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${rc.basePrice != null and rc.basePrice > 0}">
                                            <span class="price-current">
                                                <fmt:formatNumber value="${rc.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${rc.pricePerDay != null and rc.pricePerDay > 0}">
                                            <span class="price-future">
                                                <fmt:formatNumber value="${rc.pricePerDay}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="badge bg-secondary rounded-pill">${rc.roomCount}</span></td>
                                <td class="text-center pe-4">
                                    <a href="price?action=editRoomCategory&id=${rc.categoryId}"
                                       class="btn btn-sm btn-outline-action-edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty roomCategories}">
                            <tr><td colspan="7" class="text-center py-5 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            <div class="px-4 py-3 border-top text-muted small">
                Total: <strong>${fn:length(roomCategories)}</strong> room type(s)
            </div>
        </div>
    </c:if>

    <%-- ================================================================
         TAB: UTILITY
         ================================================================ --%>
    <c:if test="${type == 'utility'}">
        <div class="card table-card shadow-sm">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Utility</th>
                            <th>Unit</th>
                            <th>Current Price</th>
                            <th>Upcoming Price</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${utilities}" varStatus="s">
                            <c:if test="${!u.isDeleted}">
                                <tr>
                                    <td class="ps-4 text-muted small">${s.index+1}</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="rounded-circle p-2" style="background:rgba(78,142,162,.15);">
                                                <i class="bi bi-lightning" style="color:#4E8EA2;"></i>
                                            </div>
                                            <span class="fw-semibold" style="color:#4E8EA2;">${u.utilityName}</span>
                                        </div>
                                    </td>
                                    <td class="text-muted small">${not empty u.unit ? u.unit : '—'}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${utilityCurrentMap[u.utilityId] != null}">
                                                <span class="price-current">
                                                    <fmt:formatNumber value="${utilityCurrentMap[u.utilityId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                </span>
                                            </c:when>
                                            <c:otherwise><span class="price-none">No price set</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${utilityFutureMap[u.utilityId] != null}">
                                                <span class="price-future">
                                                    <fmt:formatNumber value="${utilityFutureMap[u.utilityId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                </span>
                                                <span class="future-pill">upcoming</span>
                                            </c:when>
                                            <c:otherwise><span class="price-none">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center pe-4">
                                        <a href="price?action=editUtilityPrice&id=${u.utilityId}"
                                           class="btn btn-sm btn-outline-action-edit">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:if>
                        </c:forEach>
                        <c:if test="${empty utilities}">
                            <tr><td colspan="6" class="text-center py-5 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            <div class="px-4 py-3 border-top text-muted small">
                Total: <strong>${fn:length(utilities)}</strong> utility(s)
            </div>
        </div>
    </c:if>

    <%-- ================================================================
         TAB: SERVICE
         ================================================================ --%>
    <c:if test="${type == 'service'}">
        <div class="card table-card shadow-sm">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Category Code</th>
                            <th class="text-center">Type</th>
                            <th>Unit</th>
                            <th>Current Price</th>
                            <th>Upcoming Price</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cat" items="${categories}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index+1}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle p-2" style="background:rgba(73,118,159,.12);">
                                            <i class="bi bi-tag" style="color:#49769F;"></i>
                                        </div>
                                        <span class="fw-semibold" style="color:#49769F;">${cat.categoryCode}</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge rounded-pill px-3
                                        ${cat.categoryType == 'rent'    ? 'badge-subtle-rent'    :
                                          cat.categoryType == 'utility' ? 'badge-subtle-utility' :
                                          cat.categoryType == 'service' ? 'badge-subtle-service' :
                                                                          'badge-subtle-facility'}">
                                        ${cat.categoryType}
                                    </span>
                                </td>
                                <td class="text-muted small">${not empty cat.unit ? cat.unit : '—'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${currentMap[cat.categoryId] != null and currentMap[cat.categoryId] > 0}">
                                            <span class="price-current">
                                                <fmt:formatNumber value="${currentMap[cat.categoryId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${futureMap[cat.categoryId] != null and futureMap[cat.categoryId] > 0}">
                                            <span class="price-future">
                                                <fmt:formatNumber value="${futureMap[cat.categoryId]}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                            <span class="future-pill">upcoming</span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="price?action=edit&id=${cat.categoryId}"
                                       class="btn btn-sm btn-outline-action-edit me-1">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="price?action=delete&id=${cat.categoryId}"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Delete \'${cat.categoryCode}\'?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty categories}">
                            <tr><td colspan="7" class="text-center py-5 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            <div class="px-4 py-3 border-top text-muted small">
                Total: <strong>${fn:length(categories)}</strong> category(s)
            </div>
        </div>
    </c:if>

    <%-- ================================================================
         TAB: FACILITY
         ================================================================ --%>
    <c:if test="${type == 'facility'}">
        <div class="card table-card shadow-sm">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Facility</th>
                            <th>Description</th>
                            <th>Current Price (Monthly)</th>
                            <th class="text-center pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="f" items="${facilities}" varStatus="s">
                            <tr>
                                <td class="ps-4 text-muted small">${s.index+1}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <c:choose>
                                            <c:when test="${not empty f.image}">
                                                <img src="${pageContext.request.contextPath}/assets/images/facility/${f.image}"
                                                     style="width:30px;height:30px;object-fit:cover;border-radius:6px;" alt="">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded-circle p-2" style="background:rgba(110,162,179,.15);">
                                                    <i class="bi bi-box" style="color:#6EA2B3;"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="fw-semibold" style="color:#6EA2B3;">${f.facilityName}</span>
                                    </div>
                                </td>
                                <td class="text-muted small">${not empty f.description ? f.description : '—'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${f.monthlyPrice != null and f.monthlyPrice > 0}">
                                            <span class="price-current">
                                                <fmt:formatNumber value="${f.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="price-none">No price set</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="price?action=editFacilityPrice&id=${f.facilityId}"
                                       class="btn btn-sm btn-outline-action-edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty facilities}">
                            <tr><td colspan="5" class="text-center py-5 price-none">No data available</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            <div class="px-4 py-3 border-top text-muted small">
                Total: <strong>${fn:length(facilities)}</strong> facility(s)
            </div>
        </div>
    </c:if>

</t:layout>