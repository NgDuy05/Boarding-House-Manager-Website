<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Service History - AKDD House</title>
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
        .page-hero h1 { font-weight: 800; font-size: 1.9rem; letter-spacing: -0.5px; }
        .page-hero p  { opacity: .85; font-size: 1.05rem; }

        .btn-request-new {
            background: rgba(255,255,255,.15);
            border: 1px solid rgba(255,255,255,.3);
            color: #fff; border-radius: 50px; padding: 12px 24px;
            text-decoration: none; font-weight: 700; font-size: .95rem;
            display: inline-flex; align-items: center; gap: .5rem;
            transition: all .2s ease;
        }
        .btn-request-new:hover {
            background: rgba(255,255,255,.25);
            color: #fff; text-decoration: none;
            transform: translateY(-2px);
        }

        /* ── Stat Chips ── */
        .stat-chip {
            background: #fff; border-radius: 16px;
            padding: 16px 22px;
            box-shadow: 0 4px 16px rgba(0,0,0,.04);
            display: flex; align-items: center; gap: 1rem;
            transition: transform 0.2s ease;
        }
        .stat-chip:hover { transform: translateY(-3px); }
        .stat-chip .chip-icon {
            width: 48px; height: 48px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0;
        }
        .chip-total   .chip-icon { background: var(--ocean-100); color: var(--ocean-800); }
        .chip-pending .chip-icon { background: #fef08a; color: #a16207; }
        .chip-billed  .chip-icon { background: #d1fae5; color: #065f46; }
        
        .stat-chip .chip-num { font-size: 1.6rem; font-weight: 800; color: var(--ocean-900); line-height:1; }
        .stat-chip .chip-lbl { font-size: .85rem; color: #6b7280; margin-top: 4px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px;}

        /* ── Filter Bar ── */
        .filter-bar {
            background: #fff; border-radius: 50px;
            padding: 6px; display: inline-flex; gap: 4px; flex-wrap: wrap;
            box-shadow: 0 4px 16px rgba(0,0,0,.04);
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
            color: #fff; box-shadow: 0 4px 10px rgba(0, 119, 182, 0.2);
        }

        /* ── History Table ── */
        .history-card {
            border: none; border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,.04);
            overflow: hidden; background: #fff;
        }
        .table thead th { 
            background-color: var(--ocean-100) !important; 
            color: var(--ocean-900) !important; 
            font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; 
            border: none; padding: 16px;
        }
        .table tbody tr:hover { background-color: rgba(0, 119, 182, 0.05) !important; }
        .table td { padding: 16px; vertical-align: middle; border-bottom: 1px solid #f0f4f8; }

        .service-tag {
            display: inline-flex; align-items: center; gap: .4rem;
            background: var(--ocean-100); color: var(--ocean-800);
            border-radius: 50px; padding: 4px 12px;
            font-size: .8rem; font-weight: 700;
        }
        .total-cost { font-weight: 800; color: var(--ocean-700); font-size: 1.05rem; }
        
        .status-badge {
            border-radius: 50px; padding: 4px 12px; font-size: .75rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: 0.5px; display: inline-flex; align-items: center; gap: 4px;
        }
        .status-billed   { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .status-pending  { background: #fef9c3; color: #a16207; border: 1px solid #fef08a; }
        .status-rejected { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
        .status-approved { background: var(--ocean-100); color: var(--ocean-800); border: 1px solid var(--ocean-300); }

        .empty-icon { font-size: 4rem; color: var(--ocean-200); }
        .btn-ocean {
            background: linear-gradient(135deg, var(--ocean-700), var(--ocean-500));
            color: white; border: none; font-weight: 700; border-radius: 10px;
            padding: 10px 24px; transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-ocean:hover {
            transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 150, 199, 0.25); color: white;
        }
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
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/services" class="text-white text-opacity-75 text-decoration-none">Services</a>
                    </li>
                    <li class="breadcrumb-item active text-white fw-semibold">My Service History</li>
                </ol>
            </nav>
            <div class="d-flex align-items-start justify-content-between flex-wrap gap-3">
                <div>
                    <h1><i class="bi bi-clock-history me-2"></i>My Service History</h1>
                    <p class="mb-0">Track all services used in your tenancy period</p>
                </div>
                <a href="${pageContext.request.contextPath}/services?action=requestForm" class="btn-request-new">
                    <i class="bi bi-send-fill"></i>Request New Service
                </a>
            </div>
        </div>
    </div>

    <div class="container pb-5" style="padding-top: 48px;">

        <%-- Stats strip --%>
        <div class="row g-3 mb-4">
            <%-- Compute stats --%>
            <c:set var="totalRecords" value="${historyList.size()}" />
            <c:set var="pendingCount" value="0" />
            <c:set var="billedCount"  value="0" />
            <c:set var="grandTotal"   value="0" />
            <c:forEach var="h" items="${historyList}">
                <c:choose>
                    <c:when test="${h.billed}">
                        <c:set var="billedCount" value="${billedCount + 1}" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="pendingCount" value="${pendingCount + 1}" />
                    </c:otherwise>
                </c:choose>
                <c:set var="grandTotal" value="${grandTotal + h.totalCost}" />
            </c:forEach>

            <div class="col-sm-6 col-lg-3">
                <div class="stat-chip chip-total">
                    <div class="chip-icon"><i class="bi bi-grid-1x2-fill"></i></div>
                    <div>
                        <div class="chip-num">${totalRecords}</div>
                        <div class="chip-lbl">Total records</div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="stat-chip chip-pending">
                    <div class="chip-icon"><i class="bi bi-hourglass-split"></i></div>
                    <div>
                        <div class="chip-num">${pendingCount}</div>
                        <div class="chip-lbl">Pending billing</div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="stat-chip chip-billed">
                    <div class="chip-icon"><i class="bi bi-check-circle-fill"></i></div>
                    <div>
                        <div class="chip-num">${billedCount}</div>
                        <div class="chip-lbl">Already billed</div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="stat-chip chip-total">
                    <div class="chip-icon"><i class="bi bi-cash-stack"></i></div>
                    <div>
                        <div class="chip-num" style="font-size:1.3rem">
                            <fmt:formatNumber value="${grandTotal}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                        </div>
                        <div class="chip-lbl">Estimated total</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Filter buttons --%>
        <div class="d-flex align-items-center gap-3 mb-4">
            <span class="text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;"><i class="bi bi-funnel-fill me-1"></i>Filter:</span>
            <div class="filter-bar" id="filterContainer">
                <button class="filter-btn active" onclick="filterHistory('all', this)"><i class="bi bi-grid-fill"></i> All</button>
                <button class="filter-btn" onclick="filterHistory('pending', this)"><i class="bi bi-hourglass-split"></i> Pending</button>
                <button class="filter-btn" onclick="filterHistory('billed', this)"><i class="bi bi-check-circle-fill"></i> Billed</button>
            </div>
        </div>

        <%-- History table --%>
        <div class="history-card card">
            <c:choose>
                <c:when test="${not empty historyList}">
                    <div class="table-responsive">
                        <table class="table mb-0" id="historyTable">
                            <thead>
                                <tr>
                                    <th class="ps-4">#</th>
                                    <th>Service</th>
                                    <th>Room / Contract</th>
                                    <th>Usage Date</th>
                                    <th class="text-center">Qty</th>
                                    <th class="text-end">Unit Price</th>
                                    <th class="text-end">Amount</th>
                                    <th class="text-center pe-4">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="h" items="${historyList}" varStatus="st">
                                    <tr data-status="${h.billed ? 'billed' : 'pending'}">
                                        <td class="ps-4 text-muted small fw-bold">${st.count}</td>
                                        <td>
                                            <span class="service-tag">
                                                <i class="bi bi-lightning-charge-fill"></i>
                                                ${h.serviceName}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="fw-bold" style="color: var(--ocean-900); font-size: .95rem;">Room ${h.roomNumber}</div>
                                            <div class="text-muted" style="font-size:.8rem; font-weight: 500;">Contract #${h.contractId}</div>
                                        </td>
                                        <td class="text-muted small fw-semibold">${h.usageDate}</td>
                                        <td class="text-center small fw-semibold">${h.quantity}</td>
                                        <td class="text-end text-muted small">
                                            <fmt:formatNumber value="${h.unitPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                        </td>
                                        <td class="text-end">
                                            <span class="total-cost">
                                                <fmt:formatNumber value="${h.totalCost}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                            </span>
                                        </td>
                                        <td class="text-center pe-4">
                                            <c:choose>
                                                <c:when test="${h.status == 'pending'}">
                                                    <span class="status-badge status-pending">
                                                        <i class="bi bi-hourglass-split"></i>Pending
                                                    </span>
                                                </c:when>
                                                <c:when test="${h.status == 'rejected'}">
                                                    <span class="status-badge status-rejected">
                                                        <i class="bi bi-x-circle-fill"></i>Rejected
                                                    </span>
                                                </c:when>
                                                <c:when test="${h.billed}">
                                                    <span class="status-badge status-billed">
                                                        <i class="bi bi-receipt"></i>Billed
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-approved">
                                                        <i class="bi bi-check-circle-fill"></i>Approved
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <div class="empty-icon mb-3">
                            <i class="bi bi-clock-history"></i>
                        </div>
                        <h4 class="fw-bold" style="color: var(--ocean-900);">No service history found</h4>
                        <p class="text-muted mb-4">You haven't used any services yet.</p>
                        <a href="${pageContext.request.contextPath}/services" class="btn btn-ocean">
                            <i class="bi bi-grid-fill me-2"></i>Browse Services
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterHistory(status, btnElement) {
            // Update active state on buttons
            var buttons = document.querySelectorAll('#filterContainer .filter-btn');
            buttons.forEach(function(btn) {
                btn.classList.remove('active');
            });
            btnElement.classList.add('active');

            // Filter rows
            var rows = document.querySelectorAll('#historyTable tbody tr');
            rows.forEach(function(row) {
                if (status === 'all') {
                    row.style.display = '';
                } else {
                    row.style.display = (row.getAttribute('data-status') === status) ? '' : 'none';
                }
            });
        }
    </script>
        </main>
      </div>
    </div>
</body>
</html>