<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/facility">Facilities</a>
            </li>
            <li class="breadcrumb-item active">Edit Facility</li>
        </ol>
    </nav>

    <c:if test="${empty facility}">
        <div class="alert alert-danger">Facility not found.</div>
    </c:if>

    <c:if test="${not empty facility}">
        <div class="row justify-content-center">
            <div class="col-lg-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-white border-bottom py-3">
                        <h5 class="mb-0 fw-semibold">
                            <i class="bi bi-pencil-square text-primary me-2"></i>Edit Facility
                        </h5>
                    </div>
                    <div class="card-body p-4">
                        <form method="post" action="${pageContext.request.contextPath}/facility">
                            <input type="hidden" name="action" value="edit">
                            <input type="hidden" name="facilityId" value="${facility.facilityId}">

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Facility Name <span class="text-danger">*</span></label>
                                <input type="text" name="facilityName" class="form-control" required
                                       value="${facility.facilityName}">
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Category ID <span class="text-danger">*</span></label>
                                <input type="number" name="categoryId" class="form-control" required
                                       value="${facility.categoryId}" min="1">
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Description</label>
                                <textarea name="description" class="form-control" rows="3">${facility.description}</textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Image URL</label>
                                <input type="text" name="image" class="form-control"
                                       value="${facility.image}">
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-semibold">Price / month (VND)</label>
                                <input type="number" name="monthlyPrice" class="form-control"
                                       min="0" step="1000" value="${facility.monthlyPrice}">
                                <div class="form-text text-muted">Monthly surcharge added to room rent</div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary px-4">
                                    <i class="bi bi-check-circle me-1"></i>Save Changes
                                </button>
                                <a href="${pageContext.request.contextPath}/facility"
                                   class="btn btn-outline-secondary px-4">
                                    <i class="bi bi-x-circle me-1"></i>Cancel
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

</t:layout>
