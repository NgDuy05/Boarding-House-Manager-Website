<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<t:layout>

    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/price?action=categories&type=rent"
           class="btn btn-sm btn-outline-secondary">
            <i class="bi bi-arrow-left"></i>
        </a>
        <h4 class="mb-0"><i class="bi bi-house-gear me-2"></i>Edit Room Category Price</h4>
    </div>

    <c:if test="${empty roomCategory}">
        <div class="alert alert-danger">Room category not found.</div>
    </c:if>

    <c:if test="${not empty roomCategory}">
        <div class="card shadow-sm border-0" style="max-width:520px;">
            <div class="card-header py-3" style="background:linear-gradient(135deg,#001D39,#0A4174);color:white;border-radius:12px 12px 0 0;">
                <strong>${roomCategory.categoryName}</strong>
                <span class="text-white-50 ms-2 small">#${roomCategory.categoryId}</span>
            </div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/price">
                    <input type="hidden" name="action" value="saveRoomCategory">
                    <input type="hidden" name="categoryId" value="${roomCategory.categoryId}">

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Category Name</label>
                        <input type="text" name="categoryName" class="form-control"
                               value="${roomCategory.categoryName}" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea name="description" class="form-control" rows="2">${roomCategory.description}</textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Base Monthly Price (₫) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="number" name="basePrice" class="form-control"
                                   value="${roomCategory.basePrice}" min="0" step="1000" required>
                            <span class="input-group-text">₫/month</span>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold">Price Per Day (₫)</label>
                        <div class="input-group">
                            <input type="number" name="pricePerDay" class="form-control"
                                   value="${roomCategory.pricePerDay}" min="0" step="1000">
                            <span class="input-group-text">₫/day</span>
                        </div>
                        <small class="text-muted">Used for daily contracts</small>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>Save
                        </button>
                        <a href="${pageContext.request.contextPath}/price?action=categories&type=rent"
                           class="btn btn-outline-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

</t:layout>