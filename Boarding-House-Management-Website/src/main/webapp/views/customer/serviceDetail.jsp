<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Service Detail - AKDD House</title>
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
            --ds-heading: #171719;
        }

        body { 
            background: var(--ds-bg); 
            font-family: 'Pretendard', sans-serif !important; 
            color: var(--ds-text);
        }

        /* ── Page header ── */
        .page-hero {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            border-radius: 16px; padding: 28px; color: #fff;
            display: flex; align-items: center; gap: 20px;
            margin-bottom: 24px; position: relative; overflow: hidden;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-hero::after {
            content: ''; position: absolute;
            width: 200px; height: 200px;
            background: rgba(255,255,255,.06); border-radius: 50%;
            top: -60px; right: -60px;
        }
        .hero-icon {
            width: 72px; height: 72px;
            background: rgba(255,255,255,.15); border-radius: 20px;
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; border: 2px solid rgba(255,255,255,.3); flex-shrink: 0;
        }
        .page-hero h4 { font-weight: 800; margin-bottom: 4px; font-size: 1.4rem; }
        .page-hero small { opacity: .85; font-size: .9rem; }

        /* ── Action Buttons ── */
        .btn-back {
            display: inline-flex; align-items: center; gap: .5rem;
            color: var(--ocean-700); font-weight: 700; font-size: .95rem;
            text-decoration: none; margin-bottom: 1.5rem; transition: color .2s;
        }
        .btn-back:hover { color: var(--ocean-900); text-decoration: none; }

        .btn-action-ocean {
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600));
            color: #fff; border: none; border-radius: 12px;
            padding: 14px 24px; font-weight: 700; font-size: 1.05rem;
            display: inline-flex; align-items: center; justify-content: center; gap: .5rem;
            transition: transform .2s, box-shadow .2s;
            text-decoration: none; width: 100%;
        }
        .btn-action-ocean:hover {
            transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 119, 182, 0.3); color: #fff;
        }

        /* ── Info Card ── */
        .info-card {
            background: #fff; border-radius: 20px; border: none;
            box-shadow: 0 4px 24px rgba(0,0,0,.04); padding: 2rem;
            margin-bottom: 24px;
        }
        .svc-image {
            width: 100%; max-height: 280px; object-fit: cover;
            border-radius: 14px; margin-bottom: 1.5rem;
            box-shadow: 0 4px 16px rgba(0,0,0,.06);
        }
        .svc-title {
            font-size: 1.6rem; font-weight: 800; color: var(--ocean-900);
            margin-bottom: 1.5rem; border-bottom: 2px dashed var(--ocean-200);
            padding-bottom: 1rem;
        }
        .info-label {
            font-size: .8rem; font-weight: 700; color: #9ca3af;
            text-transform: uppercase; letter-spacing: .5px; margin-bottom: .4rem;
        }
        .info-value-price {
            font-size: 1.8rem; font-weight: 800; color: var(--ocean-700);
            display: flex; align-items: baseline; gap: 4px;
        }
        .info-value-desc {
            font-size: 1rem; color: #4b5563; line-height: 1.7;
            background: #f9fafb; padding: 1.2rem; border-radius: 12px;
            border: 1px solid #f3f4f6;
        }
    </style>
</head>
<body>
    <%@ include file="../navbar.jsp" %>

    <div class="container-fluid p-0">
      <div class="row g-0" style="min-height: calc(100vh - 56px);">
        <%@ include file="sidebar.jsp" %>
        <main class="col p-4">
    <div style="max-width: 680px; margin: 0 auto;">

        <a href="${pageContext.request.contextPath}/services" class="btn-back">
            <i class="bi bi-arrow-left"></i> Back to Services
        </a>

        <c:if test="${empty service}">
            <div class="alert alert-warning d-flex align-items-center shadow-sm border-0 rounded-4 p-4 mt-2">
                <i class="bi bi-exclamation-triangle-fill fs-3 text-warning me-3"></i>
                <div>
                    <h5 class="fw-bold mb-1">Service Not Found</h5>
                    <p class="mb-0 text-muted">The service you are looking for doesn't exist or has been removed.</p>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty service}">
            <%-- Hero Header --%>
            <div class="page-hero">
                <div class="hero-icon"><i class="bi bi-lightning-charge-fill"></i></div>
                <div style="position:relative;z-index:1;">
                    <h4>Service Details</h4>
                    <small>Information and pricing for this service</small>
                </div>
            </div>

            <%-- Detail Card --%>
            <div class="info-card">
                <h2 class="svc-title">
                    ${service.serviceName}
                </h2>

                <c:if test="${not empty service.image}">
                    <c:choose>
                        <c:when test="${fn:startsWith(service.image, 'http') or fn:startsWith(service.image, '/')}">
                            <img src="${fn:startsWith(service.image, 'http') ? '' : pageContext.request.contextPath}${service.image}" 
                                 class="svc-image" alt="${service.serviceName}"
                                 onerror="this.style.display='none';">
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/${service.image}" 
                                 class="svc-image" alt="${service.serviceName}"
                                 onerror="this.style.display='none';">
                        </c:otherwise>
                    </c:choose>
                </c:if>

                <div class="row g-4">
                    <div class="col-12">
                        <div class="info-label"><i class="bi bi-tag-fill me-1"></i> Pricing</div>
                        <div class="info-value-price">
                            <c:choose>
                                <c:when test="${not empty service.price and service.price > 0}">
                                    <fmt:formatNumber value="${service.price}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                    <span style="font-size: .9rem; color: #6b7280; font-weight: 500;">/ usage</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #10b981;"><i class="bi bi-check-circle-fill me-2 fs-5"></i>Free</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="col-12">
                        <div class="info-label"><i class="bi bi-info-circle-fill me-1"></i> Description</div>
                        <div class="info-value-desc">
                            ${not empty service.description ? service.description : 'No detailed description available for this service.'}
                        </div>
                    </div>
                </div>
            </div>

            <%-- Action Button (Only for customers) --%>
            <c:if test="${sessionScope.user.role == 'customer'}">
                <a href="${pageContext.request.contextPath}/services?action=request&serviceId=${service.serviceId}"
                   class="btn-action-ocean">
                    <i class="bi bi-send-fill me-2"></i>Request This Service
                </a>
            </c:if>

        </c:if>

    </div>
        </main>
      </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>