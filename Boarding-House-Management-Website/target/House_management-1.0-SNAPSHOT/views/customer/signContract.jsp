<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Sign Contract - AKDD House</title>
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
            background-color: var(--ds-bg); 
            font-family: 'Pretendard', sans-serif !important;
            color: var(--ds-text);
            overflow-x: hidden;
        }

        /* ── Page Header ── */
        .page-header { 
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700)); 
            color: white; border-radius: 20px; padding: 32px 36px; margin-bottom: 24px; 
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-header h4 { font-weight: 800; font-size: 1.7rem; margin-bottom: 6px; }
        .page-header small { font-size: 1rem; opacity: 0.85; }

        /* ── Room Card (Step 1) ── */
        .room-card { 
            border-radius: 16px; border: 2px solid #e5e7eb; cursor: pointer; transition: all .2s ease; background: #fff;
        }
        .room-card:hover { 
            border-color: var(--ocean-400); transform: translateY(-4px); box-shadow: 0 12px 24px rgba(0, 119, 182, 0.1) !important; 
        }
        .room-card.selected { border-color: var(--ocean-600); background: #f0fbfc; }

        /* ── Form Card (Step 2) ── */
        .form-card { border-radius: 20px; border: none; box-shadow: 0 4px 24px rgba(0,0,0,.04); background: #fff; }
        
        .form-control, .form-select { border-radius: 10px; border: 1.5px solid #e5e7eb; padding: 10px 14px; font-size: .95rem; }
        .form-control:focus, .form-select:focus { 
            border-color: var(--ocean-500); box-shadow: 0 0 0 3px rgba(0, 180, 216, 0.15); 
        }
        .input-group-text { border-radius: 10px; border: 1.5px solid #e5e7eb; background: var(--ocean-100); color: var(--ocean-800); font-weight: 600; }

        /* ── Buttons ── */
        .btn-sign { 
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600)); 
            border: none; color: white; border-radius: 12px; transition: transform .2s, box-shadow .2s;
        }
        .btn-sign:hover { opacity: .95; color: white; transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 119, 182, 0.25); }
        .btn-outline-ocean {
            color: var(--ocean-700); border: 2px solid var(--ocean-300); border-radius: 12px; background: transparent; transition: all .2s;
        }
        .btn-outline-ocean:hover { background: var(--ocean-100); color: var(--ocean-900); border-color: var(--ocean-500); }

        /* ── Facilities ── */
        .facility-item { 
            border: 2px solid #e5e7eb; border-radius: 12px; padding: 12px 16px; transition: .2s ease; background: #fff;
        }
        .facility-item:hover { border-color: var(--ocean-300); }
        .facility-item:has(input:checked) { border-color: var(--ocean-600); background: #f0fbfc; box-shadow: 0 4px 12px rgba(0, 150, 199, 0.08); }
        .facility-item input[type="checkbox"] { accent-color: var(--ocean-700); width: 18px; height: 18px; cursor: pointer; }
        
        /* ── Rent Preview ── */
        .rent-preview { 
            background: linear-gradient(135deg, var(--ocean-100), #ffffff); border: 2px dashed var(--ocean-300);
            border-radius: 16px; padding: 20px; box-shadow: 0 4px 12px rgba(0, 150, 199, 0.05);
        }
    </style>
</head>
<body>
<%@ include file="../navbar.jsp" %>
<div class="container-fluid p-0">
  <div class="row g-0" style="min-height: calc(100vh - 56px);">
    <%@ include file="sidebar.jsp" %>
    <main class="col p-4 d-flex justify-content-center">
<div style="width: 100%; max-width:860px">

    <div class="page-header text-center text-md-start">
        <h4 class="fw-bold mb-2"><i class="bi bi-pen-fill me-2" style="color: var(--ocean-400);"></i>Sign a Rental Contract</h4>
        <small>Choose an available room and submit your lease request to the management</small>
    </div>

    <%-- Alerts --%>
    <c:if test="${not empty sessionScope.contractSuccess}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 rounded-4" style="background:#d1fae5; color:#065f46;">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.contractSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("contractSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.contractError}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 rounded-4" style="background:#fee2e2; color:#b91c1c;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.contractError}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% session.removeAttribute("contractError"); %>
    </c:if>

    <%-- Block if customer already has an active contract --%>
    <c:if test="${alreadyHasContract == true}">
        <div class="alert alert-warning d-flex align-items-center gap-3 rounded-4 shadow-sm border-0 p-4" style="background-color: #fef9c3; color: #a16207;">
            <i class="bi bi-exclamation-triangle-fill fs-3"></i>
            <div>
                <div class="fw-bold fs-5 mb-1">Contract Already Exists</div>
                You already have an active rental contract. 
                <a href="${pageContext.request.contextPath}/contract?action=mycontract" class="alert-link fw-bold text-decoration-none">
                    View your current contract
                </a>
                — please terminate it before signing a new one.
            </div>
        </div>
    </c:if>

    <c:choose>
        <%-- Step 2: Room selected, show contract form --%>
        <c:when test="${not empty room}">
            <div class="card form-card mb-5">
                <div class="card-body p-4 p-md-5">
                    
                    <%-- Room Header --%>
                    <div class="d-flex gap-3 align-items-center mb-4 pb-3 border-bottom" style="border-color: var(--ocean-100) !important;">
                        <div class="rounded-3 d-flex align-items-center justify-content-center" style="width:64px;height:64px;font-size:28px;flex-shrink:0; background: var(--ocean-100); color: var(--ocean-800);">
                            <i class="bi bi-door-open-fill"></i>
                        </div>
                        <div>
                            <h4 class="mb-1 fw-bold" style="color: var(--ocean-900);">Room ${room.roomNumber}</h4>
                            <div class="text-muted fw-medium">
                                ${room.categoryName} &middot; 
                                <span class="fw-bold" style="color: var(--ocean-600);"><fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/month</span>
                            </div>
                        </div>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill ms-auto px-4 py-2 fs-6 shadow-sm"><i class="bi bi-check-circle-fill me-1"></i>Available</span>
                    </div>

                    <form action="${pageContext.request.contextPath}/contract" method="post">
                        <input type="hidden" name="action"  value="customerSign">
                        <input type="hidden" name="roomId"  value="${room.roomId}">

                        <%-- Customer info (pre-filled, read-only) --%>
                        <div class="mb-4 p-4 rounded-4" style="background:#fafbfc; border:1px solid #e5e7eb;">
                            <div class="fw-bold mb-3" style="font-size:.9rem;text-transform:uppercase;letter-spacing:1px;color:var(--ocean-700);">
                                <i class="bi bi-person-badge-fill me-2"></i>Your Information
                            </div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-dark mb-1" style="font-size:.85rem;">Full Name</label>
                                    <input type="text" class="form-control bg-white" value="${sessionScope.user.fullName}" readonly style="cursor:not-allowed; color:#6b7280; border-color: transparent; box-shadow: 0 2px 8px rgba(0,0,0,0.03);">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-dark mb-1" style="font-size:.85rem;">Email</label>
                                    <input type="email" class="form-control bg-white" value="${sessionScope.user.email}" readonly style="cursor:not-allowed; color:#6b7280; border-color: transparent; box-shadow: 0 2px 8px rgba(0,0,0,0.03);">
                                </div>
                            </div>
                        </div>

                        <div class="row g-4">
                            <div class="col-md-6">
                                <label class="form-label fw-bold text-dark">Start Date <span class="text-danger">*</span></label>
                                <input type="date" name="startDate" class="form-control" required id="startDateInput">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold text-dark">Contract Duration</label>
                                <div class="input-group">
                                    <input type="number" name="durationMonths" id="durationMonthsSign"
                                           class="form-control" value="12" min="1" max="36" required>
                                    <span class="input-group-text">months</span>
                                </div>
                                <div class="form-text text-muted fw-medium"><i class="bi bi-info-circle me-1"></i>Default 12 months.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold text-dark">End Date (Auto-calculated)</label>
                                <input type="text" id="endDateDisplaySign" class="form-control" readonly style="background:#f9fafb;" placeholder="Auto from start date + duration">
                                <input type="hidden" name="endDate" id="endDateHiddenSign">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold text-dark">Deposit Amount (&#8363;) <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-cash-stack"></i></span>
                                    <input type="number" name="deposit" class="form-control fw-bold" style="color: var(--ocean-700);" value="${room.basePrice}" min="0" required>
                                </div>
                                <div class="form-text text-muted fw-medium">Equivalent to 1 month's rent by default.</div>
                            </div>
                        </div>

                        <%-- Facility selection --%>
                        <c:if test="${not empty facilities}">
                        <div class="mt-5">
                            <h6 class="fw-bold mb-3" style="color: var(--ocean-900);">
                                <i class="bi bi-stars me-2" style="color: var(--ocean-500);"></i>Optional Add-ons
                                <span class="text-muted fw-normal" style="font-size:.85rem;">(Select if needed)</span>
                            </h6>
                            <div class="d-flex flex-column gap-2 mb-4" id="facilityList">
                                <c:forEach var="f" items="${facilities}">
                                    <div class="facility-item d-flex align-items-center justify-content-between flex-wrap gap-2">
                                        <div class="form-check mb-0 d-flex align-items-center gap-3">
                                            <input class="form-check-input facility-cb" type="checkbox"
                                                   name="facilityId" value="${f.facilityId}"
                                                   id="fac_${f.facilityId}"
                                                   data-price="${f.monthlyPrice != null ? f.monthlyPrice : 0}">
                                            <label class="form-check-label fw-bold text-dark" for="fac_${f.facilityId}" style="cursor:pointer; font-size: 1rem;">
                                                ${f.facilityName}
                                                <c:if test="${f.monthlyPrice != null and f.monthlyPrice > 0}">
                                                    <span class="ms-2 badge rounded-pill" style="background: var(--ocean-100); color: var(--ocean-800); font-size: .8rem;">
                                                        +<fmt:formatNumber value="${f.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/mo
                                                    </span>
                                                </c:if>
                                            </label>
                                        </div>
                                        <div class="d-flex align-items-center gap-2 qty-wrap"
                                             id="qty_wrap_${f.facilityId}" style="visibility:hidden;">
                                            <label class="text-muted fw-semibold small mb-0">Qty:</label>
                                            <input type="number" name="facilityQty"
                                                   id="fac_qty_${f.facilityId}"
                                                   class="form-control form-control-sm facility-qty fw-bold text-center"
                                                   value="1" min="1" max="5"
                                                   data-fac-id="${f.facilityId}"
                                                   style="width:60px;" disabled>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <%-- Live rent preview --%>
                            <div class="rent-preview">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <span class="fw-bold" style="color: var(--ocean-900); font-size: 1.1rem;">
                                        <i class="bi bi-calculator me-2" style="color: var(--ocean-500);"></i>Estimated rent / month
                                    </span>
                                    <span class="fw-bold fs-4" style="color: var(--ocean-700);" id="rentPreview">
                                        <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/> ₫
                                    </span>
                                </div>
                                <div class="text-muted mt-2 fw-medium" style="font-size:.85rem; line-height: 1.5;" id="rentBreakdown">
                                    Room rent: <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/> ₫
                                </div>
                            </div>
                        </div>
                        </c:if>

                        <div class="mt-5 d-flex flex-column flex-sm-row gap-3">
                            <button type="submit" class="btn btn-sign flex-fill py-3 fs-6">
                                <i class="bi bi-pen-fill me-2"></i>Confirm &amp; Sign Contract
                            </button>
                            <a href="${pageContext.request.contextPath}/contract?action=signContract" class="btn btn-outline-ocean flex-fill py-3 fs-6 text-center">
                                <i class="bi bi-arrow-left me-2"></i>Choose Another Room
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
                            <i class="bi bi-door-closed-fill d-block mb-3" style="font-size:64px; color: var(--ocean-200);"></i>
                            <h4 class="mb-2 fw-bold" style="color: var(--ocean-900);">No rooms available</h4>
                            <p class="text-muted mb-4">All rooms are currently occupied or under maintenance. Please check back later.</p>
                            <a href="${pageContext.request.contextPath}/room?action=publicList" class="btn btn-sign px-4 py-2">
                                <i class="bi bi-grid-fill me-2"></i>Browse All Rooms
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <h5 class="fw-bold mb-4" style="color: var(--ocean-900);"><i class="bi bi-cursor-fill me-2" style="color: var(--ocean-500);"></i>Step 1: Select a room to proceed</h5>
                    <div class="row g-4">
                        <c:forEach var="r" items="${availableRooms}">
                            <div class="col-md-6 col-lg-6">
                                <a href="${pageContext.request.contextPath}/contract?action=signContract&roomId=${r.roomId}"
                                   class="text-decoration-none">
                                    <div class="card room-card p-4 h-100">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div>
                                                <div class="fw-bold fs-4" style="color: var(--ocean-900);">Room ${r.roomNumber}</div>
                                                <div class="text-muted fw-medium mt-1"><i class="bi bi-tag-fill me-1" style="color: var(--ocean-300);"></i>${r.categoryName}</div>
                                            </div>
                                            <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px; background: var(--ocean-100); color: var(--ocean-700);">
                                                <i class="bi bi-arrow-right fs-5"></i>
                                            </div>
                                        </div>
                                        <div class="mt-auto d-flex align-items-center justify-content-between pt-3 border-top" style="border-color: var(--ocean-100) !important;">
                                            <span class="fw-bold fs-5" style="color: var(--ocean-700);">
                                                <fmt:formatNumber value="${r.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;<span class="text-muted fw-medium small">/mo</span>
                                            </span>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1 fw-bold">Available</span>
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
        return n.toLocaleString('vi-VN') + ' ₫';
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
                    var label = cb.closest('.facility-item').querySelector('.form-check-label');
                    // Clean up the textcontent to just get the name without the price span
                    var nameText = label ? label.childNodes[0].textContent.trim() : 'Amenity';
                    lines.push(nameText
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