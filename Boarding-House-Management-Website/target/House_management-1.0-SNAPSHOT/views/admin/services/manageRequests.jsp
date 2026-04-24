<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t"   tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<t:layout>

<style>
    /* 1. Header Gradient using the dark blues */
    .page-header {
        background: linear-gradient(135deg, #001D39, #0A4174, #49769F);
        color: white; 
        border-radius: 12px; 
        padding: 20px 24px; 
        margin-bottom: 24px;
        box-shadow: 0 4px 12px rgba(0, 29, 57, 0.15);
    }
    .page-header .btn-outline-light { border: 1px solid rgba(255,255,255,0.5); color: #fff; font-weight: 600; }
    .page-header .btn-outline-light:hover { background: rgba(255,255,255,0.15); border-color: #fff; color: #fff; }

    /* 2. Table styling */
    .table-card { border-radius: 14px; border: none; overflow: hidden; }
    .table thead th { 
        background: #BDD8E9 !important; 
        color: #001D39 !important; 
        font-size: 12px; 
        font-weight: 700; 
        text-transform: uppercase; 
        letter-spacing: .5px; 
        border: none; 
    }
    .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); }

    /* 3. Custom Theme Buttons */
    .btn-theme-dark { background-color: #001D39; color: white; border: none; }
    .btn-theme-dark:hover { background-color: #0A4174; color: white; }

    .btn-outline-theme { border-color: #49769F; color: #49769F; }
    .btn-outline-theme:hover { background-color: #49769F; color: white; }
    
    .btn-outline-action-view { border-color: #4E8EA2; color: #4E8EA2; }
    .btn-outline-action-view:hover { background-color: #4E8EA2; color: white; }
    
    /* 4. Update Modal styling */
    .modal-theme-header { color: #001D39; }
    .bg-theme-subtle { background: rgba(123, 189, 232, 0.15); }
</style>

    <%-- Page header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="mb-0 fs-4 fw-bold">
                <i class="bi bi-clipboard2-check me-2"></i>Manage Service Requests
            </h2>
            <p class="mb-0 small" style="color: #BDD8E9;">Review and approve/reject service requests from tenants</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/services?action=requestList"
               class="btn btn-outline-light btn-sm px-3 py-2">
                <i class="bi bi-list-check me-1"></i>All Usage Records
            </a>
            <a href="${pageContext.request.contextPath}/services?action=adminList"
               class="btn btn-outline-light btn-sm px-3 py-2">
                <i class="bi bi-gear me-1"></i>Manage Services
            </a>
        </div>
    </div>

    <%-- Stats cards --%>
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100" style="border-radius: 12px;">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="rounded-circle p-3 bg-warning-subtle">
                        <i class="bi bi-clock-fill fs-4 text-warning-emphasis"></i>
                    </div>
                    <div>
                        <div class="fs-3 fw-bold" style="color: #001D39;">${pendingCount}</div>
                        <div class="text-muted small">Pending Review</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/services?action=manageRequests&status=pending"
                       class="btn btn-sm btn-warning ms-auto fw-semibold">View</a>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100" style="border-radius: 12px;">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="rounded-circle p-3 bg-success-subtle">
                        <i class="bi bi-check-circle-fill fs-4 text-success"></i>
                    </div>
                    <div>
                        <div class="fs-3 fw-bold" style="color: #001D39;">${approvedCount}</div>
                        <div class="text-muted small">Approved</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/services?action=manageRequests&status=approved"
                       class="btn btn-sm btn-success ms-auto fw-semibold">View</a>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100" style="border-radius: 12px;">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="rounded-circle p-3 bg-danger-subtle">
                        <i class="bi bi-x-circle-fill fs-4 text-danger"></i>
                    </div>
                    <div>
                        <div class="fs-3 fw-bold" style="color: #001D39;">${rejectedCount}</div>
                        <div class="text-muted small">Rejected</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/services?action=manageRequests&status=rejected"
                       class="btn btn-sm btn-danger ms-auto fw-semibold">View</a>
                </div>
            </div>
        </div>
    </div>

    <%-- Filter tabs --%>
    <div class="card border-0 shadow-sm mb-0" style="border-radius:16px 16px 0 0;">
        <div class="card-body py-3 px-3 border-bottom">
            <div class="d-flex gap-2 flex-wrap">
                <a href="${pageContext.request.contextPath}/services?action=manageRequests"
                   class="btn btn-sm ${empty statusFilter ? 'btn-theme-dark' : 'btn-outline-theme'}">
                    <i class="bi bi-grid me-1"></i>All
                    <span class="badge ${empty statusFilter ? 'bg-white text-dark' : 'bg-secondary'} ms-1">
                        ${pendingCount + approvedCount + rejectedCount}
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/services?action=manageRequests&status=pending"
                   class="btn btn-sm ${statusFilter == 'pending' ? 'btn-warning' : 'btn-outline-warning text-dark'}">
                    <i class="bi bi-clock me-1"></i>Pending
                    <span class="badge bg-white text-dark ms-1">${pendingCount}</span>
                </a>
                <a href="${pageContext.request.contextPath}/services?action=manageRequests&status=approved"
                   class="btn btn-sm ${statusFilter == 'approved' ? 'btn-success' : 'btn-outline-success'}">
                    <i class="bi bi-check-circle me-1"></i>Approved
                    <span class="badge bg-white text-success ms-1">${approvedCount}</span>
                </a>
                <a href="${pageContext.request.contextPath}/services?action=manageRequests&status=rejected"
                   class="btn btn-sm ${statusFilter == 'rejected' ? 'btn-danger' : 'btn-outline-danger'}">
                    <i class="bi bi-x-circle me-1"></i>Rejected
                    <span class="badge bg-white text-danger ms-1">${rejectedCount}</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Requests table --%>
    <div class="card border-0 shadow-sm table-card" style="border-radius:0 0 16px 16px;">
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty requestList}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-4">#</th>
                                    <th>Tenant</th>
                                    <th>Contract / Room</th>
                                    <th>Service</th>
                                    <th>Date</th>
                                    <th class="text-end">Qty</th>
                                    <th class="text-end">Est. Cost</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-center pe-4">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="req" items="${requestList}" varStatus="st">
                                    <tr>
                                        <td class="ps-4 text-muted small">${st.count}</td>

                                        <%-- Tenant --%>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle p-2" style="background: rgba(10, 65, 116, 0.1);">
                                                    <i class="bi bi-person small" style="color: #0A4174;"></i>
                                                </div>
                                                <span class="fw-semibold small" style="color: #0A4174;">
                                                    <c:choose>
                                                        <c:when test="${not empty req.requesterName}">${req.requesterName}</c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </td>

                                        <%-- Contract / Room --%>
                                        <td>
                                            <div class="fw-semibold small" style="color: #001D39;">Contract #${req.contractId}</div>
                                            <div class="text-muted" style="font-size:.74rem">
                                                <i class="bi bi-door-closed me-1" style="color: #6EA2B3;"></i>Room ${req.roomNumber}
                                            </div>
                                        </td>

                                        <%-- Service --%>
                                        <td>
                                            <span class="badge border px-2 py-1" style="background: rgba(73, 118, 159, 0.1); color: #49769F; border-color: rgba(73, 118, 159, 0.2) !important;">
                                                <i class="bi bi-lightning-charge me-1"></i>${req.serviceName}
                                            </span>
                                        </td>

                                        <%-- Date --%>
                                        <td class="text-muted small">${req.usageDate}</td>

                                        <%-- Qty --%>
                                        <td class="text-end small">${req.quantity}</td>

                                        <%-- Est. Cost --%>
                                        <td class="text-end fw-semibold small" style="color: #001D39;">
                                            <fmt:formatNumber value="${req.totalCost}"
                                                groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                        </td>

                                        <%-- Status badge --%>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${req.status == 'pending'}">
                                                    <span class="badge rounded-pill bg-warning text-dark px-3 py-2">
                                                        <i class="bi bi-clock me-1"></i>Pending
                                                    </span>
                                                </c:when>
                                                <c:when test="${req.status == 'approved'}">
                                                    <span class="badge rounded-pill bg-success px-3 py-2">
                                                        <i class="bi bi-check-circle me-1"></i>Approved
                                                    </span>
                                                </c:when>
                                                <c:when test="${req.status == 'rejected'}">
                                                    <span class="badge rounded-pill bg-danger px-3 py-2">
                                                        <i class="bi bi-x-circle me-1"></i>Rejected
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge rounded-pill bg-secondary px-3 py-2">
                                                        ${req.status}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <%-- Actions --%>
                                        <td class="text-center pe-4">
                                            <div class="d-flex justify-content-center gap-1">
                                                <c:if test="${req.status == 'pending'}">
                                                    <a href="${pageContext.request.contextPath}/services?action=approve&id=${req.usageId}&from=${statusFilter}"
                                                       class="btn btn-sm btn-success"
                                                       onclick="return confirm('Approve this request?')"
                                                       title="Approve">
                                                        <i class="bi bi-check-lg"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/services?action=reject&id=${req.usageId}&from=${statusFilter}"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('Reject this request?')"
                                                       title="Reject">
                                                        <i class="bi bi-x-lg"></i>
                                                    </a>
                                                </c:if>
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-action-view"
                                                        title="Update Status"
                                                        onclick="openStatusModal(${req.usageId}, '${req.status}', '${statusFilter}', ${req.quantity}, ${req.unitPrice})"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#updateStatusModal">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="px-4 py-3 text-muted small border-top bg-white" style="border-radius: 0 0 16px 16px;">
                        Showing <strong>${requestList.size()}</strong> record(s)
                        <c:if test="${not empty statusFilter}"> — filtered by: <strong>${statusFilter}</strong></c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-inbox fs-1 d-block mb-3" style="color: #6EA2B3;"></i>
                        <h6 class="fw-semibold" style="color: #0A4174;">No requests found</h6>
                        <c:if test="${not empty statusFilter}">
                            <p class="small">No <strong>${statusFilter}</strong> requests at this time.</p>
                            <a href="${pageContext.request.contextPath}/services?action=manageRequests"
                               class="btn btn-sm btn-theme-dark">View All</a>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- ===== UPDATE STATUS MODAL ===== --%>
    <div class="modal fade" id="updateStatusModal" tabindex="-1" aria-labelledby="updateStatusModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow" style="border-radius: 14px;">
                <form method="post" action="${pageContext.request.contextPath}/services">
                    <input type="hidden" name="action"       value="updateStatus">
                    <input type="hidden" name="id"           id="modalUsageId">
                    <input type="hidden" name="statusFilter" id="modalStatusFilter">

                    <div class="modal-header border-bottom-0 pb-0">
                        <h5 class="modal-title fw-bold modal-theme-header" id="updateStatusModalLabel">
                            <i class="bi bi-pencil-square me-2 text-muted"></i>Update Request Status
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body pt-3">
                        <p class="text-muted small mb-3">
                            Select the new status for request <strong>#<span id="modalUsageIdDisplay" style="color: #0A4174;"></span></strong>.
                        </p>

                        <div class="mb-3">
                            <label class="form-label fw-semibold" style="color: #001D39;">New Status</label>
                            <select name="status" id="modalStatus" class="form-select border-secondary-subtle focus-ring-theme">
                                <option value="pending">⏳ Pending</option>
                                <option value="approved">✅ Approved</option>
                                <option value="rejected">❌ Rejected</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold" style="color: #001D39;">Quantity</label>
                            <input type="number" name="quantity" id="modalQty"
                                   class="form-control border-secondary-subtle focus-ring-theme" min="0.01" step="0.01"
                                   oninput="recalcEstCost()">
                        </div>

                        <div class="p-3 rounded-3 bg-theme-subtle">
                            <div class="small text-muted mb-1">Est. Cost</div>
                            <div class="fw-bold fs-5" style="color: #001D39;" id="modalEstCost">—</div>
                        </div>
                    </div>

                    <div class="modal-footer border-top-0 pt-0">
                        <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-theme-dark btn-sm px-3">
                            <i class="bi bi-save me-1"></i>Save Status
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        var _unitPrice = 0;

        function openStatusModal(usageId, currentStatus, statusFilter, qty, unitPrice) {
            _unitPrice = parseFloat(unitPrice) || 0;

            document.getElementById('modalUsageId').value             = usageId;
            document.getElementById('modalUsageIdDisplay').textContent = usageId;
            document.getElementById('modalStatus').value              = currentStatus;
            document.getElementById('modalStatusFilter').value        = statusFilter || '';
            document.getElementById('modalQty').value                 = qty;

            recalcEstCost();
        }

        function recalcEstCost() {
            var qty  = parseFloat(document.getElementById('modalQty').value) || 0;
            var cost = qty * _unitPrice;
            document.getElementById('modalEstCost').textContent =
                cost.toLocaleString('vi-VN') + '₫';
        }
    </script>

</t:layout>