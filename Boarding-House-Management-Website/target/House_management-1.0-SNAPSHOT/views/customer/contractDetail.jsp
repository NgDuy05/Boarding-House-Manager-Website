<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Contract Detail - AKDD House</title>
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
            border-radius: 18px; 
            padding: 24px 30px; 
            margin-bottom: 24px; 
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-header .btn-light {
            background-color: #ffffff;
            color: var(--ocean-900);
            border: none;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.2s;
        }
        .page-header .btn-light:hover {
            background-color: var(--ocean-100);
            transform: translateY(-2px);
        }

        /* 4. Info Cards */
        .info-card { 
            border-radius: 16px; 
            border: none; 
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03); 
        }
        .label-sm { 
            font-size: 13px; 
            font-weight: 800; 
            text-transform: uppercase; 
            letter-spacing: 0.8px; 
            color: var(--ocean-900); 
            border-bottom: 2px solid var(--ocean-100);
            padding-bottom: 8px;
        }
        .info-row { 
            border-bottom: 1px dashed var(--ocean-200); 
            padding: 12px 0; 
            display: flex; 
            justify-content: space-between;
            align-items: center;
        }
        .info-row:last-child { border-bottom: none; padding-bottom: 0; }
        .info-row .text-muted { color: #5A5C63 !important; font-weight: 500; }
        .info-row .fw-semibold { color: var(--ocean-900); }

        /* 5. Nav Pills (Tabs) */
        .nav-pills .nav-link { 
            color: var(--ocean-700); 
            font-weight: 600; 
            border-radius: 10px; 
            margin-right: 8px;
            padding: 10px 20px;
            transition: all 0.2s ease;
        }
        .nav-pills .nav-link:hover:not(.active) { background-color: var(--ocean-100); color: var(--ocean-900); }
        .nav-pills .nav-link.active { 
            background-color: var(--ocean-800); 
            color: white !important; 
            box-shadow: 0 4px 12px rgba(2, 62, 138, 0.25);
        }
        
        /* 6. Tables */
        .table thead th { 
            background-color: var(--ocean-100) !important; 
            color: var(--ocean-900) !important; 
            font-size: 13px; 
            font-weight: 700; 
            text-transform: uppercase; 
            letter-spacing: 0.5px; 
            border: none; 
            padding: 14px 16px;
        }
        .table tbody tr:hover { background-color: rgba(0, 119, 182, 0.05) !important; }
        .table td { padding: 14px 16px; vertical-align: middle; }

        /* 7. Custom Colors */
        .text-ocean { color: var(--ocean-700) !important; }
        .bg-ocean-subtle { background-color: var(--ocean-100) !important; color: var(--ocean-800) !important; }
        .badge-owner { background-color: var(--ocean-800); color: #fff; }
    </style>
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4">
<div style="max-width: 1000px; margin: 0 auto;">

    <%-- Page Header --%>
    <div class="page-header d-flex align-items-center gap-3 flex-wrap">
        <div class="rounded-circle bg-white bg-opacity-25 d-flex align-items-center justify-content-center" style="width:64px;height:64px;font-size:28px;flex-shrink:0; border: 2px solid rgba(255,255,255,0.3);">
            <i class="bi bi-file-earmark-text"></i>
        </div>
        <div class="flex-grow-1">
            <h3 class="mb-1 fw-bold">Contract #${contract.contractId}</h3>
            <div class="opacity-75 small" style="font-size: 14px;">
                <i class="bi bi-door-closed me-1"></i>Room ${contract.roomNumber}
                <c:if test="${not empty contract.categoryName}">&middot; ${contract.categoryName}</c:if>
            </div>
        </div>
        <span class="badge bg-${contract.statusColor}-subtle text-${contract.statusColor} border border-${contract.statusColor}-subtle rounded-pill fs-6 px-4 py-2 shadow-sm">${contract.statusLabel}</span>
        <a href="${pageContext.request.contextPath}/contract?action=mycontract" class="btn btn-light btn-sm ms-3 px-3 py-2">
            <i class="bi bi-arrow-left me-1"></i>Back
        </a>
    </div>

    <div class="row g-4">
        <%-- Left: Info Cards --%>
        <div class="col-lg-4">
            <div class="card info-card mb-4">
                <div class="card-body p-4">
                    <div class="label-sm mb-3"><i class="bi bi-house me-2 text-ocean"></i>Room Info</div>
                    <div class="info-row"><span class="text-muted small">Room Number</span><span class="fw-semibold">Room ${contract.roomNumber}</span></div>
                    <div class="info-row"><span class="text-muted small">Category</span><span class="fw-semibold">${not empty contract.categoryName ? contract.categoryName : '—'}</span></div>
                    <div class="info-row">
                        <span class="text-muted small">Monthly Rent</span>
                        <span class="fw-bold fs-6 text-success">
                            <c:choose>
                                <c:when test="${not empty contract.monthlyRent and contract.monthlyRent > 0}">
                                    <fmt:formatNumber value="${contract.monthlyRent}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                </c:when>
                                <c:when test="${not empty contract.basePrice}">
                                    <fmt:formatNumber value="${contract.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                </c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
            </div>

            <div class="card info-card">
                <div class="card-body p-4">
                    <div class="label-sm mb-3"><i class="bi bi-file-text me-2 text-ocean"></i>Contract Terms</div>
                    <div class="info-row"><span class="text-muted small">Contract ID</span><span class="fw-bold text-ocean">#${contract.contractId}</span></div>
                    <div class="info-row"><span class="text-muted small">Deposit Paid</span><span class="fw-bold text-ocean"><fmt:formatNumber value="${contract.deposit}" groupingUsed="true" maxFractionDigits="0"/>&#8363;</span></div>
                    <div class="info-row"><span class="text-muted small">Start Date</span><span class="fw-semibold">${contract.startDate}</span></div>
                    <div class="info-row"><span class="text-muted small">End Date</span><span class="fw-semibold">${not empty contract.endDate ? contract.endDate : '—'}</span></div>
                    <div class="info-row mt-2 border-0">
                        <span class="text-muted small">Status</span>
                        <span class="badge bg-${contract.statusColor}-subtle text-${contract.statusColor} border border-${contract.statusColor}-subtle rounded-pill px-3">${contract.statusLabel}</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Right: Tabs Content --%>
        <div class="col-lg-8">
            <ul class="nav nav-pills mb-4">
                <li class="nav-item">
                    <button class="nav-link active" data-bs-toggle="pill" data-bs-target="#t-roommates">
                        <i class="bi bi-people me-1"></i>Roommates 
                        <span class="badge bg-white text-dark ms-1 shadow-sm" style="border-radius: 20px;">${tenants.size()}</span>
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#t-tenants">
                        <i class="bi bi-person-vcard me-1"></i>Tenants 
                        <span class="badge bg-white text-dark ms-1 shadow-sm" style="border-radius: 20px;">${contractTenants.size()}</span>
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#t-bills">
                        <i class="bi bi-receipt me-1"></i>Bills 
                        <span class="badge bg-white text-dark ms-1 shadow-sm" style="border-radius: 20px;">${bills.size()}</span>
                    </button>
                </li>
            </ul>

            <div class="tab-content">
                <%-- Roommates Tab --%>
                <div class="tab-pane fade show active" id="t-roommates">
                    <div class="card info-card">
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${empty tenants}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="bi bi-people fs-1 d-block mb-3" style="color: var(--ocean-200);"></i>
                                        <h6 class="fw-semibold" style="color: var(--ocean-800);">No roommates listed</h6>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="d-flex flex-column gap-3">
                                        <c:forEach var="t" items="${tenants}">
                                            <div class="d-flex align-items-center gap-3 p-3 rounded-4" style="border: 1px solid var(--ocean-100); background-color: #fafbfc;">
                                                <div class="rounded-circle bg-ocean-subtle d-flex align-items-center justify-content-center fw-bold"
                                                     style="width:48px;height:48px;flex-shrink:0;font-size:18px">
                                                    ${not empty t.fullName ? t.fullName.substring(0,1).toUpperCase() : '?'}
                                                </div>
                                                <div class="flex-grow-1">
                                                    <div class="fw-bold" style="color: var(--ocean-900); font-size: 15px;">${not empty t.fullName ? t.fullName : t.username}</div>
                                                    <div class="text-muted small mt-1">Joined ${t.joinedAt}
                                                        <c:if test="${not empty t.leftAt}"> &middot; Left ${t.leftAt}</c:if>
                                                    </div>
                                                </div>
                                                <span class="badge ${t.role=='owner'?'badge-owner':'bg-secondary text-white'} rounded-pill px-3 py-2 text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">${t.role}</span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <%-- Tenants Tab --%>
                <div class="tab-pane fade" id="t-tenants">
                    <div class="card info-card">
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${empty contractTenants}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="bi bi-person-vcard fs-1 d-block mb-3" style="color: var(--ocean-200);"></i>
                                        <h6 class="fw-semibold" style="color: var(--ocean-800);">No tenant records found</h6>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="d-flex flex-column gap-3">
                                        <c:forEach var="t" items="${contractTenants}">
                                            <div class="d-flex align-items-center gap-3 p-3 rounded-4" style="border: 1px solid var(--ocean-100); background-color: #fafbfc;">
                                                <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold flex-shrink-0
                                                            ${t.primary ? 'badge-owner' : 'bg-secondary text-white'}"
                                                     style="width:48px;height:48px;flex-shrink:0;font-size:18px">
                                                    ${t.fullName.substring(0,1).toUpperCase()}
                                                </div>
                                                <div class="flex-grow-1">
                                                    <div class="fw-bold" style="color: var(--ocean-900); font-size: 15px;">${t.fullName}</div>
                                                    <div class="text-muted small mt-1">
                                                        <c:if test="${not empty t.phone}"><i class="bi bi-telephone me-1" style="color: var(--ocean-600);"></i>${t.phone} &nbsp;</c:if>
                                                        <c:if test="${not empty t.birthDate}"><i class="bi bi-calendar me-1" style="color: var(--ocean-600);"></i>${t.birthDate}</c:if>
                                                    </div>
                                                </div>
                                                <span class="badge ${t.primary ? 'badge-owner' : 'bg-secondary text-white'} rounded-pill px-3 py-2 text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">${t.roleLabel}</span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <%-- Bills Tab --%>
                <div class="tab-pane fade" id="t-bills">
                    <div class="card info-card overflow-hidden">
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty bills}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="bi bi-receipt fs-1 d-block mb-3" style="color: var(--ocean-200);"></i>
                                        <h6 class="fw-semibold" style="color: var(--ocean-800);">No bills associated</h6>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table align-middle mb-0">
                                            <thead>
                                                <tr>
                                                    <th class="ps-4">ID</th>
                                                    <th>Period</th>
                                                    <th>Due Date</th>
                                                    <th>Amount</th>
                                                    <th class="text-center pe-4">Status</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="b" items="${bills}">
                                                    <tr>
                                                        <td class="ps-4 text-muted small fw-semibold">#${b.billId}</td>
                                                        <td class="fw-semibold" style="color: var(--ocean-900);">${b.period}</td>
                                                        <td class="text-muted small">${b.dueDate}</td>
                                                        <td class="fw-bold" style="color: var(--ocean-800);">${b.totalAmount}&#8363;</td>
                                                        <td class="text-center pe-4">
                                                            <c:choose>
                                                                <c:when test="${b.status=='paid'}"><span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3"><i class="bi bi-check-circle me-1"></i>Paid</span></c:when>
                                                                <c:when test="${b.status=='pending'}"><span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-3"><i class="bi bi-clock me-1"></i>Unpaid</span></c:when>
                                                                <c:when test="${b.status=='overdue'}"><span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3"><i class="bi bi-exclamation-circle me-1"></i>Overdue</span></c:when>
                                                                <c:otherwise><span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-3">${b.status}</span></c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
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