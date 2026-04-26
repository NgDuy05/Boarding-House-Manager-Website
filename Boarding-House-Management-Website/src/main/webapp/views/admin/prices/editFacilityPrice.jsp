<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<t:layout>

    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/price?action=categories&type=facility"
           class="btn btn-sm btn-outline-secondary">
            <i class="bi bi-arrow-left"></i>
        </a>
        <h4 class="mb-0"><i class="bi bi-box-seam me-2"></i>Edit Facility Price</h4>
    </div>

    <c:if test="${empty facility}">
        <div class="alert alert-danger">Facility not found.</div>
    </c:if>

    <c:if test="${not empty facility}">
        <div class="card shadow-sm border-0" style="max-width:520px;">
            <div class="card-header py-3" style="background:linear-gradient(135deg,#6EA2B3,#4E8EA2);color:white;border-radius:12px 12px 0 0;">
                <strong>${facility.facilityName}</strong>
                <span class="text-white-50 ms-2 small">#${facility.facilityId}</span>
            </div>
            <div class="card-body">

                <c:if test="${not empty facility.image}">
                    <div class="mb-3 text-center">
                        <img src="${pageContext.request.contextPath}/assets/images/facility/${facility.image}"
                             style="max-height:100px;border-radius:8px;object-fit:cover;" alt="${facility.facilityName}">
                    </div>
                </c:if>

                <div class="mb-3">
                    <label class="form-label text-muted small">Current Monthly Price</label>
                    <div class="fw-bold fs-5 text-success">
                        <c:choose>
                            <c:when test="${facility.monthlyPrice != null and facility.monthlyPrice > 0}">
                                <fmt:formatNumber value="${facility.monthlyPrice}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/tháng
                            </c:when>
                            <c:otherwise><span class="text-muted fst-italic">Chưa có giá</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/price">
                    <input type="hidden" name="action" value="saveFacilityPrice">
                    <input type="hidden" name="facilityId" value="${facility.facilityId}">

                    <div class="mb-4">
                        <label class="form-label fw-semibold">New Monthly Price (₫) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="number" name="monthlyPrice" class="form-control"
                                   value="${facility.monthlyPrice}" min="0" step="1000" required>
                            <span class="input-group-text">₫/tháng</span>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>Save
                        </button>
                        <a href="${pageContext.request.contextPath}/price?action=categories&type=facility"
                           class="btn btn-outline-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

</t:layout>
