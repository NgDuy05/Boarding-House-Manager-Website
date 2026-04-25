<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- Redirect to servlet if accessed directly (no data) --%>
<c:if test="${empty services}">
    <c:redirect url="/services"/>
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Services - AKDD House</title>
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
            overflow-x: hidden;
        }

        /* ── Page Hero ── */
        .page-hero {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            color: #fff; padding: 48px 0 56px; margin-bottom: -32px;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-hero h1 { font-weight: 800; font-size: 2rem; letter-spacing: -0.5px; }

        /* ── Service Cards ── */
        .svc-card {
            border: none; border-radius: 20px;
            box-shadow: 0 4px 16px rgba(0,0,0,.04);
            transition: transform .2s ease, box-shadow .2s ease;
            overflow: hidden; background: #fff;
            height: 100%; display: flex; flex-direction: column;
        }
        .svc-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 30px rgba(0, 119, 182, 0.1);
        }
        
        .svc-img {
            height: 160px; object-fit: cover; width: 100%;
        }
        .svc-img-placeholder {
            height: 160px;
            background: linear-gradient(135deg, var(--ocean-100), var(--ocean-200));
            display: flex; align-items: center; justify-content: center;
            font-size: 3.5rem; color: var(--ocean-500);
        }
        
        .svc-body {
            padding: 1.5rem; display: flex; flex-direction: column; flex-grow: 1;
        }
        .svc-name { font-weight: 800; font-size: 1.15rem; color: var(--ocean-900); margin-bottom: 6px; }
        .svc-desc { 
            font-size: .9rem; color: #6b7280; margin-bottom: 16px; 
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
            flex-grow: 1; line-height: 1.5;
        }

        .svc-price-wrap {
            margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px dashed var(--ocean-200);
        }
        .svc-price {
            font-weight: 800; color: var(--ocean-700); font-size: 1.2rem;
        }

        /* ── Badges & Buttons ── */
        .badge-cat {
            background: var(--ocean-100); color: var(--ocean-800);
            border-radius: 8px; padding: 4px 12px; font-size: .75rem; font-weight: 700;
            display: inline-flex; align-items: center; border: 1px solid var(--ocean-300);
        }
        
        .btn-history {
            color: var(--ocean-700); border: 2px solid var(--ocean-400);
            border-radius: 50px; padding: 8px 20px; font-weight: 700; font-size: .95rem;
            text-decoration: none; transition: all .2s; display: inline-flex; align-items: center; gap: 6px;
            background: transparent;
        }
        .btn-history:hover { background: var(--ocean-100); color: var(--ocean-900); border-color: var(--ocean-600); }

        .btn-request {
            background: linear-gradient(135deg, var(--ocean-700), var(--ocean-500));
            color: #fff; border: none; border-radius: 10px;
            padding: 8px 18px; font-weight: 700; font-size: .9rem;
            text-decoration: none; transition: transform .2s, box-shadow .2s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-request:hover {
            transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 150, 199, 0.25); color: #fff;
        }
        
        /* ── Empty State ── */
        .empty-state { text-align: center; padding: 5rem 1rem; color: #9ca3af; }
        .empty-state i { font-size: 4rem; color: var(--ocean-200); display: block; margin-bottom: 1rem; }
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
                    <li class="breadcrumb-item active text-white fw-semibold">Services</li>
                </ol>
            </nav>
            <h1><i class="bi bi-grid-3x3-gap-fill me-2"></i>Available Services</h1>
            <p class="mb-0 opacity-85">Explore and request services available for tenants in AKDD House</p>
        </div>
    </div>

    <div class="container pb-5" style="padding-top: 48px; max-width: 1200px;">

        <%-- Actions bar --%>
        <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-3">
            <h4 class="fw-bold mb-0" style="color: var(--ocean-900);">
                All Services
                <span class="badge ms-2 fs-6 rounded-pill align-middle" style="background: var(--ocean-100); color: var(--ocean-800);">${services.size()}</span>
            </h4>
            <c:if test="${not empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/services?action=myHistory"
                   class="btn-history shadow-sm">
                    <i class="bi bi-clock-history"></i>My Service History
                </a>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${not empty services}">
                <div class="row g-4">
                    <c:forEach var="svc" items="${services}">
                        <div class="col-sm-6 col-md-4 col-xl-3">
                            <div class="svc-card">
                                <%-- Image section --%>
                                <c:choose>
                                    <c:when test="${not empty svc.image}">
                                        <img src="${pageContext.request.contextPath}/assets/images/service/${svc.image}"
                                             class="svc-img" alt="${svc.serviceName}"
                                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                        <div class="svc-img-placeholder" style="display:none">
                                            <i class="bi bi-lightning-charge-fill"></i>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="svc-img-placeholder">
                                            <i class="bi bi-stars"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <%-- Body section --%>
                                <div class="svc-body">
                                    <div class="svc-name">${svc.serviceName}</div>
                                    <div class="svc-desc" title="${svc.description}">
                                        <c:choose>
                                            <c:when test="${not empty svc.description}">${svc.description}</c:when>
                                            <c:otherwise>Premium utility service provided by AKDD House.</c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <div class="svc-price-wrap">
                                        <c:set var="price" value="${priceMap[svc.categoryId]}"/>
                                        <c:set var="unit"  value="${unitMap[svc.categoryId]}"/>
                                        <c:choose>
                                            <c:when test="${not empty price and price > 0}">
                                                <span class="svc-price">
                                                    <fmt:formatNumber value="${price}" type="number" maxFractionDigits="0"/>&#8363;
                                                </span>
                                                <c:if test="${not empty unit}">
                                                    <span class="text-muted fw-medium" style="font-size:.85rem;">/ ${unit}</span>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="svc-price text-muted" style="font-size:1rem;">Liên hệ để biết giá</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <div class="d-flex align-items-center justify-content-between mt-auto">
                                        <span class="badge-cat">
                                            <i class="bi bi-tag-fill me-1"></i>Cat. ${svc.categoryId}
                                        </span>
                                        <c:if test="${not empty sessionScope.user}">
                                            <a href="${pageContext.request.contextPath}/services?action=requestForm&serviceId=${svc.serviceId}"
                                               class="btn-request">
                                                <i class="bi bi-send-fill"></i>Request
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="bi bi-inbox-fill"></i>
                    <h4 class="fw-bold" style="color: var(--ocean-900);">No services available</h4>
                    <p>There are currently no services listed. Please check back later.</p>
                </div>
            </c:otherwise>
        </c:choose>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        </main>
      </div>
    </div>
</body>
</html>