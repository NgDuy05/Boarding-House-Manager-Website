<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title><c:choose><c:when test="${not empty notification}">${notification.title} - </c:when></c:choose>Notifications - AKDD House</title>
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

        .page-hero {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            color: #fff; 
            padding: 48px 0 56px; 
            margin-bottom: -32px;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-hero h1 { font-weight: 800; font-size: 1.85rem; line-height: 1.3; letter-spacing: -0.5px; }

        .detail-card {
            background: #fff; border-radius: 20px; border: none;
            box-shadow: 0 8px 30px rgba(0,0,0,.06);
            overflow: hidden;
        }

        .detail-header {
            padding: 2.5rem 2.5rem 1.5rem;
            border-bottom: 1px dashed var(--ocean-200);
        }
        .detail-type-badge {
            display: inline-flex; align-items: center; gap: .4rem;
            border-radius: 50px; padding: 6px 16px;
            font-size: .8rem; font-weight: 800;
            margin-bottom: 1.25rem;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .badge-broadcast { background: var(--ocean-100); color: var(--ocean-900); border: 1px solid var(--ocean-300); }
        .badge-targeted  { background: rgba(0, 119, 182, 0.1); color: var(--ocean-800); border: 1px solid rgba(0, 119, 182, 0.2); }

        .detail-title {
            font-size: 1.6rem; font-weight: 800; color: var(--ocean-900);
            margin-bottom: 1.25rem; line-height: 1.4;
        }

        .meta-row {
            display: flex; flex-wrap: wrap; gap: 1.5rem;
        }
        .meta-item {
            display: flex; align-items: center; gap: .5rem;
            font-size: .9rem; color: #5A5C63;
        }
        .meta-item i { color: var(--ocean-600); font-size: 1.1rem; }
        .meta-item strong { color: var(--ocean-900); font-weight: 600; }

        .detail-content {
            padding: 2rem 2.5rem;
            font-size: 1.05rem; line-height: 1.8;
            color: var(--ds-text); white-space: pre-wrap;
        }

        .btn-back {
            display: inline-flex; align-items: center; gap: .4rem;
            color: var(--ocean-700); font-weight: 600; font-size: .95rem;
            text-decoration: none; margin-bottom: 1.5rem;
            transition: color 0.2s ease;
        }
        .btn-back:hover { text-decoration: none; color: var(--ocean-900); }

        .icon-hero {
            width: 64px; height: 64px; border-radius: 20px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem; margin-bottom: 1.25rem;
            border: 2px solid rgba(255,255,255,0.3);
        }
        .icon-broadcast { background: rgba(255,255,255,.15); color: #fff; }
        .icon-targeted  { background: rgba(255,255,255,.15); color: #fff; }

        .not-found { text-align:center; padding: 4rem 1rem; color: #9ca3af; }
        .not-found i { font-size: 4rem; display:block; margin-bottom: 1rem; color: var(--ocean-300); }

        .btn-ocean-gradient {
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600));
            color: #fff;
            border: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .btn-ocean-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(2, 62, 138, 0.25);
            color: #fff;
        }
    </style>
</head>
<body>
    <%@ include file="../navbar.jsp" %>

    <div class="container-fluid p-0">
      <div class="row g-0" style="min-height: calc(100vh - 56px);">
        <%@ include file="sidebar.jsp" %>
        <main class="col p-0">

    <c:choose>
        <c:when test="${empty notification}">
            <%-- Not Found --%>
            <div class="page-hero">
                <div class="container">
                    <h1><i class="bi bi-bell-slash me-2"></i>Notification Not Found</h1>
                </div>
            </div>
            <div class="container py-5">
                <div class="not-found">
                    <i class="bi bi-exclamation-circle-fill"></i>
                    <h5 class="fw-bold text-dark">Notification not found</h5>
                    <p>The notification you're looking for doesn't exist or has been removed.</p>
                    <a href="${pageContext.request.contextPath}/notification?action=publicList"
                       class="btn btn-ocean-gradient rounded-pill px-4 py-2 mt-3 fw-semibold">
                        Back to Notifications
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>

            <%-- Hero --%>
            <div class="page-hero">
                <div class="container">
                    <nav aria-label="breadcrumb" class="mb-3">
                        <ol class="breadcrumb" style="--bs-breadcrumb-divider-color:rgba(255,255,255,.5)">
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/" class="text-white text-opacity-75 text-decoration-none">Home</a>
                            </li>
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/notification?action=publicList"
                                   class="text-white text-opacity-75 text-decoration-none">Notifications</a>
                            </li>
                            <li class="breadcrumb-item active text-white fw-semibold">Detail</li>
                        </ol>
                    </nav>
                    <div class="icon-hero ${notification.broadcast ? 'icon-broadcast' : 'icon-targeted'}">
                        <i class="bi ${notification.broadcast ? 'bi-megaphone-fill' : 'bi-person-fill-exclamation'}"></i>
                    </div>
                    <h1>${notification.title}</h1>
                </div>
            </div>

            <div class="container py-4" style="max-width: 780px;">

                <a href="${pageContext.request.contextPath}/notification?action=publicList" class="btn-back">
                    <i class="bi bi-arrow-left"></i> Back to Notifications
                </a>

                <div class="detail-card">

                    <%-- Header: meta info --%>
                    <div class="detail-header">
                        <div class="detail-type-badge ${notification.broadcast ? 'badge-broadcast' : 'badge-targeted'}">
                            <i class="bi ${notification.broadcast ? 'bi-megaphone-fill' : 'bi-person-fill'}"></i>
                            ${notification.broadcast ? 'Broadcast Announcement' : 'Personal Notification'}
                        </div>

                        <div class="detail-title">${notification.title}</div>

                        <div class="meta-row">
                            <div class="meta-item">
                                <i class="bi bi-person-circle"></i>
                                <span>From: <strong>${not empty notification.createdByName ? notification.createdByName : 'System'}</strong></span>
                            </div>
                            <c:if test="${not empty notification.createdAt}">
                                <div class="meta-item">
                                    <i class="bi bi-calendar-event-fill"></i>
                                    <span>
                                        <strong><fmt:formatDate value="${notification.createdAt}" pattern="MMMM dd, yyyy"/></strong>
                                    </span>
                                </div>
                                <div class="meta-item">
                                    <i class="bi bi-clock-fill"></i>
                                    <span>
                                        <strong><fmt:formatDate value="${notification.createdAt}" pattern="HH:mm"/></strong>
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${not notification.broadcast}">
                                <div class="meta-item">
                                    <i class="bi bi-file-earmark-text-fill"></i>
                                    <span>Contract ID: <strong>#${notification.targetContractId}</strong></span>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <%-- Full content --%>
                    <div class="detail-content">${notification.content}</div>

                </div>

                <%-- Navigation buttons --%>
                <div class="d-flex gap-3 mt-4 mb-5">
                    <a href="${pageContext.request.contextPath}/notification?action=publicList"
                       class="btn px-4 py-2 fw-semibold rounded-pill"
                       style="background:#f3f4f6;color:#374151;border:none">
                        <i class="bi bi-arrow-left me-1"></i>All Notifications
                    </a>
                    <a href="${pageContext.request.contextPath}/notification?action=publicList&type=${notification.broadcast ? 'broadcast' : 'targeted'}"
                       class="btn btn-ocean-gradient px-4 py-2 fw-semibold rounded-pill">
                        <i class="bi bi-filter me-1"></i>
                        More ${notification.broadcast ? 'Broadcast' : 'Personal'} Notifications
                    </a>
                </div>

            </div>

        </c:otherwise>
    </c:choose>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        </main>
      </div>
    </div>
</body>
</html>