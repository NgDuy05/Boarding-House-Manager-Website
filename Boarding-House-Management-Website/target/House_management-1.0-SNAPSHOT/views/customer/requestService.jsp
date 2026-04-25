<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Request Service - AKDD House</title>
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

        /* ── Hero ── */
        .page-hero {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            color: #fff; padding: 48px 0 56px; margin-bottom: -28px;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .page-hero h1 { font-weight: 800; font-size: 2rem; letter-spacing: -0.5px; }
        .page-hero p { font-size: 1.05rem; }

        /* ── Form Card ── */
        .form-card {
            border: none; border-radius: 20px;
            box-shadow: 0 8px 30px rgba(0,0,0,.06);
            background: #fff;
        }
        .form-card .card-header {
            background: transparent; border-bottom: 1px dashed var(--ocean-200);
            padding: 1.6rem 2rem 1.2rem;
        }

        /* ── Service Options ── */
        .svc-option {
            border: 2px solid #e2e8f0; border-radius: 16px;
            padding: 16px 20px; cursor: pointer;
            transition: all .2s ease;
            display: flex; align-items: center; gap: 16px;
            margin-bottom: 12px;
            background-color: #ffffff;
        }
        .svc-option:hover { 
            border-color: var(--ocean-400); 
            background: var(--ocean-100); 
        }
        .svc-option input[type="checkbox"] { 
            accent-color: var(--ocean-700); 
            width: 20px; height: 20px; 
        }
        .svc-option.selected { 
            border-color: var(--ocean-600); 
            background: #f0fbfc; 
            box-shadow: 0 4px 12px rgba(0, 150, 199, 0.08); 
        }
        
        .svc-icon {
            width: 48px; height: 48px; border-radius: 12px;
            background: var(--ocean-100); color: var(--ocean-800);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem; flex-shrink: 0;
        }
        .svc-label { font-weight: 700; color: var(--ocean-900); font-size: 1.05rem; margin-bottom: 2px; }
        .svc-desc  { font-size: .85rem; color: #5A5C63; }

        /* ── Badges & Steps ── */
        .contract-badge {
            background: #d1fae5; color: #065f46;
            border-radius: 50px; padding: 8px 18px;
            font-size: .85rem; font-weight: 700;
            display: inline-flex; align-items: center; gap: .4rem;
            box-shadow: 0 4px 10px rgba(6, 95, 70, 0.1);
        }
        .no-contract {
            background: #fee2e2; color: #991b1b;
            border-radius: 16px; padding: 16px 20px;
            display: flex; align-items: center; gap: 12px;
            box-shadow: 0 4px 10px rgba(153, 27, 27, 0.1);
        }
        .step-number {
            width: 32px; height: 32px; border-radius: 50%;
            background: var(--ocean-700); color: #fff;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: .9rem; font-weight: 800; flex-shrink: 0;
        }

        /* ── Buttons ── */
        .btn-submit-ocean {
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600));
            color: white; border: none; font-weight: 700; border-radius: 12px;
            transition: transform 0.2s, box-shadow 0.2s;
            font-size: 1.05rem;
        }
        .btn-submit-ocean:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 119, 182, 0.25);
            color: white;
        }
        .btn-outline-ocean {
            color: var(--ocean-700); border-color: var(--ocean-300); border-radius: 12px; font-weight: 600;
            font-size: 1.05rem;
        }
        .btn-outline-ocean:hover {
            background: var(--ocean-100); color: var(--ocean-900); border-color: var(--ocean-500);
        }
        
        .form-control-lg { border-radius: 12px; font-size: 0.95rem; border: 1.5px solid #e2e8f0; }
        .form-control-lg:focus { border-color: var(--ocean-500); box-shadow: 0 0 0 3px rgba(0, 180, 216, 0.15); }
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
                    <li class="breadcrumb-item active text-white fw-semibold">Request Service</li>
                </ol>
            </nav>
            <h1><i class="bi bi-send-fill me-2"></i>Request a Service</h1>
            <p class="mb-0 opacity-85">Submit a service request — our staff will review and approve it shortly</p>
        </div>
    </div>

    <div class="container pb-5" style="padding-top: 48px;">
        <div class="row justify-content-center">
            <div class="col-lg-8">

                <%-- Alert: URL param errors --%>
                <c:if test="${param.error == 'nocontract'}">
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-4 shadow-sm border-0 rounded-4">
                        <i class="bi bi-exclamation-circle-fill fs-5"></i>
                        <span>You do not have an active rental contract. Please contact the manager.</span>
                    </div>
                </c:if>
                <c:if test="${param.error == 'failed'}">
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-4 shadow-sm border-0 rounded-4">
                        <i class="bi bi-x-circle-fill fs-5"></i>
                        <span>Request submission failed. Please try again.</span>
                    </div>
                </c:if>
                <c:if test="${param.error == 'noservice'}">
                    <div class="alert alert-warning d-flex align-items-center gap-2 mb-4 shadow-sm border-0 rounded-4">
                        <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                        <span>Please select at least one service.</span>
                    </div>
                </c:if>
                <c:if test="${param.success == 'requested'}">
                    <div class="alert alert-success d-flex align-items-center gap-2 mb-4 shadow-sm border-0 rounded-4" style="background:#d1fae5; color:#065f46;">
                        <i class="bi bi-check-circle-fill fs-5"></i>
                        <span>Your request has been submitted successfully! We will review and respond shortly.</span>
                    </div>
                </c:if>

                <%-- No contract error --%>
                <c:if test="${not empty errorMsg}">
                    <div class="no-contract mb-4">
                        <i class="bi bi-exclamation-triangle-fill text-danger fs-3"></i>
                        <div>
                            <div class="fw-bold fs-5 mb-1">Cannot place service request</div>
                            <div class="text-danger opacity-75">${errorMsg}</div>
                        </div>
                    </div>
                </c:if>

                <c:if test="${empty errorMsg}">

                    <%-- Contract info --%>
                    <div class="d-flex align-items-center gap-3 mb-4">
                        <span class="contract-badge">
                            <i class="bi bi-file-earmark-check-fill fs-6"></i>
                            Contract #${contractId} — Active
                        </span>
                    </div>

                    <%-- Form --%>
                    <div class="form-card">
                        <div class="card-header">
                            <h5 class="fw-bold mb-0" style="color: var(--ocean-900);">
                                <i class="bi bi-send-fill me-2" style="color: var(--ocean-500);"></i>Fill in Request Details
                            </h5>
                        </div>
                        <div class="p-4 p-md-5">
                            <form method="post" action="${pageContext.request.contextPath}/services">
                                <input type="hidden" name="action" value="submitRequest">

                                <%-- Step 1: Choose service --%>
                                <div class="d-flex align-items-center gap-3 mb-4">
                                    <span class="step-number">1</span>
                                    <h5 class="fw-bold mb-0 text-dark">Select Services <span class="text-danger">*</span></h5>
                                </div>

                                <div class="mb-5">
                                    <c:forEach var="svc" items="${services}">
                                        <label class="svc-option w-100" id="label_${svc.serviceId}">
                                            <input type="checkbox" name="serviceIds"
                                                   value="${svc.serviceId}"
                                                   onchange="updateSelected(this)"
                                                   ${param.serviceId == svc.serviceId ? 'checked' : ''}>
                                            <div class="svc-icon">
                                                <i class="bi bi-lightning-charge-fill"></i>
                                            </div>
                                            <div>
                                                <div class="svc-label">${svc.serviceName}</div>
                                                <div class="svc-desc">
                                                    <c:choose>
                                                        <c:when test="${not empty svc.description}">${svc.description}</c:when>
                                                        <c:otherwise>Standard utility service</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </label>
                                    </c:forEach>
                                </div>

                                <%-- Step 2: Quantity & Date --%>
                                <div class="d-flex align-items-center gap-3 mb-4">
                                    <span class="step-number">2</span>
                                    <h5 class="fw-bold mb-0 text-dark">Quantity &amp; Start Date</h5>
                                </div>

                                <div class="row g-4 mb-5">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold text-dark mb-2">Quantity</label>
                                        <input type="number" name="quantity" class="form-control form-control-lg"
                                               value="1" min="1" step="1" required>
                                        <div class="form-text mt-2"><i class="bi bi-info-circle me-1"></i>Enter the usage quantity (default: 1 month)</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold text-dark mb-2">Start Date</label>
                                        <input type="date" name="usageDate" class="form-control form-control-lg"
                                               id="usageDateInput" required>
                                    </div>
                                </div>

                                <%-- Step 3: Submit --%>
                                <div class="d-flex align-items-center gap-3 mb-4">
                                    <span class="step-number">3</span>
                                    <h5 class="fw-bold mb-0 text-dark">Confirm &amp; Submit</h5>
                                </div>

                                <div class="alert mb-4 rounded-4 p-3" style="background-color: var(--ocean-100); border: 1px dashed var(--ocean-400);">
                                    <div class="d-flex gap-3 align-items-start">
                                        <i class="bi bi-info-circle-fill mt-1" style="color: var(--ocean-800); font-size: 1.2rem;"></i>
                                        <div class="small" style="color: var(--ocean-900); font-weight: 500; line-height: 1.5;">
                                            Your request will be sent to the admin for approval. Once approved, the service cost
                                            will be automatically added to your next monthly bill.
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex flex-column flex-sm-row gap-3 mt-4">
                                    <button type="submit" class="btn btn-submit-ocean btn-lg flex-grow-1 px-4 py-3">
                                        <i class="bi bi-send-fill me-2"></i>Submit Request
                                    </button>
                                    <a href="${pageContext.request.contextPath}/services"
                                       class="btn btn-outline-ocean btn-lg px-5 py-3 text-center">
                                        Cancel
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>

                </c:if>

            </div>

            <%-- Sidebar: Notes (Visible on large screens) --%>
            <div class="col-lg-4 d-none d-lg-block">
                <div class="form-card p-4 sticky-top" style="top: 24px;">
                    <h5 class="fw-bold mb-4" style="color: var(--ocean-900);">
                        <i class="bi bi-lightbulb-fill me-2" style="color: var(--ocean-500);"></i>Important Notes
                    </h5>
                    <ul class="list-unstyled small" style="color: #5A5C63; line-height: 1.7;">
                        <li class="mb-3 d-flex gap-2">
                            <i class="bi bi-check-circle-fill text-success"></i>
                            <span>Requests must be approved by admin before taking effect.</span>
                        </li>
                        <li class="mb-3 d-flex gap-2">
                            <i class="bi bi-check-circle-fill text-success"></i>
                            <span>Cost is calculated based on the current unit price of the service.</span>
                        </li>
                        <li class="mb-3 d-flex gap-2">
                            <i class="bi bi-check-circle-fill text-success"></i>
                            <span>Track request status under "My Service History".</span>
                        </li>
                        <li class="mb-3 d-flex gap-2">
                            <i class="bi bi-clock-fill text-warning"></i>
                            <span>Approval typically takes within 1 business day.</span>
                        </li>
                    </ul>
                    <hr style="border-color: var(--ocean-200); margin: 24px 0;">
                    <a href="${pageContext.request.contextPath}/services?action=myHistory"
                       class="btn btn-outline-ocean btn-sm w-100 py-2">
                        <i class="bi bi-clock-history me-2"></i>View My History
                    </a>
                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set default date to today
        document.getElementById('usageDateInput').valueAsDate = new Date();

        // Highlight selected service option
        function updateSelected(cb) {
            if (cb.checked) {
                cb.closest('.svc-option').classList.add('selected');
            } else {
                cb.closest('.svc-option').classList.remove('selected');
            }
        }

        // Pre-highlight on load
        document.querySelectorAll('input[name="serviceIds"]:checked').forEach(function(cb) {
            cb.closest('.svc-option').classList.add('selected');
        });

        // Form validation: ensure at least one service selected
        document.querySelector('form').addEventListener('submit', function(e) {
            var checked = document.querySelectorAll('input[name="serviceIds"]:checked');
            if (checked.length === 0) {
                e.preventDefault();
                alert('Please select at least one service before submitting.');
            }
        });
    </script>
        </main>
      </div>
    </div>
</body>
</html>