<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

    <%-- Breadcrumb --%>
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/services?action=adminList">Services</a>
            </li>
            <li class="breadcrumb-item active">Edit Service</li>
        </ol>
    </nav>

    <div class="row justify-content-center">
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0 fw-semibold">
                        <i class="bi bi-pencil text-warning me-2"></i>Edit Service — ${service.serviceName}
                    </h5>
                </div>
                <div class="card-body p-4">

                    <c:if test="${not empty errorMsg}">
                        <div class="alert alert-danger d-flex align-items-center gap-2 mb-4">
                            <i class="bi bi-exclamation-circle-fill"></i>
                            <span>${errorMsg}</span>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/services">
                        <input type="hidden" name="action"    value="update">
                        <input type="hidden" name="serviceId" value="${service.serviceId}">

                        <!-- Service Name -->
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Service Name <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="serviceName" class="form-control"
                                   value="${service.serviceName}" required>
                        </div>

                        <!-- Description -->
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" class="form-control" rows="3">${service.description}</textarea>
                        </div>

                        <!-- Pricing -->
                        <div class="card border-0 bg-light rounded-3 p-3 mb-3">
                            <div class="fw-semibold small text-muted mb-3">
                                <i class="bi bi-tag-fill me-1 text-primary"></i>
                                Pricing
                                <span class="fw-normal ms-1">(will be saved to price history)</span>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-7">
                                    <label class="form-label fw-semibold">
                                        Unit Price <span class="text-danger">*</span>
                                    </label>
                                    <div class="input-group">
                                        <input type="number" name="price" class="form-control"
                                               value="${currentPrice}" min="0" step="1000" required
                                               oninput="updatePreview()">
                                        <span class="input-group-text">&#8363;</span>
                                    </div>
                                    <div class="form-text">
                                        Price is effective from the beginning of the current month
                                    </div>
                                </div>

                                <div class="col-md-5">
                                    <label class="form-label fw-semibold">
                                        Unit <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" name="unit" class="form-control"
                                           value="${currentUnit}" required
                                           oninput="updatePreview()">
                                    <div class="form-text">Unit of measurement</div>
                                </div>
                            </div>

                            <!-- Preview -->
                            <div id="pricePreview" class="mt-3 ${empty currentPrice or currentPrice == 0 ? 'd-none' : ''}">
                                <div class="d-flex align-items-center gap-2 text-success">
                                    <i class="bi bi-check-circle-fill"></i>
                                    <span class="fw-semibold" id="pricePreviewText"></span>
                                </div>
                            </div>
                        </div>

                        <!-- Image -->
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Image Filename</label>
                            <input type="text" name="image" class="form-control"
                                   value="${service.image}">
                            <div class="form-text">
                                Enter a filename from <code>assets/images/service/</code>
                            </div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-warning px-4">
                                <i class="bi bi-check-circle me-1"></i>
                                Update Service
                            </button>
                            <a href="${pageContext.request.contextPath}/services?action=adminList"
                               class="btn btn-outline-secondary px-4">
                                <i class="bi bi-x-circle me-1"></i>
                                Cancel
                            </a>
                        </div>

                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function updatePreview() {
            var price = parseFloat(document.querySelector('[name="price"]').value);
            var unit  = document.querySelector('[name="unit"]').value.trim();
            var box   = document.getElementById('pricePreview');
            var txt   = document.getElementById('pricePreviewText');

            if (price > 0 && unit) {
                txt.textContent = price.toLocaleString('en-US') + '₫ / ' + unit;
                box.classList.remove('d-none');
            } else {
                box.classList.add('d-none');
            }
        }
        // Init preview on load
        updatePreview();
    </script>

</t:layout>

