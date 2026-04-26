<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<t:layout>

    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/price?action=categories&type=utility"
           class="btn btn-sm btn-outline-secondary">
            <i class="bi bi-arrow-left"></i>
        </a>
        <h4 class="mb-0"><i class="bi bi-lightning-charge me-2"></i>Update Utility Price</h4>
    </div>

    <c:if test="${param.error == 'date'}">
        <div class="alert alert-danger">Effective date must be in the future!</div>
    </c:if>

    <c:if test="${empty utility}">
        <div class="alert alert-danger">Utility not found.</div>
    </c:if>

    <c:if test="${not empty utility}">
        <div class="card shadow-sm border-0" style="max-width:520px;">
            <div class="card-header py-3" style="background:linear-gradient(135deg,#4E8EA2,#0A4174);color:white;border-radius:12px 12px 0 0;">
                <strong>${utility.utilityName}</strong>
                <span class="text-white-50 ms-2 small">unit: ${utility.unit}</span>
            </div>
            <div class="card-body">

                <div class="mb-3 p-3 rounded" style="background:rgba(78,142,162,.08);">
                    <small class="text-muted">Current Price</small>
                    <div class="fw-bold fs-5 text-success mt-1">
                        <c:choose>
                            <c:when test="${currentPrice != null}">
                                <fmt:formatNumber value="${currentPrice.price}" groupingUsed="true" maxFractionDigits="0"/>&#8363;/${utility.unit}
                                <small class="text-muted fw-normal ms-2">
                                    (effective from <fmt:formatDate value="${currentPrice.effectiveFrom}" pattern="dd/MM/yyyy"/>)
                                </small>
                            </c:when>
                            <c:otherwise><span class="text-muted fst-italic">No price set</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/price">
                    <input type="hidden" name="action" value="saveUtilityPrice">
                    <input type="hidden" name="utilityId" value="${utility.utilityId}">

                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Price (₫/${utility.unit}) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="number" name="price" class="form-control"
                                   min="0" step="100" required placeholder="Enter new price">
                            <span class="input-group-text">₫/${utility.unit}</span>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold">Effective Date <span class="text-danger">*</span></label>
                        <input type="date" name="effectiveFrom" class="form-control"
                               min="${today}" value="${today}" required>
                        <small class="text-muted">The new price will be applied from this date</small>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>Save
                        </button>
                        <a href="${pageContext.request.contextPath}/price?action=categories&type=utility"
                           class="btn btn-outline-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

</t:layout>