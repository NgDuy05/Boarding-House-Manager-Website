<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sign Contract - AKDD House</title>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background-color:#f4f6f9; }
        .page-header { background:linear-gradient(135deg,#0f3460,#16213e); color:white; border-radius:14px; padding:22px 28px; margin-bottom:24px; }
        .room-card { border-radius:12px; border:2px solid #dee2e6; cursor:pointer; transition:.2s; }
        .room-card:hover { border-color:#0f3460; transform:translateY(-2px); box-shadow:0 4px 16px rgba(0,0,0,.08)!important; }
        .room-card.selected { border-color:#0f3460; background:#f0f4ff; }
        .form-card { border-radius:14px; border:none; }
        .form-control:focus,.form-select:focus { border-color:#0f3460; box-shadow:0 0 0 .2rem rgba(15,52,96,.2); }
        .btn-sign { background:linear-gradient(135deg,#0f3460,#1a1a2e); border:none; color:white; }
        .btn-sign:hover { opacity:.9; color:white; }
        .facility-item { border:1.5px solid #e9ecef; border-radius:10px; padding:.6rem .9rem; transition:.15s; }
        .facility-item:has(input:checked) { border-color:#0f3460; background:#f0f4ff; }
        .rent-preview { background:linear-gradient(135deg,#f0f7ff,#e8f4fd); border:1px solid #bee3f8;
                        border-radius:10px; padding:.85rem 1.1rem; }
    </style>
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4">
<div style="max-width:800px">

    <div class="page-header">
        <h4 class="fw-bold mb-1"><i class="bi bi-pen me-2"></i>Sign a Rental Contract</h4>
        <small class="opacity-75">Choose an available room and submit your request</small>
    </div>

    <c:if test="${not empty sessionScope.contractSuccess}">
        <div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i>${sessionScope.contractSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% session.removeAttribute("contractSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.contractError}">
        <div class="alert alert-danger alert-dismissible fade show"><i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.contractError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% session.removeAttribute("contractError"); %>
    </c:if>

    <%-- Block if customer already has an active contract --%>
    <c:if test="${alreadyHasContract == true}">
        <div class="alert alert-warning d-flex align-items-center gap-2 rounded-3">
            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
            <div>
                You already have an active rental contract.
                <a href="${pageContext.request.contextPath}/contract?action=mycontract" class="alert-link fw-semibold">
                    View your current contract
                </a>
                — please terminate it before signing a new one.
            </div>
        </div>
    </c:if>

    <c:choose>
        <%-- Step 2: Room selected, show contract form --%>
        <c:when test="${not empty room}">
            <div class="card form-card shadow-sm mb-4">
                <div class="card-body p-4">
                    <div class="d-flex gap-3 align-items-center mb-4">
                        <div class="rounded-2 bg-primary-subtle text-primary d-flex align-items-center justify-content-center" style="width:56px;height:56px;font-size:22px;flex-shrink:0">
                            <i class="bi bi-door-open"></i>
                        </div>
                        <div>
                            <h5 class="mb-0 fw-bold">Room ${room.roomNumber}</h5>
                            <div class="text-muted">${room.categoryName} &middot; <span class="text-success fw-semibold"><fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/month</span></div>
                        </div>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill ms-auto px-3">Available</span>
                    </div>

                    <form action="${pageContext.request.contextPath}/contract" method="post">
                        <input type="hidden" name="action"  value="customerSign">
                        <input type="hidden" name="roomId"  value="${room.roomId}">

                        <%-- Customer info (pre-filled, read-only) --%>
                        <div class="mb-4 p-3 rounded-3" style="background:#f8f9fa;border:1px solid #e9ecef;">
                            <div class="fw-semibold mb-2 text-muted" style="font-size:.8rem;text-transform:uppercase;letter-spacing:.5px;">
                                <i class="bi bi-person-fill me-1"></i>Your Information
                            </div>
                            <div class="row g-2">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold mb-1" style="font-size:.85rem;">Full Name</label>
                                    <input type="text" class="form-control form-control-sm" value="${sessionScope.user.fullName}" readonly
                                           style="background:#fff;cursor:default;color:#495057;">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold mb-1" style="font-size:.85rem;">Email</label>
                                    <input type="email" class="form-control form-control-sm" value="${sessionScope.user.email}" readonly
                                           style="background:#fff;cursor:default;color:#495057;">
                                </div>
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Start Date <span class="text-danger">*</span></label>
                                <input type="date" name="startDate" class="form-control" required id="startDateInput">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Contract Duration</label>
                                <div class="input-group">
                                    <input type="number" name="durationMonths" id="durationMonthsSign"
                                           class="form-control" value="12" min="1" max="36" required>
                                    <span class="input-group-text">months</span>
                                </div>
                                <div class="form-text text-muted">Default 12 months. End date is auto-calculated.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">End Date (auto-calculated)</label>
                                <input type="text" id="endDateDisplaySign" class="form-control" readonly placeholder="Auto from start date + duration">
                                <input type="hidden" name="endDate" id="endDateHiddenSign">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Deposit Amount (&#8363;) <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-cash"></i></span>
                                    <input type="number" name="deposit" class="form-control" value="${room.basePrice}" min="0" required>
                                </div>
                                <div class="form-text">Usually equivalent to 1–2 months' rent</div>
                            </div>
                        </div>

                        <%-- Facility selection --%>
                        <c:if test="${not empty facilities}">
                        <div class="mt-4">
                            <h6 class="fw-semibold mb-2">
                                <i class="bi bi-stars me-1 text-primary"></i>Optional Add-ons
                                <span class="text-muted fw-normal" style="font-size:.82rem;">(optional)</span>
                            </h6>
                            <div class="d-flex flex-column gap-2 mb-3" id="facilityList">
                                <c:forEach var="f" items="${facilities}">
                                    <div class="facility-item d-flex align-items-center gap-3">
                                        <div class="form-check mb-0 d-flex align-items-center gap-2 flex-grow-1">
                                            <input class="form-check-input facility-cb" type="checkbox"
                                                   name="facilityId" value="${f.facilityId}"
                                                   id="fac_${f.facilityId}"
                                                   data-price="${f.monthlyPrice != null ? f.monthlyPrice : 0}"
                                                   style="width:18px;height:18px;">
                                            <label class="form-check-label fw-semibold" for="fac_${f.facilityId}" style="cursor:pointer;">
                                                ${f.facilityName}
                                            </label>
                                            <c:if test="${f.monthlyPrice != null and f.monthlyPrice > 0}">
                                                <span class="text-success small ms-1">
                                                    +<fmt:formatNumber value="${f.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/mo
                                                </span>
                                            </c:if>
                                        </div>
                                        <div class="d-flex align-items-center gap-1 qty-wrap"
                                             id="qty_wrap_${f.facilityId}" style="visibility:hidden;">
                                            <label class="text-muted" style="font-size:.8rem;white-space:nowrap;">Qty:</label>
                                            <input type="number" name="facilityQty"
                                                   id="fac_qty_${f.facilityId}"
                                                   class="form-control form-control-sm facility-qty"
                                                   value="1" min="1" max="5"
                                                   data-fac-id="${f.facilityId}"
                                                   style="width:64px;" disabled>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                            <%-- Live rent preview --%>
                            <div class="rent-preview">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="fw-semibold text-primary">
                                        <i class="bi bi-calculator me-1"></i>Estimated rent / month
                                    </span>
                                    <span class="fw-bold text-primary fs-5" id="rentPreview">
                                        <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                    </span>
                                </div>
                                <div class="text-muted mt-1" style="font-size:.8rem;" id="rentBreakdown">
                                    Room rent: <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                </div>
                            </div>
                        </div>
                        </c:if>

                        <div class="mt-4 d-flex gap-2">
                            <button type="submit" class="btn btn-sign flex-fill fw-semibold py-2">
                                <i class="bi bi-pen me-1"></i>Confirm &amp; Sign Contract
                            </button>
                            <a href="${pageContext.request.contextPath}/contract?action=signContract" class="btn btn-outline-secondary flex-fill fw-semibold py-2">
                                <i class="bi bi-arrow-left me-1"></i>Choose Another Room
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </c:when>

        <%-- Step 1: Select a room --%>
        <c:otherwise>
            <c:choose>
                <c:when test="${empty availableRooms}">
                    <div class="card form-card shadow-sm">
                        <div class="card-body text-center py-5">
                            <i class="bi bi-door-closed text-muted" style="font-size:56px"></i>
                            <h5 class="mt-3 mb-1 fw-semibold">No rooms available</h5>
                            <p class="text-muted">All rooms are currently occupied. Please check back later.</p>
                            <a href="${pageContext.request.contextPath}/customer-room" class="btn btn-outline-dark">
                                <i class="bi bi-arrow-left me-1"></i>Browse All Rooms
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <h6 class="fw-semibold mb-3 text-muted"><i class="bi bi-cursor me-1"></i>Select a room to proceed</h6>
                    <div class="row g-3">
                        <c:forEach var="r" items="${availableRooms}">
                            <div class="col-md-6 col-lg-4">
                                <a href="${pageContext.request.contextPath}/contract?action=signContract&roomId=${r.roomId}"
                                   class="text-decoration-none">
                                    <div class="card room-card shadow-sm p-3 h-100">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <div class="fw-bold fs-5">Room ${r.roomNumber}</div>
                                                <div class="text-muted small mt-1">${r.categoryName}</div>
                                            </div>
                                            <i class="bi bi-arrow-right-circle text-primary opacity-50 fs-5"></i>
                                        </div>
                                        <div class="mt-3 d-flex align-items-center justify-content-between">
                                            <span class="text-success fw-bold"><fmt:formatNumber value="${r.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;<span class="text-muted fw-normal small">/month</span></span>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill small">Available</span>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:otherwise>
    </c:choose>
</div>
    </main>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var startInput = document.getElementById('startDateInput');
    if (startInput) {
        startInput.value = new Date().toISOString().substring(0, 10);

        // Auto-compute end date
        function computeEndDate() {
            var start = startInput.value;
            var months = parseInt(document.getElementById('durationMonthsSign').value) || 12;
            if (!start) return;
            var d = new Date(start);
            d.setMonth(d.getMonth() + months);
            d.setDate(d.getDate() - 1);
            var iso = d.toISOString().slice(0, 10);
            document.getElementById('endDateDisplaySign').value = iso;
            document.getElementById('endDateHiddenSign').value = iso;
        }

        startInput.addEventListener('change', computeEndDate);
        document.getElementById('durationMonthsSign').addEventListener('input', computeEndDate);
        // Compute immediately after setting today's date
        computeEndDate();
    }

    // Phone validation on submit
    var form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function(e) {
            var phoneInputs = document.querySelectorAll('input[name="phone"]');
            phoneInputs.forEach(function(input) {
                if (input.value && !/^(0[35789])\d{8}$/.test(input.value)) {
                    e.preventDefault();
                    input.classList.add('is-invalid');
                    var fb = input.parentNode.querySelector('.invalid-feedback');
                    if (!fb) {
                        fb = document.createElement('div');
                        fb.className = 'invalid-feedback';
                        input.parentNode.appendChild(fb);
                    }
                    fb.textContent = 'Invalid phone number (e.g. 0912345678)';
                }
            });
        });
        document.querySelectorAll('input[name="phone"]').forEach(function(input) {
            input.addEventListener('input', function() { input.classList.remove('is-invalid'); });
        });
    }
});
</script>
<script>
// ===== Facility checkbox: show/hide qty + live rent preview =====
(function() {
    var BASE_PRICE = parseFloat('${room.basePrice}') || 0;

    function formatVnd(n) {
        return n.toLocaleString('vi-VN') + '&#8363;';
    }

    function updatePreview() {
        var cbs  = document.querySelectorAll('.facility-cb');
        var total = BASE_PRICE;
        var lines = ['Room rent: ' + formatVnd(BASE_PRICE)];

        cbs.forEach(function(cb) {
            var facId  = cb.value;
            var price  = parseFloat(cb.dataset.price) || 0;
            var qtyEl  = document.getElementById('fac_qty_' + facId);
            var qty    = qtyEl ? (parseInt(qtyEl.value) || 1) : 1;
            var wrap   = document.getElementById('qty_wrap_' + facId);

            if (cb.checked) {
                total += price * qty;
                if (price > 0) {
                    var label = cb.closest('.form-check').querySelector('label');
                    lines.push((label ? label.textContent.trim() : 'Amenity')
                               + (qty > 1 ? ' x' + qty : '')
                               + ': +' + formatVnd(price * qty));
                }
                if (wrap) wrap.style.visibility = 'visible';
                if (qtyEl) qtyEl.disabled = false;
            } else {
                if (wrap) wrap.style.visibility = 'hidden';
                if (qtyEl) { qtyEl.disabled = true; qtyEl.value = 1; }
            }
        });

        var preview   = document.getElementById('rentPreview');
        var breakdown = document.getElementById('rentBreakdown');
        if (preview)   preview.innerHTML   = formatVnd(total);
        if (breakdown) breakdown.textContent = lines.join(' + ');
    }

    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.facility-cb').forEach(function(cb) {
            cb.addEventListener('change', updatePreview);
        });
        document.querySelectorAll('.facility-qty').forEach(function(inp) {
            inp.addEventListener('input', updatePreview);
        });
        updatePreview();
    });
})();
</script>
</body>
</html>
