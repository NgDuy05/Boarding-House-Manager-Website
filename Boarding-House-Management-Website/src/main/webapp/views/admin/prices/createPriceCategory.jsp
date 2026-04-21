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
            <i class="bi bi-tag me-2"></i>Add Price Category
        </h4>
    </div>

    <!-- ERROR -->
    <c:if test="${param.error == 'date'}">
        <div class="alert alert-danger">
            Effective date must be in the future!
        </div>
    </c:if>

    <c:if test="${param.error == 'db'}">
        <div class="alert alert-danger">
            Cannot create category. Please try again!
        </div>
    </c:if>

    <!-- FORM -->
    <div class="card shadow-sm border-0" style="max-width:520px;">
        <div class="card-body">

            <form method="post" action="${pageContext.request.contextPath}/price">

                <input type="hidden" name="action" value="create">

                <!-- CATEGORY CODE -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">
                        Category Code <span class="text-danger">*</span>
                    </label>

                    <input type="text"
                           name="categoryCode"
                           class="form-control"
                           placeholder="e.g. ROOM_RENT"
                           required>
                </div>

                <!-- TYPE -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">
                        Category Type <span class="text-danger">*</span>
                    </label>

                    <select name="categoryType" class="form-select" required>
                        <option value="">-- Select type --</option>
                        <option value="rent">Rent</option>
                        <option value="utility">Utility</option>
                        <option value="service">Service</option>
                        <option value="facility">Facility</option>
                    </select>
                </div>

                <!-- UNIT -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">Unit</label>

                    <input type="text"
                           name="unit"
                           class="form-control"
                           placeholder="e.g. month, kWh, m3">
                </div>

                <!-- PRICE -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">
                        Initial Price <span class="text-danger">*</span>
                    </label>

                    <input type="number"
                           name="priceAmount"
                           class="form-control"
                           step="0.01"
                           min="0"
                           required>
                </div>

                <!-- DATE -->
                <div class="mb-4">
                    <label class="form-label fw-semibold">
                        Effective From <span class="text-danger">*</span>
                    </label>

                    <input type="date"
                           name="effectiveFrom"
                           class="form-control"
                           min="${today}"
                           value="${today}"
                           required>

                    <small class="text-muted">
                        Must be today or future date
                    </small>
                </div>

                <!-- BUTTON -->
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-plus-lg me-1"></i>Create
                    </button>

                    <a href="${pageContext.request.contextPath}/price?action=categories"
                       class="btn btn-outline-secondary">
                        Cancel
                    </a>
                </div>

            </form>

        </div>
    </div>

</t:layout>