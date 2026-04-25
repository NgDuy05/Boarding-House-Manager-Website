<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Room ${room.roomNumber} - AKDD House</title>
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
            background-color: var(--ds-bg);
            font-family: 'Pretendard', sans-serif !important;
            color: var(--ds-text);
            overflow-x: hidden;
        }

        /* ── Room details section ── */
        .room-details {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 4px 24px rgba(0,0,0,.04);
            padding: 32px;
            margin-bottom: 24px;
        }
        .view-img {
            border-radius: 16px;
            object-fit: cover;
            height: 320px;
            width: 100%;
            background: #f3f4f6;
            box-shadow: 0 4px 16px rgba(0,0,0,.06);
        }
        .view-img-placeholder {
            height: 320px;
            border-radius: 16px;
            background: linear-gradient(135deg, var(--ocean-100), var(--ocean-200));
            display: flex; align-items: center; justify-content: center;
            flex-direction: column; gap: .5rem; color: var(--ocean-600);
            box-shadow: 0 4px 16px rgba(0,0,0,.06);
        }
        .view-img-placeholder i { font-size: 4rem; }

        /* Title & description */
        .view-title {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--ocean-900);
        }
        .view-des {
            color: #5A5C63;
            font-size: 1rem;
            line-height: 1.7;
            margin: 12px 0 20px;
        }

        /* Stats boxes */
        .stats-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 24px; }
        .stat-box {
            text-align: center;
            min-width: 90px;
            background: var(--ds-bg);
            padding: 12px;
            border-radius: 12px;
            border: 1px solid var(--ocean-100);
        }
        .stat-box .num {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--ocean-700);
            display: block;
            line-height: 1;
        }
        .stat-box .num-text {
            font-size: .8rem;
            color: #6b7280;
            font-weight: 600;
            display: block;
            margin-top: 6px;
            text-transform: uppercase;
        }

        /* Status badge */
        .status-pill {
            display: inline-flex; align-items: center; border-radius: 50px;
            padding: 6px 16px; font-weight: 800;
            font-size: .8rem; text-transform: uppercase; letter-spacing: .5px;
        }
        .s-available   { background:#d1fae5; color:#059669; border: 1px solid #a7f3d0;}
        .s-occupied    { background:#fee2e2; color:#dc2626; border: 1px solid #fecaca;}
        .s-maintenance { background:#fef9c3; color:#d97706; border: 1px solid #fef08a;}

        /* Category tag */
        .category-tag {
            display: inline-flex; align-items: center;
            background: var(--ocean-100); color: var(--ocean-800);
            border-radius: 8px; padding: 4px 12px;
            font-size: .85rem; font-weight: 700;
        }

        /* Action buttons */
        .view-btn { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 12px; }
        .btn-book-now {
            background: linear-gradient(135deg, var(--ocean-700), var(--ocean-500)); 
            color: #fff; border: none; border-radius: 12px;
            padding: 12px 28px; font-size: 1rem; font-weight: 700;
            text-decoration: none; display: inline-flex; align-items: center; gap: .5rem;
            transition: transform .2s, box-shadow .2s;
            box-shadow: 0 4px 12px rgba(0, 119, 182, 0.2);
        }
        .btn-book-now:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0, 119, 182, 0.3); color: #fff; }
        .btn-contact {
            color: var(--ocean-700); border: 2px solid var(--ocean-500);
            border-radius: 12px;
            padding: 10px 28px; font-size: 1rem; font-weight: 700;
            text-decoration: none; display: inline-flex; align-items: center; gap: .5rem;
            background: transparent; transition: all .2s;
        }
        .btn-contact:hover { background: var(--ocean-100); color: var(--ocean-900); border-color: var(--ocean-600); }
        .btn-book-now.disabled {
            background: #e5e7eb !important; color: #9ca3af !important; pointer-events: none; box-shadow: none;
        }

        /* ── Image gallery ── */
        .gallery { background: #fff; border-radius: 20px; box-shadow: 0 4px 24px rgba(0,0,0,.04); padding: 28px; margin-bottom: 24px; }
        .img-gallery-grid { display: flex; gap: 12px; flex-wrap: wrap; }
        .img-thumb {
            width: calc(16.6% - 10px); min-width: 90px; aspect-ratio: 1;
            object-fit: cover; border-radius: 12px; cursor: pointer;
            border: 3px solid transparent; transition: border-color .2s, transform .2s;
        }
        .img-thumb:hover, .img-thumb.active {
            border-color: var(--ocean-500); transform: scale(1.05); box-shadow: 0 4px 12px rgba(0, 180, 216, 0.2);
        }
        @media (max-width: 576px) { .img-thumb { width: calc(33.3% - 8px); } }

        /* ── Info card / amenities ── */
        .info-card {
            background: #fff; border-radius: 20px; border: none;
            box-shadow: 0 4px 24px rgba(0,0,0,.04); padding: 1.8rem; margin-bottom: 24px;
        }
        .section-title {
            font-weight: 800; font-size: 1.1rem; color: var(--ocean-900);
            display: flex; align-items: center; gap: .5rem;
            margin-bottom: 1.4rem; padding-bottom: .8rem;
            border-bottom: 2px dashed var(--ocean-200);
        }
        .section-title i { color: var(--ocean-600); font-size: 1.3rem; }

        .info-row {
            display: flex; align-items: center;
            padding: 12px 0; border-bottom: 1px solid #f0f4f8; font-size: .95rem;
        }
        .info-row:last-child { border-bottom: none; }
        .info-key { width: 140px; flex-shrink: 0; color: #6b7280; font-weight: 600; font-size: .85rem; text-transform: uppercase; letter-spacing: .4px; }
        .info-val { color: var(--ocean-900); font-weight: 700; }

        /* Amenity cards */
        .amenity-card {
            border-radius: 14px; border: 1.5px solid #e5e7eb; padding: 1rem;
            display: flex; align-items: flex-start; gap: 1rem;
            transition: border-color .2s, box-shadow .2s, transform .2s; background: #fff; height: 100%;
        }
        .amenity-card:hover { border-color: var(--ocean-400); box-shadow: 0 4px 16px rgba(0, 119, 182, 0.08); transform: translateY(-2px); }
        .amenity-icon-wrap {
            width: 54px; height: 54px; flex-shrink: 0;
            background: var(--ocean-100); border-radius: 12px;
            display: flex; align-items: center; justify-content: center; overflow: hidden;
            color: var(--ocean-700);
        }
        .amenity-icon-wrap img { width: 54px; height: 54px; object-fit: cover; border-radius: 12px; }
        .amenity-name { font-weight: 800; font-size: .95rem; color: var(--ocean-900); margin-bottom: 2px; }
        .amenity-desc { font-size: .8rem; color: #6b7280; margin-top: 2px; line-height: 1.4; }
        .amenity-price { font-size: .85rem; color: var(--ocean-700); font-weight: 800; margin-top: 6px; }
        
        .empty-amenity { text-align: center; padding: 3rem; color: #9ca3af; }
        .empty-amenity i { font-size: 3rem; margin-bottom: .8rem; color: var(--ocean-200); display: block; }

        /* Back link */
        .btn-back {
            display: inline-flex; align-items: center; gap: .5rem;
            color: var(--ocean-700); font-weight: 700; font-size: .95rem;
            text-decoration: none; margin-bottom: 1.5rem; transition: color .2s;
        }
        .btn-back:hover { text-decoration: none; color: var(--ocean-900); }

        /* ── Booking modal ── */
        .modal-backdrop-custom {
            display: none; position: fixed; inset: 0; background: rgba(3, 4, 94, .6);
            z-index: 1040; align-items: center; justify-content: center; backdrop-filter: blur(4px);
        }
        .modal-backdrop-custom.show { display: flex; }
        .booking-form {
            background: #fff; border-radius: 24px; padding: 32px 40px;
            width: 100%; max-width: 500px; position: relative;
            box-shadow: 0 12px 40px rgba(0,0,0,.2);
        }
        .booking-form .close-btn {
            position: absolute; top: 20px; right: 24px; font-size: 1.6rem; cursor: pointer; color: #9ca3af;
            background: none; border: none; line-height: 1; transition: color .2s;
        }
        .booking-form .close-btn:hover { color: var(--ocean-900); }
        .booking-heading { font-size: 1.4rem; font-weight: 800; color: var(--ocean-900); margin-bottom: 8px; }
        .booking-text { font-size: .9rem; color: #6b7280; margin-bottom: 20px; line-height: 1.5; }
        .booking-form input {
            width: 100%; padding: 10px 14px; border: 1.5px solid #e5e7eb; border-radius: 10px;
            font-size: .95rem; margin-bottom: 16px; transition: border-color .2s; font-family: 'Pretendard', sans-serif;
        }
        .booking-form input:focus { outline: none; border-color: var(--ocean-500); box-shadow: 0 0 0 3px rgba(0, 180, 216, 0.15); }
        .booking-form p { font-size: .85rem; color: var(--ocean-800); margin: 0 0 6px; font-weight: 700; }
        .btn-submit-booking {
            width: 100%; background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600)); color: #fff;
            border: none; border-radius: 12px; padding: 14px; font-weight: 800; font-size: 1.05rem;
            cursor: pointer; transition: transform .2s, box-shadow .2s; margin-top: 8px;
        }
        .btn-submit-booking:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 119, 182, 0.25); }

        /* ── Footer ── */
        .footer-section {
            background: var(--ocean-900); color: #e2e8f0; padding: 48px 0 32px; margin-top: 48px;
        }
        .footer-section h3 { color: #fff; font-size: 1.4rem; font-weight: 800; margin-bottom: 16px; }
        .footer-section h5 { color: var(--ocean-200); font-size: .95rem; font-weight: 500; line-height: 1.6; }
        .footer-section a { color: var(--ocean-400); font-size: 1.5rem; transition: color 0.2s; margin: 0 8px; }
        .footer-section a:hover { color: #fff; }
    </style>
</head>
<body>
    <%@ include file="../navbar.jsp" %>

    <div class="container-fluid p-0">
      <div class="row g-0" style="min-height: calc(100vh - 56px);">
        <%@ include file="sidebar.jsp" %>
        <main class="col p-0">

    <%-- Room not found --%>
    <c:if test="${empty room}">
        <div class="container mt-5 text-center">
            <i class="bi bi-exclamation-circle-fill text-danger mb-3 d-block" style="font-size:4rem"></i>
            <h3 class="fw-bold" style="color: var(--ocean-900);">Room not found</h3>
            <p class="text-muted mb-4">The room you are looking for does not exist or is currently unavailable.</p>
            <a href="${pageContext.request.contextPath}/room?action=publicList" class="btn text-white fw-bold px-4 py-2" style="background: var(--ocean-700); border-radius: 10px;">
                Back to Room List
            </a>
        </div>
    </c:if>

    <c:if test="${not empty room}">
    <div class="container py-4" style="max-width:1100px; padding-top: 32px !important;">

        <a href="${pageContext.request.contextPath}/room?action=publicList" class="btn-back">
            <i class="bi bi-arrow-left"></i> Back to Room List
        </a>

        <%-- ── Top Hero Details ── --%>
        <section class="room-details">
            <div class="row g-5">
                <%-- Main image --%>
                <div class="col-lg-5">
                    <c:choose>
                        <c:when test="${not empty room.image}">
                            <img class="view-img"
                                 src="${pageContext.request.contextPath}/${room.image}"
                                 alt="Room ${room.roomNumber}"
                                 onerror="this.style.display='none';document.getElementById('img-placeholder').style.display='flex';">
                            <div id="img-placeholder" class="view-img-placeholder" style="display:none;">
                                <i class="bi bi-door-closed-fill"></i>
                                <span class="fw-bold fs-5 mt-2">Room ${room.roomNumber}</span>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="view-img-placeholder">
                                <i class="bi bi-image"></i>
                                <span class="fw-bold fs-5 mt-2">Room ${room.roomNumber}</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- Details column --%>
                <div class="col-lg-7">
                    <div class="d-flex align-items-center gap-3 mb-2 flex-wrap">
                        <span class="view-title">
                            <i class="bi bi-door-open-fill me-1" style="color: var(--ocean-500);"></i>Room ${room.roomNumber}
                        </span>
                        <span class="status-pill s-${room.status}">
                            <c:choose>
                                <c:when test="${room.status == 'available'}"><i class="bi bi-check-circle-fill me-1"></i>Available</c:when>
                                <c:when test="${room.status == 'occupied'}"><i class="bi bi-person-fill-check me-1"></i>Occupied</c:when>
                                <c:otherwise><i class="bi bi-tools me-1"></i>Maintenance</c:otherwise>
                            </c:choose>
                        </span>
                        <c:if test="${not empty room.categoryName}">
                            <span class="category-tag"><i class="bi bi-tag-fill me-1"></i>${room.categoryName}</span>
                        </c:if>
                    </div>

                    <c:if test="${not empty room.basePrice and room.basePrice > 0}">
                        <p class="mb-3" style="font-size:1.6rem;font-weight:800;color:var(--ocean-700);">
                            <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                            <span style="font-size:.9rem;color:#9ca3af;font-weight:600"> / month</span>
                        </p>
                    </c:if>

                    <p class="view-des">This is a premium space designed for your comfort and convenience. Contact us for a direct viewing or book immediately via the system.</p>

                    <%-- Stats --%>
                    <div class="stats-row">
                        <div class="stat-box">
                            <span class="num">#${room.roomId}</span>
                            <span class="num-text">Room ID</span>
                        </div>
                        <c:if test="${not empty amenities}">
                        <div class="stat-box">
                            <span class="num">${amenities.size()}</span>
                            <span class="num-text">Amenities</span>
                        </div>
                        </c:if>
                        <div class="stat-box">
                            <span class="num" style="font-size:1.2rem;padding-top:.6rem; padding-bottom: 0.2rem;">
                                <c:choose>
                                    <c:when test="${room.status == 'available'}">Ready</c:when>
                                    <c:otherwise>Wait</c:otherwise>
                                </c:choose>
                            </span>
                            <span class="num-text">Status</span>
                        </div>
                    </div>

                    <%-- Action buttons --%>
                    <div class="view-btn mt-4">
                        <c:choose>
                            <%-- Admin/Staff --%>
                            <c:when test="${sessionScope.user.role == 'admin' or sessionScope.user.role == 'staff'}">
                                <a href="${pageContext.request.contextPath}/contract?action=create" class="btn-book-now">
                                    <i class="bi bi-file-earmark-plus-fill"></i> Create Contract
                                </a>
                            </c:when>
                            <%-- Logged-in customer, room available --%>
                            <c:when test="${not empty sessionScope.user and room.status == 'available'}">
                                <c:choose>
                                    <c:when test="${alreadyHasContract == true}">
                                        <span class="btn-book-now disabled">
                                            <i class="bi bi-bookmark-check-fill"></i> Already Contracted
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="javascript:void(0);" onclick="openBookingModal()" class="btn-book-now">
                                            <i class="bi bi-calendar2-check-fill"></i> Book Now
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <%-- Not logged in, room available --%>
                            <c:when test="${empty sessionScope.user and room.status == 'available'}">
                                <a href="${pageContext.request.contextPath}/auth?action=login" class="btn-book-now">
                                    <i class="bi bi-box-arrow-in-right"></i> Log In to Book
                                </a>
                            </c:when>
                            <%-- Not available --%>
                            <c:otherwise>
                                <span class="btn-book-now disabled">
                                    <i class="bi bi-lock-fill"></i> Not Available
                                </span>
                            </c:otherwise>
                        </c:choose>
                        <a href="${pageContext.request.contextPath}/room?action=publicList" class="btn-contact">
                            <i class="bi bi-chat-dots-fill"></i> Contact Support
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <%-- ── Image gallery ── --%>
        <c:if test="${not empty room.image}">
        <section class="gallery">
            <div class="section-title">
                <i class="bi bi-images"></i> Room Gallery
            </div>
            <div class="img-gallery-grid">
                <img class="img-thumb active"
                     src="${pageContext.request.contextPath}/${room.image}"
                     alt="Room ${room.roomNumber}"
                     onclick="selectThumb(this)"
                     onerror="this.style.display='none'">
            </div>
        </section>
        </c:if>

        <%-- ── SIDE-BY-SIDE: Room info + Amenities row ── --%>
        <div class="row g-4 align-items-stretch">
            
            <%-- Left: Room information --%>
            <div class="col-lg-4 col-md-5">
                <div class="info-card h-100 mb-0">
                    <div class="section-title">
                        <i class="bi bi-info-circle-fill"></i> Room Info
                    </div>
                    <div class="info-row">
                        <div class="info-key">Room No.</div>
                        <div class="info-val fs-5">${room.roomNumber}</div>
                    </div>
                    <div class="info-row">
                        <div class="info-key">Status</div>
                        <div class="info-val">
                            <span class="status-pill s-${room.status}" style="font-size:.74rem;padding:3px 11px;">
                                <c:choose>
                                    <c:when test="${room.status == 'available'}"><i class="bi bi-check-circle-fill me-1"></i>Available</c:when>
                                    <c:when test="${room.status == 'occupied'}"><i class="bi bi-person-fill-check me-1"></i>Occupied</c:when>
                                    <c:otherwise><i class="bi bi-tools me-1"></i>Maintenance</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                    <c:if test="${not empty room.categoryName}">
                    <div class="info-row">
                        <div class="info-key">Type</div>
                        <div class="info-val">
                            <span class="category-tag"><i class="bi bi-tag-fill me-1"></i>${room.categoryName}</span>
                        </div>
                    </div>
                    </c:if>
                    <c:if test="${not empty room.areaMSquare and room.areaMSquare > 0}">
                    <div class="info-row">
                        <div class="info-key">Floor Area</div>
                        <div class="info-val">${room.areaMSquare} m²</div>
                    </div>
                    </c:if>
                    <c:if test="${room.maxOccupants > 0}">
                    <div class="info-row">
                        <div class="info-key">Max Occupancy</div>
                        <div class="info-val">${room.maxOccupants} persons</div>
                    </div>
                    </c:if>
                    <c:if test="${not empty room.basePrice and room.basePrice > 0}">
                    <div class="info-row">
                        <div class="info-key">Base Price</div>
                        <div class="info-val fw-bold" style="color:var(--ocean-700);">
                            <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                            <span class="text-muted fw-normal" style="font-size:.78rem"> / month</span>
                        </div>
                    </div>
                    </c:if>
                    <div class="info-row" style="border-bottom: none;">
                        <div class="info-key">Room ID</div>
                        <div class="info-val text-muted">#${room.roomId}</div>
                    </div>
                </div>
            </div>

            <%-- Right: Facilities --%>
            <div class="col-lg-8 col-md-7">
                <div class="info-card h-100 mb-0">
                    <div class="section-title">
                        <i class="bi bi-stars"></i>
                        Room Facilities
                        <span class="badge ms-auto rounded-pill" style="background:var(--ocean-100);color:var(--ocean-800);font-size:.8rem;">
                            ${amenities.size()} items
                        </span>
                    </div>
                    <c:choose>
                        <c:when test="${empty amenities}">
                            <div class="empty-amenity">
                                <i class="bi bi-inbox-fill"></i>
                                <p class="mb-0 fw-semibold">No facilities listed yet.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row g-3 mt-1">
                                <c:forEach var="a" items="${amenities}">
                                <div class="col-md-6 col-xl-6">
                                    <div class="amenity-card">
                                        <div class="amenity-icon-wrap">
                                            <c:choose>
                                                <c:when test="${not empty a.image}">
                                                    <c:choose>
                                                        <c:when test="${fn:startsWith(a.image, 'http') or fn:startsWith(a.image, '/')}">
                                                            <img src="${fn:startsWith(a.image, 'http') ? '' : pageContext.request.contextPath}${a.image}" alt="${a.facilityName}" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="${pageContext.request.contextPath}/${a.image}" alt="${a.facilityName}" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div style="display:none;width:100%;height:100%;align-items:center;justify-content:center;">
                                                        <i class="bi bi-image" style="font-size:1.5rem;"></i>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-star-fill" style="font-size:1.5rem;"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="amenity-name">${a.facilityName}</div>
                                            <c:if test="${not empty a.description}">
                                                <div class="amenity-desc text-truncate" style="max-width: 130px;" title="${a.description}">${a.description}</div>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${not empty a.monthlyPrice and a.monthlyPrice > 0}">
                                                    <div class="amenity-price">
                                                        <fmt:formatNumber value="${a.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;<span style="font-weight:500;color:#9ca3af;font-size:.75rem;">/mo</span>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="font-size:.8rem;color:#10b981;font-weight:700;margin-top:6px;"><i class="bi bi-check-circle-fill me-1"></i>Included</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

    </div>

    <%-- ── Booking modal (Preserved logic) ── --%>
    <div id="bookingModal" class="modal-backdrop-custom">
        <div class="booking-form">
            <button class="close-btn" onclick="closeBookingModal()"><i class="bi bi-x-lg"></i></button>
            <h2 class="booking-heading"><i class="bi bi-calendar2-check-fill me-2" style="color: var(--ocean-600);"></i>Booking Request</h2>
            <p class="booking-text">Once created, you may edit or remove bookings unless they've been approved. You will receive an approval mail with payment options shortly!</p>
            <form action="${pageContext.request.contextPath}/booking" method="post">
                <input type="hidden" name="roomId" value="${room.roomId}">
                <p><i class="bi bi-person-fill me-1"></i> Full Name:</p>
                <input type="text" name="custname" value="${sessionScope.user.fullName}" required>
                
                <p><i class="bi bi-envelope-fill me-1"></i> Email:</p>
                <input type="email" name="custmail" value="${sessionScope.user.email}" required>
                
                <div class="row g-2 mt-1">
                    <div class="col-6">
                        <p><i class="bi bi-calendar-event-fill me-1"></i> Check-In:</p>
                        <input type="date" name="cindate" required>
                    </div>
                    <div class="col-6">
                        <p><i class="bi bi-calendar-x-fill me-1"></i> Check-Out:</p>
                        <input type="date" name="coutdate" required>
                    </div>
                </div>
                
                <hr style="margin:16px 0; border-color: var(--ocean-200);">
                <button type="submit" class="btn-submit-booking"><i class="bi bi-send-fill me-2"></i>Create Booking</button>
            </form>
        </div>
    </div>

    </c:if>

    <%-- Footer --%>
    <section class="footer-section">
        <div class="container">
            <div class="row text-center text-md-start align-items-center">
                <div class="col-md-4 mb-3 mb-md-0">
                    <h3 class="mb-1"><i class="bi bi-buildings-fill me-2" style="color: var(--ocean-400);"></i>AKDD House</h3>
                    <div class="small text-white-50">Premium Boarding House Management</div>
                </div>
                <div class="col-md-4 mb-3 mb-md-0 text-center">
                    <h5 class="mb-1"><i class="bi bi-geo-alt-fill me-2 text-white-50"></i>8386, An Binh, Ninh Kieu, Can Tho</h5>
                    <h5><i class="bi bi-telephone-fill me-2 text-white-50"></i>+(84) 91 123 4567</h5>
                </div>
                <div class="col-md-4 text-center text-md-end">
                    <p class="lead mb-0">
                        <a href="#" class="mx-2"><i class="bi bi-twitter" aria-hidden="true"></i></a>
                        <a href="#" class="mx-2"><i class="bi bi-facebook" aria-hidden="true"></i></a>
                        <a href="#" class="mx-2"><i class="bi bi-instagram" aria-hidden="true"></i></a>
                    </p>
                </div>
            </div>
        </div>
    </section>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function selectThumb(el) {
            document.querySelectorAll('.img-thumb').forEach(t => t.classList.remove('active'));
            el.classList.add('active');
            const viewImg = document.querySelector('.view-img');
            if (viewImg) viewImg.src = el.src;
        }

        function openBookingModal() {
            document.getElementById('bookingModal').classList.add('show');
        }
        function closeBookingModal() {
            document.getElementById('bookingModal').classList.remove('show');
        }
        document.getElementById('bookingModal')?.addEventListener('click', function(e) {
            if (e.target === this) closeBookingModal();
        });
    </script>
        </main>
      </div>
    </div>
</body>
</html>