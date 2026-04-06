<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page session="true"%>
<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="t"   tagdir="/WEB-INF/tags"%>

<t:layout>

    <!-- Page header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-0 fw-bold">Admin Dashboard</h4>
            <small class="text-muted">Welcome back, <strong>${sessionScope.user.fullName}</strong></small>
        </div>
        <span class="badge bg-danger text-uppercase">${sessionScope.user.role}</span>
    </div>

    <!-- KPI ROW 1: Room + Contract + Service counts -->
    <div class="row g-3 mb-3">
        <!-- Total rooms -->
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-primary bg-opacity-10 p-3">
                        <i class="bi bi-house-door text-primary fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Total Rooms</div>
                        <div class="fw-bold fs-5">${roomStats.total}</div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Occupied rooms -->
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-danger bg-opacity-10 p-3">
                        <i class="bi bi-person-fill text-danger fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Occupied</div>
                        <div class="fw-bold fs-5">${roomStats.occupied}</div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Active contracts -->
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-success bg-opacity-10 p-3">
                        <i class="bi bi-file-earmark-check text-success fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Active Contracts</div>
                        <div class="fw-bold fs-5">${activeContracts}</div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Pending service requests -->
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-warning bg-opacity-10 p-3">
                        <i class="bi bi-tools text-warning fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Pending Service Requests</div>
                        <div class="fw-bold fs-5 ${pendingSvcCount > 0 ? 'text-warning' : ''}">${pendingSvcCount}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- KPI ROW 2: Revenue summary -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-success bg-opacity-10 p-3">
                        <i class="bi bi-cash-stack text-success fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Collected</div>
                        <div class="fw-bold fs-6 text-success">
                            <fmt:formatNumber value="${billStats.revenuePaid}" type="number" groupingUsed="true"/> &#8363;
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-danger bg-opacity-10 p-3">
                        <i class="bi bi-exclamation-circle text-danger fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Outstanding</div>
                        <div class="fw-bold fs-6 text-danger">
                            <fmt:formatNumber value="${billStats.revenueOutstanding}" type="number" groupingUsed="true"/> &#8363;
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-danger bg-opacity-10 p-3">
                        <i class="bi bi-receipt text-danger fs-5"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Overdue Bills</div>
                        <div class="fw-bold fs-5 ${billStats.overdue > 0 ? 'text-danger' : ''}">${billStats.overdue}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts row -->
    <div class="row g-3 mb-4">
        <!-- Room status donut -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-semibold border-bottom-0 pt-3 pb-0">Room Status</div>
                <div class="card-body d-flex justify-content-center align-items-center py-3">
                    <canvas id="roomDonut" width="220" height="220"></canvas>
                </div>
            </div>
        </div>
        <!-- Monthly revenue bar -->
        <div class="col-md-8">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-semibold border-bottom-0 pt-3 pb-0">Revenue - Last 6 Months</div>
                <div class="card-body">
                    <canvas id="revenueBar" height="110"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- Tables row: Expiring contracts + Overdue bills -->
    <div class="row g-3 mb-4">
        <!-- Expiring contracts -->
        <div class="col-md-6">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <span class="fw-semibold">Contracts Expiring Soon <span class="badge bg-warning text-dark ms-1">30 days</span></span>
                    <a href="${pageContext.request.contextPath}/contract?action=list" class="btn btn-sm btn-outline-primary">View All</a>
                </div>
                <div class="card-body p-0">
                    <table class="table table-sm table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Room</th>
                                <th>Tenant</th>
                                <th>Expires</th>
                                <th>Remaining</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${expiringContracts}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/contract?action=detail&id=${c.contractId}" class="text-decoration-none fw-semibold">
                                            ${c.roomNumber}
                                        </a>
                                    </td>
                                    <td>${c.tenantName}</td>
                                    <td>${c.endDate}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.daysLeft <= 7}">
                                                <span class="badge bg-danger">${c.daysLeft}d</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark">${c.daysLeft}d</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty expiringContracts}">
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-3">
                                        <i class="bi bi-check-circle me-1"></i>No contracts expiring soon
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Overdue bills -->
        <div class="col-md-6">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <span class="fw-semibold">Overdue Bills</span>
                    <a href="${pageContext.request.contextPath}/bill?action=status&status=overdue" class="btn btn-sm btn-outline-danger">View All</a>
                </div>
                <div class="card-body p-0">
                    <table class="table table-sm table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Room</th>
                                <th>Tenant</th>
                                <th>Period</th>
                                <th class="text-end">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${overdueBills}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/bill?action=detail&id=${b.billId}" class="text-decoration-none fw-semibold">
                                            ${b.roomNumber}
                                        </a>
                                    </td>
                                    <td>${b.tenantName}</td>
                                    <td>${b.period}</td>
                                    <td class="text-end text-danger fw-semibold">
                                        <fmt:formatNumber value="${b.amount}" type="number" groupingUsed="true"/>&#8363;
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty overdueBills}">
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-3">
                                        <i class="bi bi-check-circle me-1"></i>No overdue bills
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Pending service requests table -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <span class="fw-semibold">Pending Service Requests</span>
                    <a href="${pageContext.request.contextPath}/services?action=manageRequests" class="btn btn-sm btn-outline-warning">View All</a>
                </div>
                <div class="card-body p-0">
                    <table class="table table-sm table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Room</th>
                                <th>Tenant</th>
                                <th>Service</th>
                                <th>Qty</th>
                                <th>Request Date</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${pendingSvcList}">
                                <tr>
                                    <td class="fw-semibold">${s.roomNumber}</td>
                                    <td>${s.requester}</td>
                                    <td>${s.serviceName}</td>
                                    <td>${s.quantity}</td>
                                    <td>${s.usageDate}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/services?action=manageRequests"
                                           class="btn btn-sm btn-success">Approve</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty pendingSvcList}">
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-3">
                                        <i class="bi bi-check-circle me-1"></i>No pending requests
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Access (preserved from original) -->
    <h6 class="text-muted text-uppercase mb-3" style="font-size:0.72rem;letter-spacing:.08em;">Quick Access</h6>
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/bill?action=list" class="text-decoration-none">
                <div class="card border-0 shadow-sm p-3 h-100 d-flex flex-row align-items-center gap-3">
                    <div class="rounded-circle bg-primary bg-opacity-10 p-3">
                        <i class="bi bi-receipt text-primary"></i>
                    </div>
                    <div>
                        <div class="fw-semibold">Bills</div>
                        <div class="text-muted small">View and manage all bills</div>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-sm-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/contract?action=list" class="text-decoration-none">
                <div class="card border-0 shadow-sm p-3 h-100 d-flex flex-row align-items-center gap-3">
                    <div class="rounded-circle bg-success bg-opacity-10 p-3">
                        <i class="bi bi-file-earmark-text text-success"></i>
                    </div>
                    <div>
                        <div class="fw-semibold">Contracts</div>
                        <div class="text-muted small">Manage rental contracts</div>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-sm-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/manage-customer" class="text-decoration-none">
                <div class="card border-0 shadow-sm p-3 h-100 d-flex flex-row align-items-center gap-3">
                    <div class="rounded-circle bg-warning bg-opacity-10 p-3">
                        <i class="bi bi-people text-warning"></i>
                    </div>
                    <div>
                        <div class="fw-semibold">Customers</div>
                        <div class="text-muted small">View and edit tenants</div>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-sm-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/room" class="text-decoration-none">
                <div class="card border-0 shadow-sm p-3 h-100 d-flex flex-row align-items-center gap-3">
                    <div class="rounded-circle bg-info bg-opacity-10 p-3">
                        <i class="bi bi-house-door text-info"></i>
                    </div>
                    <div>
                        <div class="fw-semibold">Rooms</div>
                        <div class="text-muted small">Manage room listings</div>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-sm-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/utility" class="text-decoration-none">
                <div class="card border-0 shadow-sm p-3 h-100 d-flex flex-row align-items-center gap-3">
                    <div class="rounded-circle bg-secondary bg-opacity-10 p-3">
                        <i class="bi bi-lightning-charge text-secondary"></i>
                    </div>
                    <div>
                        <div class="fw-semibold">Utilities</div>
                        <div class="text-muted small">Electricity, water, gas</div>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-sm-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/activity-log" class="text-decoration-none">
                <div class="card border-0 shadow-sm p-3 h-100 d-flex flex-row align-items-center gap-3">
                    <div class="rounded-circle bg-danger bg-opacity-10 p-3">
                        <i class="bi bi-activity text-danger"></i>
                    </div>
                    <div>
                        <div class="fw-semibold">Activity Logs</div>
                        <div class="text-muted small">Audit trail &amp; history</div>
                    </div>
                </div>
            </a>
        </div>
    </div>

    <!-- Chart.js (loaded after canvas elements, before Bootstrap bundle from layout.tag) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script>
        // Room status donut
        (function () {
            var available   = ${roomStats.available   != null ? roomStats.available   : 0};
            var occupied    = ${roomStats.occupied    != null ? roomStats.occupied    : 0};
            var maintenance = ${roomStats.maintenance != null ? roomStats.maintenance : 0};

            new Chart(document.getElementById('roomDonut'), {
                type: 'doughnut',
                data: {
                    labels: ['Available', 'Occupied', 'Maintenance'],
                    datasets: [{
                        data: [available, occupied, maintenance],
                        backgroundColor: ['#198754', '#dc3545', '#ffc107'],
                        borderWidth: 2,
                        borderColor: '#fff'
                    }]
                },
                options: {
                    plugins: { legend: { position: 'bottom' } },
                    cutout: '65%'
                }
            });
        })();

        // Monthly revenue bar chart
        (function () {
            var revenueData = [
                <c:forEach var="r" items="${monthlyRevenue}" varStatus="s">
                {
                    month: '${r.month}',
                    paid: ${r.paid != null ? r.paid : 0},
                    outstanding: ${r.outstanding != null ? r.outstanding : 0}
                }${!s.last ? ',' : ''}
                </c:forEach>
            ];

            new Chart(document.getElementById('revenueBar'), {
                type: 'bar',
                data: {
                    labels: revenueData.map(function (r) { return r.month; }),
                    datasets: [
                        {
                            label: 'Collected',
                            data: revenueData.map(function (r) { return r.paid; }),
                            backgroundColor: '#198754',
                            borderRadius: 4
                        },
                        {
                            label: 'Outstanding',
                            data: revenueData.map(function (r) { return r.outstanding; }),
                            backgroundColor: '#dc3545',
                            borderRadius: 4,
                            stack: 'stack'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: { legend: { position: 'top' } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function (v) {
                                    return (v / 1000000).toFixed(1) + 'M';
                                }
                            }
                        }
                    }
                }
            });
        })();
    </script>

</t:layout>
