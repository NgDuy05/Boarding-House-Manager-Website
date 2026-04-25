<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>My Contracts - AKDD House</title>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
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
            font-family: 'Pretendard', sans-serif !important;
            background-color: var(--ds-bg); 
            color: var(--ds-text);
            overflow-x: hidden;
        }

        /* 3. Page Header */
        .page-header { 
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700)); 
            color: white; 
            border-radius: 16px; 
            padding: 24px 30px; 
            margin-bottom: 24px; 
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-header .btn-light {
            background-color: #ffffff;
            color: var(--ocean-900);
            border: none;
            font-weight: 700;
            border-radius: 8px;
            padding: 8px 16px;
            transition: all 0.2s;
        }
        .page-header .btn-light:hover {
            background-color: var(--ocean-100);
            transform: translateY(-2px);
        }

        /* 4. Contract Cards */
        .contract-card { 
            border-radius: 16px; 
            border: none; 
            background-color: #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.04); 
            transition: transform 0.2s ease, box-shadow 0.2s ease; 
        }
        .contract-card:hover { 
            transform: translateY(-4px); 
            box-shadow: 0 12px 24px rgba(0, 119, 182, 0.08) !important; 
        }

        /* 5. Info Layout */
        .info-item { display: flex; flex-direction: column; }
        .info-item .label { 
            font-size: 13px; 
            color: #5A5C63; 
            font-weight: 500; 
            text-transform: capitalize; 
        }
        .info-item .value { 
            font-size: 15px; 
            font-weight: 700; 
            color: var(--ocean-900); 
            margin-top: 4px; 
        }

        /* 6. Badges & Buttons */
        .badge-status { 
            border-radius: 50px; 
            padding: 6px 16px; 
            font-size: 12px; 
            font-weight: 800; 
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }
        
        .btn-outline-ocean {
            color: var(--ocean-700);
            border-color: var(--ocean-500);
            font-weight: 600;
            border-radius: 8px;
            padding: 8px 16px;
            transition: all 0.2s;
        }
        .btn-outline-ocean:hover {
            background-color: var(--ocean-600);
            border-color: var(--ocean-600);
            color: white;
        }
    </style>
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4 d-flex justify-content-center">
<div style="width: 100%; max-width: 860px;">

    <%-- Page Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h3 class="fw-bold mb-1"><i class="bi bi-file-earmark-text-fill me-2" style="color: var(--ocean-400);"></i>My Contracts</h3>
            <div class="opacity-75 small" style="color: var(--ocean-100); font-size: 14px;">View and manage your rental agreements</div>
        </div>
        <a href="${pageContext.request.contextPath}/contract?action=signContract" class="btn btn-light shadow-sm">
            <i class="bi bi-pen me-2"></i>Sign a Contract
        </a>
    </div>

    <%-- Alerts --%>
    <c:if test="${not empty sessionScope.contractSuccess}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" style="border-radius: 12px; border:none; background:#d1fae5; color:#065f46;">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.contractSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("contractSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.contractError}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm" style="border-radius: 12px; border:none; background:#fee2e2; color:#b91c1c;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.contractError}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("contractError"); %>
    </c:if>

    <%-- Main Content --%>
    <c:choose>
        <c:when test="${empty contracts}">
            <div class="card border-0 shadow-sm" style="border-radius: 16px;">
                <div class="card-body text-center py-5">
                    <i class="bi bi-file-earmark-x d-block mb-3" style="font-size:64px; color: var(--ocean-200);"></i>
                    <h4 class="mb-2 fw-bold" style="color: var(--ocean-900);">No contracts yet</h4>
                    <p class="text-muted mb-4">You don't have any rental contracts. Browse available rooms to get started.</p>
                    <a href="${pageContext.request.contextPath}/contract?action=signContract" class="btn btn-outline-ocean">
                        <i class="bi bi-pen me-2"></i>Sign a Contract
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="d-flex flex-column gap-4">
                <c:forEach var="c" items="${contracts}">
                    <div class="card contract-card">
                        <div class="card-body p-4">
                            
                            <%-- Card Header: Title & Status --%>
                            <div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mb-4 border-bottom pb-3" style="border-color: var(--ocean-100) !important;">
                                <div>
                                    <h4 class="fw-bold mb-1" style="color: var(--ocean-900);">
                                        <i class="bi bi-door-closed me-2" style="color: var(--ocean-600);"></i>Room ${not empty c.roomNumber ? c.roomNumber : c.roomId}
                                    </h4>
                                    <div class="d-flex align-items-center gap-2 text-muted small">
                                        <span class="badge" style="background-color: rgba(144, 224, 239, 0.2); color: var(--ocean-800);">Contract #${c.contractId}</span>
                                        <c:if test="${not empty c.categoryName}">
                                            <span>&bull; ${c.categoryName}</span>
                                        </c:if>
                                    </div>
                                </div>
                                <span class="badge badge-status shadow-sm
                                    ${c.status=='active' ? 'bg-success-subtle text-success border border-success-subtle' :
                                      c.status=='terminated' ? 'bg-danger-subtle text-danger border border-danger-subtle' :
                                      'bg-secondary-subtle text-secondary border border-secondary-subtle'}">
                                    <c:choose>
                                        <c:when test="${c.status=='active'}"><i class="bi bi-check-circle-fill me-1"></i></c:when>
                                        <c:when test="${c.status=='terminated'}"><i class="bi bi-x-circle-fill me-1"></i></c:when>
                                        <c:otherwise><i class="bi bi-clock-fill me-1"></i></c:otherwise>
                                    </c:choose>
                                    ${c.statusLabel}
                                </span>
                            </div>

                            <%-- Data Grid --%>
                            <div class="row g-4 mb-4">
                                <div class="col-6 col-md-3">
                                    <div class="info-item">
                                        <span class="label"><i class="bi bi-calendar-check me-1" style="color: var(--ocean-500);"></i>Start Date</span>
                                        <span class="value">${c.startDate}</span>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="info-item">
                                        <span class="label"><i class="bi bi-calendar-x me-1" style="color: var(--ocean-500);"></i>End Date</span>
                                        <span class="value">${not empty c.endDate ? c.endDate : '—'}</span>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="info-item">
                                        <span class="label"><i class="bi bi-shield-check me-1" style="color: var(--ocean-500);"></i>Deposit</span>
                                        <span class="value" style="color: var(--ocean-700);">
                                            <fmt:formatNumber value="${c.deposit}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                        </span>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="info-item">
                                        <span class="label"><i class="bi bi-cash-stack me-1" style="color: var(--ocean-500);"></i>Monthly Rent</span>
                                        <span class="value text-success">
                                            <c:choose>
                                                <c:when test="${not empty c.basePrice}">
                                                    <fmt:formatNumber value="${c.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <%-- Actions --%>
                            <div class="d-flex justify-content-end bg-light p-3 rounded-3" style="background-color: var(--ds-bg) !important;">
                                <a href="${pageContext.request.contextPath}/contract?action=mydetail&id=${c.contractId}"
                                   class="btn btn-outline-ocean btn-sm px-4">
                                    <i class="bi bi-eye me-2"></i>View Full Details
                                </a>
                            </div>
                            
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>
    </main>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>