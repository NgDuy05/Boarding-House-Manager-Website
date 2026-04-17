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
                    <form method="post" action="${pageContext.request.contextPath}/services">
                        <input type="hidden" name="action"    value="update">
                        <input type="hidden" name="serviceId" value="${service.serviceId}">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Service Name <span class="text-danger">*</span></label>
                            <input type="text" name="serviceName" class="form-control"
                                   value="${service.serviceName}" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Price Category <span class="text-danger">*</span></label>
                            <select name="categoryId" class="form-select" required>
                                <option value="">-- Select Category --</option>
                                <c:forEach var="cat" items="${priceCategories}">
                                    <option value="${cat.categoryId}"
                                        ${cat.categoryId == service.categoryId ? 'selected' : ''}>
                                        ${cat.categoryCode} (${cat.unit})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" class="form-control" rows="3">${service.description}</textarea>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Service Image</label>
                            <div class="d-flex align-items-start gap-3">
                                <div class="position-relative">
                                    <div id="serviceImagePreview" class="rounded overflow-hidden bg-light d-flex align-items-center justify-content-center"
                                         style="width:160px;height:120px;border:2px dashed #ccc;cursor:pointer;"
                                         onclick="document.getElementById('serviceImageInput').click()">
                                        <c:choose>
                                            <c:when test="${not empty service.image}">
                                                <img src="${pageContext.request.contextPath}/${service.image}"
                                                     style="width:100%;height:100%;object-fit:cover;"
                                                     id="serviceImgTag" alt="Service image">
                                            </c:when>
                                            <c:otherwise>
                                                <i class="bi bi-image text-muted" style="font-size:32px;"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <input type="file" id="serviceImageInput" accept="image/*" style="display:none"
                                           onchange="handleServiceImageUpload(this)">
                                    <input type="hidden" name="image" id="serviceImagePath" value="${service.image}">
                                </div>
                                <div>
                                    <div class="small text-muted mb-1">Click to upload service image</div>
                                    <div class="small text-muted">JPG, PNG - Max 5MB</div>
                                    <div class="small text-muted mt-1">Current: ${not empty service.image ? service.image : 'None'}</div>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-warning px-4">
                                <i class="bi bi-check-circle me-1"></i>Update Service
                            </button>
                            <a href="${pageContext.request.contextPath}/services?action=adminList"
                               class="btn btn-outline-secondary px-4">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
    function handleServiceImageUpload(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];

            if (!file.type.startsWith('image/')) {
                alert('Only image files are allowed');
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                alert('File size must be less than 5MB');
                return;
            }

            var formData = new FormData();
            formData.append('image', file);
            formData.append('type', 'service');

            var reader = new FileReader();
            reader.onload = function(e) {
                var preview = document.getElementById('serviceImagePreview');
                preview.innerHTML = '<img src="' + e.target.result + '" style="width:100%;height:100%;object-fit:cover;">';
            };
            reader.readAsDataURL(file);

            fetch('${pageContext.request.contextPath}/upload-image', {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    alert('Upload failed: ' + data.error);
                } else {
                    document.getElementById('serviceImagePath').value = data.fullPath;
                }
            })
            .catch(err => {
                console.error(err);
                alert('Could not upload image');
            });
        }
    }
    </script>

</t:layout>
