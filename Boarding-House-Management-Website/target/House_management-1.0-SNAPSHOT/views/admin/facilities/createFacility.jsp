<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<t:layout>

    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/facility">Facilities</a>
            </li>
            <li class="breadcrumb-item active">Add New Facility</li>
        </ol>
    </nav>

    <div class="row justify-content-center">
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0 fw-semibold">
                        <i class="bi bi-plus-circle text-primary me-2"></i>Add New Facility
                    </h5>
                </div>
                <div class="card-body p-4">
                    <div class="alert alert-light border-primary border-start border-4 mb-4">
                        <small class="text-muted">
                            <i class="bi bi-info-circle me-1 text-primary"></i>
                            <strong>Facilities</strong> are chargeable room add-ons with a monthly surcharge —
                            e.g. Parking lot, Swimming pool, Gym.
                        </small>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/facility">
                        <input type="hidden" name="action" value="create">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Facility Name <span class="text-danger">*</span></label>
                            <input type="text" name="facilityName" class="form-control"
                                   placeholder="e.g. Parking lot" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Category ID <span class="text-danger">*</span></label>
                            <input type="number" name="categoryId" class="form-control" required min="1">
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" class="form-control" rows="3"
                                      placeholder="Short description of this facility..."></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Image URL</label>
                            <input type="text" name="image" class="form-control"
                                   placeholder="assets/images/…">
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Price / month (VND)</label>
                            <input type="number" name="monthlyPrice" class="form-control"
                                   min="0" step="1000" placeholder="e.g. 200000">
                            <div class="form-text text-muted">Monthly surcharge added to room rent</div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-check-circle me-1"></i>Save
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

</t:layout>
