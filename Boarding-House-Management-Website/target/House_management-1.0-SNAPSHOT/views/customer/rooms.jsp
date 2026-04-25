<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Room List - AKDD House</title>
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

        /* ── Search bar ── */
        .search-wrap { text-align: center; margin: 24px 0 16px; }
        .search-inner {
            display: inline-block; width: 60%;
            background-color: #fff; border-radius: 12px;
            padding: 8px; box-shadow: 0 4px 16px rgba(0,0,0,.06);
        }

        /* ── Section title ── */
        .room-title-new {
            font-size: 1.6rem; font-weight: 800; color: var(--ocean-900);
            display: block; padding: 16px 0 4px;
        }
        .room-title-new hr { margin: 8px 0 16px; border-color: var(--ocean-500); border-width: 2px; opacity: 1; width: 60px; border-radius: 4px; }

        /* ── Filter bar ── */
        .filter-label {
            font-size: .75rem; font-weight: 800; text-transform: uppercase;
            letter-spacing: .6px; color: var(--ocean-700); margin-bottom: .6rem;
        }
        .filter-bar {
            background: #fff; border-radius: 50px; padding: 6px;
            display: inline-flex; flex-wrap: wrap; gap: 4px;
            box-shadow: 0 4px 16px rgba(0,0,0,.04);
        }
        .filter-btn {
            border-radius: 50px; border: none; padding: 8px 18px;
            font-weight: 700; font-size: .85rem; cursor: pointer; text-decoration: none;
            display: inline-flex; align-items: center; gap: .4rem;
            color: #6b7280; background: transparent;
            transition: all .2s; white-space: nowrap;
        }
        .filter-btn:hover  { background: var(--ocean-100); color: var(--ocean-900); }
        .filter-btn.active { 
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600)); 
            color: #fff; 
            box-shadow: 0 4px 10px rgba(0, 119, 182, 0.2);
        }
        .filter-count {
            background: rgba(255,255,255,.25); border-radius: 20px; 
            padding: 2px 8px; font-size: .75rem;
        }
        .filter-btn:not(.active) .filter-count { background: #e5e7eb; color: #374151; }

        /* ── Room card ── */
        .card {
            border-radius: 16px; border: none;
            box-shadow: 0 4px 16px rgba(0,0,0,.04);
            overflow: hidden; transition: transform .2s, box-shadow .2s;
            height: 100%;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 28px rgba(0, 119, 182, 0.08);
        }
        .card-img-wrap {
            position: relative; height: 200px; overflow: hidden; background: #f3f4f6;
        }
        .card-img-wrap .card-img-top {
            width: 100%; height: 100%; object-fit: cover; transition: transform .3s ease;
        }
        .card:hover .card-img-wrap .card-img-top { transform: scale(1.05); }

        .room-placeholder {
            position: absolute; inset: 0; display: none; flex-direction: column;
            align-items: center; justify-content: center; gap: .5rem; color: #aaa;
        }
        .room-placeholder i { font-size: 3rem; color: var(--ocean-300); }

        /* Status badge over card image */
        .status-badge {
            position: absolute; top: 12px; right: 12px;
            border-radius: 20px; padding: 4px 12px;
            font-size: .7rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: .5px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .status-available   { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .status-occupied    { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
        .status-maintenance { background: #fef9c3; color: #a16207; border: 1px solid #fef08a; }

        /* Category tag */
        .room-category-tag {
            display: inline-block;
            background: var(--ocean-100); color: var(--ocean-800);
            border-radius: 8px; padding: 4px 10px;
            font-size: .75rem; font-weight: 700; margin-bottom: .8rem;
        }
        .room-price {
            font-size: 1.1rem; color: var(--ocean-700); font-weight: 800;
            margin-bottom: 1rem;
        }
        .room-price .price-label { font-size: .8rem; color: #9ca3af; font-weight: 500; }

        /* Book Now button */
        .btn-book {
            display: block; text-align: center;
            background: linear-gradient(135deg, var(--ocean-700), var(--ocean-500));
            color: #fff; border-radius: 10px; border: none;
            padding: 10px 0; font-weight: 700; font-size: .95rem;
            text-decoration: none; transition: transform .2s, box-shadow .2s;
        }
        .btn-book:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0, 150, 199, 0.25);
            color: #fff; 
        }
        .btn-book.disabled {
            background: #e5e7eb; color: #9ca3af; pointer-events: none; box-shadow: none;
        }

        /* ── Section wrapper ── */
        .h-rooms { padding: 0 8px 24px; }
        .card-set { padding: 8px 0; }

        /* ── Results info ── */
        .results-info { font-size: .9rem; color: #6b7280; margin-bottom: 1rem; font-weight: 500; }
        .results-info strong { color: var(--ocean-700); font-weight: 700; }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 5rem 1rem; color: #9ca3af; }
        .empty-state i { font-size: 4rem; margin-bottom: 1rem; color: var(--ocean-200); }
        .empty-state h5 { color: var(--ocean-800); font-weight: 700; }

        /* Pagination */
        .pagination .page-link { color: var(--ocean-800); border-color: #dee2e6; font-weight: 600; }
        .pagination .page-item.active .page-link { background-color: var(--ocean-800); border-color: var(--ocean-800); color: white; }
        .pagination .page-link:hover { background-color: var(--ocean-100); color: var(--ocean-900); }

        /* ── Footer ── */
        .footer-section {
            background: var(--ocean-900); /* Đổi footer sang Navy đậm */
            color: #e2e8f0;
            padding: 40px 0 24px;
            margin-top: 40px;
        }
        .footer-section h3 { color: #fff; font-size: 1.25rem; font-weight: 800; margin-bottom: 16px; }
        .footer-section h5 { color: var(--ocean-200); font-size: .95rem; font-weight: 400; line-height: 1.6; }
        .footer-section a { color: var(--ocean-400); font-size: 1.4rem; transition: color 0.2s; }
        .footer-section a:hover { color: #fff; }
    </style>
</head>
<body>
    <%@ include file="../navbar.jsp" %>

    <div class="container-fluid p-0">
      <div class="row g-0" style="min-height: calc(100vh - 56px);">
        <%@ include file="sidebar.jsp" %>
        <main class="col p-0">

    <%-- Search bar (from rooms.html) --%>
    
    <div class="container pb-4" style="padding-top: 32px; max-width: 1200px;">

        <%-- Category filter --%>
        <c:if test="${not empty categories}">
            <div class="mb-3">
                <div class="filter-label"><i class="bi bi-tag-fill me-1"></i>Room Category</div>
                <div class="filter-bar">
                    <a href="${pageContext.request.contextPath}/room?action=publicList<c:if test="${not empty activeStatus}">&amp;status=${activeStatus}</c:if>"
                       class="filter-btn ${activeCategoryId == 0 ? 'active' : ''}">
                        <i class="bi bi-grid-3x3-gap-fill"></i> All Types
                    </a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="${pageContext.request.contextPath}/room?action=publicList&amp;categoryId=${cat.categoryId}<c:if test="${not empty activeStatus}">&amp;status=${activeStatus}</c:if>"
                           class="filter-btn ${activeCategoryId == cat.categoryId ? 'active' : ''}">
                            ${cat.categoryName}
                        </a>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <%-- Status filter --%>
        <div class="mb-4">
            <div class="filter-label"><i class="bi bi-circle-half me-1"></i>Availability</div>
            <div class="filter-bar">
                <a href="${pageContext.request.contextPath}/room?action=publicList<c:if test="${activeCategoryId > 0}">&amp;categoryId=${activeCategoryId}</c:if>"
                   class="filter-btn ${empty activeStatus ? 'active' : ''}">
                    <i class="bi bi-grid-fill"></i> All
                    <span class="filter-count">
                        ${statusCounts['available'] + statusCounts['occupied'] + statusCounts['maintenance']}
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/room?action=publicList&amp;status=available<c:if test="${activeCategoryId > 0}">&amp;categoryId=${activeCategoryId}</c:if>"
                   class="filter-btn ${activeStatus == 'available' ? 'active' : ''}">
                    <i class="bi bi-check-circle-fill"></i> Available
                    <span class="filter-count">${statusCounts['available']}</span>
                </a>
                <a href="${pageContext.request.contextPath}/room?action=publicList&amp;status=occupied<c:if test="${activeCategoryId > 0}">&amp;categoryId=${activeCategoryId}</c:if>"
                   class="filter-btn ${activeStatus == 'occupied' ? 'active' : ''}">
                    <i class="bi bi-person-fill-check"></i> Occupied
                    <span class="filter-count">${statusCounts['occupied']}</span>
                </a>
                <a href="${pageContext.request.contextPath}/room?action=publicList&amp;status=maintenance<c:if test="${activeCategoryId > 0}">&amp;categoryId=${activeCategoryId}</c:if>"
                   class="filter-btn ${activeStatus == 'maintenance' ? 'active' : ''}">
                    <i class="bi bi-tools"></i> Maintenance
                    <span class="filter-count">${statusCounts['maintenance']}</span>
                </a>
            </div>
        </div>

        <%-- Room sections --%>
        <c:choose>
            <c:when test="${empty rooms}">
                <div class="empty-state">
                    <i class="bi bi-door-open-fill d-block"></i>
                    <h5>No rooms found</h5>
                    <p>There are no rooms matching the selected filters.</p>
                    <a href="${pageContext.request.contextPath}/room?action=publicList"
                       class="btn px-4 py-2 text-white fw-bold mt-3" style="background: var(--ocean-700); border-radius: 8px;">View All Rooms</a>
                </div>
            </c:when>
            <c:otherwise>
                <%-- Results info --%>
                <div class="results-info px-2">
                    Showing <strong>${rooms.size()}</strong> room<c:if test="${rooms.size() != 1}">s</c:if>
                    <c:if test="${activeCategoryId > 0}">
                        <c:forEach var="cat" items="${categories}">
                            <c:if test="${cat.categoryId == activeCategoryId}"> in <strong>${cat.categoryName}</strong></c:if>
                        </c:forEach>
                    </c:if>
                    <c:if test="${not empty activeStatus}"> &middot; status: <strong>${activeStatus}</strong></c:if>
                </div>

                <section class="room-details">
                    <div class="h-rooms">
                        <%-- Section title --%>
                        <div class="row px-2">
                            <span class="room-title-new">
                                <c:choose>
                                    <c:when test="${activeCategoryId > 0}">
                                        <c:forEach var="cat" items="${categories}">
                                            <c:if test="${cat.categoryId == activeCategoryId}">${cat.categoryName}</c:if>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>All Rooms</c:otherwise>
                                </c:choose>
                                <hr>
                            </span>
                        </div>

                        <%-- Cards --%>
                        <div class="card-set">
                            <div class="row g-4">
                                <c:forEach var="room" items="${rooms}">
                                    <div class="col-sm-6 col-md-4 col-xl-3">
                                        <div class="card">
                                            <div class="card-img-wrap">
                                                <c:choose>
                                                    <c:when test="${not empty room.image}">
                                                        <img class="card-img-top"
                                                             src="${pageContext.request.contextPath}/${room.image}"
                                                             alt="Room ${room.roomNumber}"
                                                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                                        <div class="room-placeholder" style="display:none">
                                                            <i class="bi bi-house-door-fill"></i>
                                                            <span class="small fw-semibold">No Image</span>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:set var="imgIdx" value="${room.roomId % 8}" />
                                                        <c:choose>
                                                            <c:when test="${imgIdx == 0}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room1.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:when test="${imgIdx == 1}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room2.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:when test="${imgIdx == 2}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room3.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:when test="${imgIdx == 3}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room4.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:when test="${imgIdx == 4}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room5.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:when test="${imgIdx == 5}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room6.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:when test="${imgIdx == 6}"><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room7.jpg" alt="Room ${room.roomNumber}"></c:when>
                                                            <c:otherwise><img class="card-img-top" src="${pageContext.request.contextPath}/assets/images/room/room8.jpg" alt="Room ${room.roomNumber}"></c:otherwise>
                                                        </c:choose>
                                                    </c:otherwise>
                                                </c:choose>
                                                <span class="status-badge status-${room.status}">
                                                    <c:choose>
                                                        <c:when test="${room.status == 'available'}">Available</c:when>
                                                        <c:when test="${room.status == 'occupied'}">Occupied</c:when>
                                                        <c:otherwise>Maintenance</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div class="card-body p-4">
                                                <h5 class="card-title fw-bold mb-2 text-dark">Room ${room.roomNumber}</h5>
                                                <span class="room-category-tag">
                                                    <c:choose>
                                                        <c:when test="${not empty room.areaMSquare and room.areaMSquare > 0}">
                                                            <i class="bi bi-rulers me-1"></i>${room.areaMSquare}m²
                                                            <c:if test="${room.maxOccupants > 0}"> &bull; ${room.maxOccupants} person</c:if>
                                                        </c:when>
                                                        <c:when test="${not empty room.categoryName}">
                                                            <i class="bi bi-tag-fill me-1"></i>${room.categoryName}
                                                        </c:when>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${not empty room.basePrice and room.basePrice > 0}">
                                                    <div class="room-price">
                                                        <fmt:formatNumber value="${room.basePrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;
                                                        <span class="price-label">/ month</span>
                                                    </div>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/room?action=publicDetail&id=${room.roomId}"
                                                   class="btn-book ${room.status == 'maintenance' ? 'disabled' : ''}">
                                                    <i class="bi bi-calendar-check me-1"></i>
                                                    ${room.status == 'maintenance' ? 'Unavailable' : 'View & Book'}
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </section>
            </c:otherwise>
        </c:choose>

        <%-- Pagination --%>
        <c:if test="${totalPages > 1}">
            <nav class="mt-2 mb-4">
                <ul class="pagination justify-content-center">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?action=publicList<c:if test='${not empty activeStatus}'>&amp;status=${activeStatus}</c:if><c:if test='${activeCategoryId > 0}'>&amp;categoryId=${activeCategoryId}</c:if>&amp;page=${currentPage - 1}">Previous</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link" href="?action=publicList<c:if test='${not empty activeStatus}'>&amp;status=${activeStatus}</c:if><c:if test='${activeCategoryId > 0}'>&amp;categoryId=${activeCategoryId}</c:if>&amp;page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?action=publicList<c:if test='${not empty activeStatus}'>&amp;status=${activeStatus}</c:if><c:if test='${activeCategoryId > 0}'>&amp;categoryId=${activeCategoryId}</c:if>&amp;page=${currentPage + 1}">Next</a>
                    </li>
                </ul>
            </nav>
        </c:if>

    </div>

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
        </main>
      </div>
    </div>
</body>
</html>