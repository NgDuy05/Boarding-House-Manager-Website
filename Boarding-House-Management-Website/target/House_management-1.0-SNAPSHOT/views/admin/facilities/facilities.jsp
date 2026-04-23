<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t"   tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<t:layout>

<style>
    .page-header {
        background: linear-gradient(135deg, #1a1a2e, #16213e, #0f3460);
        color: white; border-radius: 12px; padding: 20px 24px; margin-bottom: 24px;
    }
    .page-header .btn-light { background: rgba(255,255,255,0.15); border: none; color: #fff; font-weight: 600; }
    .page-header .btn-light:hover { background: rgba(255,255,255,0.28); }

    /* Facility card */
    .facility-card {
        border: none;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        transition: transform .18s, box-shadow .18s;
    }
    .facility-card:hover { transform: translateY(-4px); box-shadow: 0 8px 28px rgba(0,0,0,0.13); }

    /* Full-bleed image that fills the top of the card */
    .facility-img-wrap {
        width: 100%;
        aspect-ratio: 4 / 3;
        background: #f8f9fa;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }
    .facility-img-wrap img {
        width: 100%;
        height: 100%;
        object-fit: contain;   /* full ảnh, không cắt */
        display: block;
    }
    .facility-card:hover .facility-img-wrap img { transform: none; }

    .facility-img-wrap .no-img {
        width: 100%; height: 100%;
        display: flex; align-items: center; justify-content: center;
        color: #adb5bd; font-size: 3rem;
    }

    .facility-card .card-body { padding: 16px 18px 10px; }
    .facility-card .card-footer { background: transparent; border-top: 1px solid #f0f0f0; padding: 10px 18px 14px; }
</style>

    <%-- Header --%>
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-shield-check-fill me-2"></i>Room Amenities</h4>
            <small class="opacity-75">Manage all facility amenities and their pricing</small>
        </div>
        <a href="${pageContext.request.contextPath}/facility?action=create" class="btn btn-light fw-semibold">
            <i class="bi bi-plus-circle-fill me-1"></i>Add Amenity
        </a>
    </div>

    <%-- Stat --%>
    <c:if test="${not empty facilities}">
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm text-center p-3" style="border-radius:12px;">
                    <div class="fw-bold fs-4 text-primary">${facilities.size()}</div>
                    <div class="text-muted small">Total Amenities</div>
                </div>
            </div>
        </div>
    </c:if>

    <%-- Grid --%>
    <c:choose>
        <c:when test="${not empty facilities}">
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-xl-4 g-4">
                <c:forEach var="facility" items="${facilities}">
                    <div class="col">
                        <div class="card facility-card h-100">

                            <%-- Full-bleed image --%>
                            <div class="facility-img-wrap">
                                <c:choose>
                                    <c:when test="${not empty facility.image}">
                                        <img src="${pageContext.request.contextPath}/${facility.image}"
                                             alt="${facility.facilityName}">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="no-img">
                                            <i class="bi bi-image"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="card-body">
                                <h6 class="fw-bold mb-1">${facility.facilityName}</h6>
                                <p class="text-muted small mb-2" style="line-height:1.4;">
                                    <c:choose>
                                        <c:when test="${not empty facility.description}">${facility.description}</c:when>
                                        <c:otherwise><em>No description</em></c:otherwise>
                                    </c:choose>
                                </p>
                                <c:choose>
                                    <c:when test="${facility.monthlyPrice > 0}">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3">
                                            <i class="bi bi-currency-exchange me-1"></i>
                                            +<fmt:formatNumber value="${facility.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/mo
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-3">
                                            <i class="bi bi-tag me-1"></i>No price set
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="card-footer d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/facility?action=detail&id=${facility.facilityId}"
                                   class="btn btn-sm btn-outline-info flex-fill" title="Detail">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/facility?action=edit&id=${facility.facilityId}"
                                   class="btn btn-sm btn-outline-primary flex-fill" title="Edit">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/facility?action=delete&id=${facility.facilityId}"
                                   class="btn btn-sm btn-outline-danger flex-fill" title="Delete"
                                   onclick="return confirm('Delete amenity \'${facility.facilityName}\'?')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>

        <c:otherwise>
            <div class="text-center text-muted py-5">
                <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                <p>No amenities found.</p>
                <a href="${pageContext.request.contextPath}/facility?action=create" class="btn btn-primary">
                    <i class="bi bi-plus-circle me-1"></i>Add First Amenity
                </a>
            </div>
        </c:otherwise>
    </c:choose>

</t:layout>
