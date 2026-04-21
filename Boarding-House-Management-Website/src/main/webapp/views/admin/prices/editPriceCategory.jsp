<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

    <!-- HEADER -->
    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/price?action=categories"
           class="btn btn-sm btn-outline-secondary">
            <i class="bi bi-arrow-left"></i>
        </a>

        <h4 class="mb-0">
            <i class="bi bi-pencil-square me-2"></i>Edit Price Category
        </h4>
    </div>

    <!-- ERROR -->
    <c:if test="${param.error == 'date'}">
        <div class="alert alert-danger">
            Effective date must be in the future!
        </div>
    </c:if>

    <c:if test="${empty category}">
        <div class="alert alert-danger">Price category not found.</div>
    </c:if>

    <c:if test="${not empty category}">

        <div class="card shadow-sm border-0" style="max-width:520px;">
            <div class="card-body">

                <form method="post" action="${pageContext.request.contextPath}/price">

                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="categoryId" value="${category.categoryId}">

                    <!-- CODE -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Category Code *</label>
                        <input type="text" name="categoryCode" class="form-control"
                               value="${category.categoryCode}" required>
                    </div>

                    <!-- TYPE -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Category Type *</label>
                        <select name="categoryType" class="form-select" required>
                            <option value="rent" ${category.categoryType == 'rent' ? 'selected' : ''}>Rent</option>
                            <option value="utility" ${category.categoryType == 'utility' ? 'selected' : ''}>Utility</option>
                            <option value="service" ${category.categoryType == 'service' ? 'selected' : ''}>Service</option>
                            <option value="facility" ${category.categoryType == 'facility' ? 'selected' : ''}>Facility</option>
                        </select>
                    </div>

                    <!-- UNIT -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Unit</label>
                        <input type="text" name="unit" class="form-control"
                               value="${category.unit}">
                    </div>

                    <!-- CURRENT PRICE -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Current Price</label>
                        <div class="form-control bg-light">
                            ${currentPrice}
                        </div>
                    </div>

                    <!-- NEW PRICE -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Price</label>
                        <input type="number" name="priceAmount"
                               class="form-control"
                               step="0.01" min="0"
                               placeholder="Leave blank if no change">
                    </div>

                    <!-- DATE -->
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Effective Date</label>
                        <input type="date" name="effectiveFrom"
                               class="form-control"
                               min="${tomorrow}">
                        <small class="text-muted">
                            Required only if changing price (must be future)
                        </small>
                    </div>

                    <!-- BUTTON -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            Save
                        </button>

                        <a href="${pageContext.request.contextPath}/price?action=categories"
                           class="btn btn-outline-secondary">
                            Cancel
                        </a>
                    </div>

                </form>

            </div>
        </div>

    </c:if>

</t:layout>

<!-- VALIDATION -->
<script>
document.querySelector("form")?.addEventListener("submit", function(e) {
    const price = document.querySelector("[name='priceAmount']").value;
    const date = document.querySelector("[name='effectiveFrom']").value;

    if (price && !date) {
        alert("Please select effective date when changing price!");
        e.preventDefault();
    }
});
</script>