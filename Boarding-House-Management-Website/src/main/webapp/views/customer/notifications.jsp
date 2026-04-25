<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Notifications - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* 1. Import Font Pretendard */
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css");

        /* 2. Ocean Palette Variables */
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
            background: var(--ds-bg); 
            font-family: 'Pretendard', sans-serif !important; 
            color: var(--ds-text);
        }

        /* ── Hero ── */
        .page-hero {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            color: #fff; 
            padding: 48px 0 56px; 
            margin-bottom: -32px;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-hero h1 { font-weight: 800; font-size: 2rem; letter-spacing: -0.5px; }

        /* ── Filter bar ── */
        .filter-bar {
            background: #fff; border-radius: 50px;
            padding: 6px; display: inline-flex; gap: 4px;
            box-shadow: 0 4px 16px rgba(0,0,0,.06);
        }
        .filter-btn {
            border-radius: 50px; border: none;
            padding: 8px 20px; font-weight: 700; font-size: .85rem;
            cursor: pointer; text-decoration: none;
            display: inline-flex; align-items: center; gap: .4rem;
            color: #6b7280; background: transparent; transition: all .2s;
        }
        .filter-btn:hover  { background: #f3f4f6; color: #374151; }
        .filter-btn.active { 
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600)); 
            color: #fff; 
            box-shadow: 0 4px 10px rgba(0, 119, 182, 0.2);
        }

        /* ── Notification cards ── */
        .notif-card {
            background: #fff; border-radius: 16px; border: none;
            box-shadow: 0 2px 16px rgba(0,0,0,.04);
            padding: 1.5rem 1.75rem;
            transition: transform .2s ease, box-shadow .2s ease;
            display: flex; gap: 1.25rem; align-items: flex-start;
        }
        .notif-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 28px rgba(0, 119, 182, 0.08);
        }

        .notif-icon-wrap {
            width: 52px; height: 52px; flex-shrink: 0;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem;
        }
        .icon-broadcast { background: var(--ocean-100); color: var(--ocean-900); }
        .icon-targeted  { background: rgba(0, 119, 182, 0.1); color: var(--ocean-800); }

        .notif-body { flex: 1; min-width: 0; }
        .notif-title {
            font-weight: 800; font-size: 1.05rem; color: var(--ocean-900);
            margin-bottom: .35rem;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .notif-preview {
            font-size: .9rem; color: #5A5C63;
            display: -webkit-box;
            -webkit-line-clamp: 2; -webkit-box-orient: vertical;
            overflow: hidden; margin-bottom: .75rem;
            line-height: 1.5;
        }
        .notif-meta {
            display: flex; align-items: center; gap: 1rem;
            flex-wrap: wrap;
        }
        .notif-meta span { font-size: .8rem; color: #9ca3af; display: flex; align-items: center; gap: .3rem; font-weight: 500; }
        
        .badge-pill {
            border-radius: 20px; padding: 4px 12px;
            font-size: .75rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .badge-broadcast { background: var(--ocean-100); color: var(--ocean-900); }
        .badge-targeted  { background: rgba(0, 119, 182, 0.1); color: var(--ocean-800); }

        .notif-action {
            flex-shrink: 0; align-self: center;
        }
        .btn-read {
            display: inline-flex; align-items: center; gap: .3rem;
            font-size: .85rem; font-weight: 700; color: var(--ocean-700);
            text-decoration: none; padding: 8px 16px;
            border: 1.5px solid var(--ocean-200); border-radius: 10px;
            transition: all .2s; white-space: nowrap;
        }
        .btn-read:hover {
            background: var(--ocean-100); color: var(--ocean-900); border-color: var(--ocean-300);
        }

        .empty-state { text-align: center; padding: 5rem 1rem; color: #9ca3af; }
        .empty-state i { font-size: 4rem; display: block; margin-bottom: 1rem; color: var(--ocean-200); }
        .empty-state h5 { color: var(--ocean-800); font-weight: 700; }

        .results-info { font-size: .88rem; color: #6b7280; margin-bottom: 1.25rem; font-weight: 500; }
        .results-info strong { color: var(--ocean-700); font-weight: 700; }

        /* Pagination */
        .pagination .page-link { color: var(--ocean-800); border-color: #dee2e6; font-weight: 600; }
        .pagination .page-item.active .page-link { background-color: var(--ocean-800); border-color: var(--ocean-800); color: white; }
        .pagination .page-link:hover { background-color: var(--ocean-100); color: var(--ocean-900); }
    </style>
</head>
<body>
    <%@ include file="../navbar.jsp" %>

    <div class="container-fluid p-0">
      <div class="row g-0" style="min-height: calc(100vh - 56px);">
        <%@ include file="sidebar.jsp" %>
        <main class="col p-0">

    <%-- Hero --%>
    <div class="page-hero">
        <div class="container">
            <nav aria-label="breadcrumb" class="mb-3">
                <ol class="breadcrumb" style="--bs-breadcrumb-divider-color:rgba(255,255,255,.5)">
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/" class="text-white text-opacity-75 text-decoration-none">Home</a>
                    </li>
                    <li class="breadcrumb-item active text-white fw-semibold">Notifications</li>
                </ol>
            </nav>
            <h1><i class="bi bi-bell-fill me-2"></i>Notifications</h1>
            <p class="mb-0 opacity-85">Stay updated with announcements and important messages</p>
        </div>
    </div>

    <div class="container pb-5" style="padding-top: 48px; max-width: 900px;">

        <%-- Filter bar --%>
        <div class="d-flex justify-content-center mb-4">
            <div class="filter-bar">
                <a href="${pageContext.request.contextPath}/notification?action=publicList"
                   class="filter-btn ${empty typeFilter ? 'active' : ''}">
                    <i class="bi bi-grid"></i> All
                    <span style="background:rgba(255,255,255,0.2); color:inherit; border-radius:20px; padding:2px 8px; font-size:.75rem; margin-left: 4px;">
                        ${totalItems}
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/notification?action=publicList&type=broadcast"
                   class="filter-btn ${typeFilter == 'broadcast' ? 'active' : ''}">
                    <i class="bi bi-megaphone-fill"></i> General
                </a>
                <a href="${pageContext.request.contextPath}/notification?action=publicList&type=targeted"
                   class="filter-btn ${typeFilter == 'targeted' ? 'active' : ''}">
                    <i class="bi bi-person-lines-fill"></i> For Me
                </a>
            </div>
        </div>

        <%-- Results info --%>
        <div class="results-info text-center text-md-start">
            <strong>${totalItems}</strong>
            notification<c:if test="${totalItems != 1}">s</c:if>
            <c:if test="${typeFilter == 'broadcast'}"> &middot; general only</c:if>
            <c:if test="${typeFilter == 'targeted'}"> &middot; targeted to you</c:if>
        </div>

        <%-- Notification list --%>
        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <i class="bi bi-bell-slash-fill"></i>
                    <h5>No notifications</h5>
                    <p class="mb-0">
                        <c:choose>
                            <c:when test="${typeFilter == 'broadcast'}">No general notifications found.</c:when>
                            <c:when test="${typeFilter == 'targeted'}">No personal notifications found.</c:when>
                            <c:otherwise>You have no notifications at the moment.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="d-flex flex-column gap-3">
                    <c:forEach var="n" items="${notifications}">
                        <div class="notif-card">
                            <%-- Icon --%>
                            <div class="notif-icon-wrap ${n.broadcast ? 'icon-broadcast' : 'icon-targeted'}">
                                <i class="bi ${n.broadcast ? 'bi-megaphone-fill' : 'bi-person-fill-exclamation'}"></i>
                            </div>

                            <%-- Content --%>
                            <div class="notif-body">
                                <div class="notif-title">${n.title}</div>
                                <div class="notif-preview">${n.content}</div>
                                <div class="notif-meta">
                                    <%-- Type badge --%>
                                    <span>
                                        <c:choose>
                                            <c:when test="${n.broadcast}">
                                                <span class="badge-pill badge-broadcast">
                                                    <i class="bi bi-megaphone-fill me-1"></i>General
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-pill badge-targeted">
                                                    <i class="bi bi-person-fill me-1"></i>For You
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <%-- Created by --%>
                                    <span>
                                        <i class="bi bi-person-circle"></i>
                                        ${not empty n.createdByName ? n.createdByName : 'System'}
                                    </span>
                                    <%-- Timestamp --%>
                                    <c:if test="${not empty n.createdAt}">
                                        <span>
                                            <i class="bi bi-clock-fill"></i>
                                            <fmt:formatDate value="${n.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                                        </span>
                                    </c:if>
                                </div>
                            </div>

                            <%-- Action --%>
                            <div class="notif-action">
                                <a href="${pageContext.request.contextPath}/notification?action=publicDetail&id=${n.notificationId}"
                                   class="btn-read">
                                    Read <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <%-- Pagination --%>
        <c:if test="${totalPages > 1}">
            <div class="d-flex justify-content-between align-items-center mt-5">
                <div class="text-muted small fw-semibold">
                    Showing <strong>${(currentPage - 1) * pageSize + 1}</strong>–<strong>${(currentPage - 1) * pageSize + notifications.size()}</strong>
                    of <strong>${totalItems}</strong>
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/notification?action=publicList&page=${currentPage - 1}&type=${typeFilter}">
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
                                        <a class="page-link" href="${pageContext.request.contextPath}/notification?action=publicList&page=${p}&type=${typeFilter}">${p}</a>
                                    </li>
                                </c:when>
                                <c:when test="${(p == currentPage - 3 && currentPage > 4) || (p == currentPage + 3 && currentPage < totalPages - 3)}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/notification?action=publicList&page=${currentPage + 1}&type=${typeFilter}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        </main>
      </div>
    </div>
</body>
</html>