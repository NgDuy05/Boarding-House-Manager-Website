<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page session="true"%>
<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - AKDD House</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* Ocean Palette Variables */
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
        }

        body { background-color: #f4f7f9; } /* Subtle cool tint */
        
        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            color: white;
            border-radius: 16px;
            padding: 28px 32px;
            margin-bottom: 28px;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }

        /* Section Cards */
        .section-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .section-card:hover {
            box-shadow: 0 8px 24px rgba(0, 119, 182, 0.08);
            transform: translateY(-2px);
        }
        
        .section-card .card-header {
            background: transparent;
            border-bottom: 1px solid var(--ocean-200);
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--ocean-900);
            padding: 1.25rem 1.5rem 1rem;
        }
        .section-card .card-header i {
            color: var(--ocean-600); /* Unified Icon Color */
        }
        
        /* Information Rows */
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 0;
            border-bottom: 1px dashed var(--ocean-200);
            font-size: 0.95rem;
        }
        .info-row:last-child { border-bottom: none; }
        .info-label { color: #6c757d; font-weight: 500; }
        
        /* Semantic Status Badges (Refined) */
        .status-badge {
            font-size: 0.75rem;
            padding: 0.35rem 0.8rem;
            border-radius: 20px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-badge-pending  { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .status-badge-approved { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .status-badge-rejected { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
        .status-badge-paid     { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .status-badge-unpaid   { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; } 
        .status-badge-overdue  { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
        
        /* Custom Theme Buttons & Links */
        .btn-outline-ocean {
            color: var(--ocean-700);
            border-color: var(--ocean-500);
            background-color: transparent;
            font-weight: 600;
        }
        .btn-outline-ocean:hover {
            background-color: var(--ocean-700);
            border-color: var(--ocean-700);
            color: white;
        }
        
        a.view-all {
            color: var(--ocean-600);
            font-weight: 600;
            text-decoration: none;
            transition: color 0.2s;
        }
        a.view-all:hover { color: var(--ocean-800); }

        /* List Groups Hover Effect */
        .list-group-item {
            border-bottom: 1px solid var(--ocean-100);
            transition: background-color 0.2s;
        }
        .list-group-item:hover { background-color: var(--ocean-100); }
        .list-group-item:last-child { border-bottom: none; }
    </style>
</head>
<body style="overflow-x:hidden;">

<%@ include file="../navbar.jsp" %>

<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4">

    <div class="welcome-banner">
        <h3 class="fw-bold mb-1">Welcome, ${sessionScope.user.fullName} 👋</h3>
        <div class="opacity-75">Here's an overview of your room and services</div>
    </div>

    <div class="row g-4">

        <div class="col-lg-7">

            <div class="card section-card mb-4">
                <div class="card-header d-flex align-items-center gap-2">
                    <i class="bi bi-house-door"></i> My Room
                </div>
                <div class="card-body px-4 py-3">
                    <c:choose>
                        <c:when test="${not empty contract}">
                            <div class="info-row">
                                <span class="info-label">Room Number</span>
                                <span class="fw-bold fs-5" style="color: var(--ocean-900);">${contract.roomNumber}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Room Type</span>
                                <span class="fw-semibold" style="color: var(--ocean-800);">${contract.categoryName}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Contract End Date</span>
                                <span class="fw-semibold text-dark">${contract.endDate}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Roommates</span>
                                <span class="fw-semibold text-dark">${contract.tenantCount}</span>
                            </div>
                            <div class="mt-4">
                                <a href="${pageContext.request.contextPath}/contract?action=mycontract"
                                   class="btn btn-sm btn-outline-ocean px-3">
                                    <i class="bi bi-file-earmark-text me-1"></i>View Contract
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-muted text-center py-4">
                                <i class="bi bi-house-slash d-block fs-1 mb-2" style="color: var(--ocean-200);"></i>
                                No active room. <a href="${pageContext.request.contextPath}/contract?action=signContract" style="color: var(--ocean-700); font-weight: 600;">Sign a contract</a> to get started.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card section-card mb-4">
                <div class="card-header d-flex align-items-center gap-2">
                    <i class="bi bi-receipt"></i> Current Bill
                </div>
                <div class="card-body px-4 py-3">
                    <c:choose>
                        <c:when test="${not empty currentBill}">
                            <div class="info-row">
                                <span class="info-label">Amount Due</span>
                                <span class="fw-bold text-danger fs-5">
                                    <fmt:formatNumber value="${currentBill.totalAmount}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Period</span>
                                <span class="fw-semibold text-dark">${currentBill.period}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Due Date</span>
                                <span class="fw-semibold text-dark">${currentBill.dueDate}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status</span>
                                <span class="status-badge status-badge-${currentBill.status}">${currentBill.status}</span>
                            </div>
                            <div class="mt-4 d-flex gap-2">
                                <c:if test="${currentBill.status != 'paid'}">
                                    <a href="${pageContext.request.contextPath}/bill?action=detail&id=${currentBill.billId}"
                                       class="btn btn-sm btn-danger px-3 fw-semibold">
                                        <i class="bi bi-credit-card me-1"></i>Pay Bill
                                    </a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/bill?action=mybill"
                                   class="btn btn-sm btn-outline-ocean px-3">
                                    <i class="bi bi-list-ul me-1"></i>View All Bills
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-muted text-center py-4">
                                <i class="bi bi-receipt d-block fs-1 mb-2" style="color: var(--ocean-200);"></i>
                                You have no pending bills.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>

        <div class="col-lg-5">

            <div class="card section-card mb-4">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <span><i class="bi bi-bell me-2"></i>Notifications</span>
                    <a href="${pageContext.request.contextPath}/notification?action=publicList"
                       class="view-all small">View all</a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty recentNotifications}">
                            <div class="text-muted text-center py-5 small">
                                <i class="bi bi-bell-slash d-block fs-2 mb-2" style="color: var(--ocean-200);"></i>No new notifications
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="list-group list-group-flush">
                                <c:forEach var="n" items="${recentNotifications}">
                                    <li class="list-group-item border-0 px-4 py-3">
                                        <div class="fw-semibold small text-truncate" style="max-width:300px; color: var(--ocean-900);">${n.title}</div>
                                        <div class="text-muted mt-1" style="font-size:.8rem;"><i class="bi bi-clock me-1"></i>${n.createdAt}</div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card section-card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <span><i class="bi bi-tools me-2"></i>Service Requests</span>
                    <a href="${pageContext.request.contextPath}/services?action=myHistory"
                       class="view-all small">View all</a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty recentServices}">
                            <div class="text-muted text-center py-5 small">
                                <i class="bi bi-clipboard-x d-block fs-2 mb-2" style="color: var(--ocean-200);"></i>No service requests
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="list-group list-group-flush">
                                <c:forEach var="s" items="${recentServices}">
                                    <li class="list-group-item border-0 px-4 py-3 d-flex justify-content-between align-items-center">
                                        <div>
                                            <div class="fw-semibold small" style="color: var(--ocean-900);">${s.serviceName}</div>
                                            <div class="text-muted mt-1" style="font-size:.8rem;"><i class="bi bi-calendar-event me-1"></i>${s.usageDate}</div>
                                        </div>
                                        <span class="status-badge status-badge-${s.status}">${s.status}</span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>