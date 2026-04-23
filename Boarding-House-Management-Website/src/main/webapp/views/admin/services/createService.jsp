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
            <li class="breadcrumb-item active">Add New Service</li>
        </ol>
    </nav>

    <div class="row justify-content-center">
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0 fw-semibold">
                        <i class="bi bi-plus-circle text-primary me-2"></i>Add New Service
                    </h5>
                </div>
                <div class="card-body p-4">
                    <c:if test="${not empty errorMsg}">
                        <div class="alert alert-danger">${errorMsg}</div>
                    </c:if>
                    <form method="post" action="${pageContext.request.contextPath}/services">
                        <input type="hidden" name="action" value="insert">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Service Name <span class="text-danger">*</span></label>
                            <input type="text" name="serviceName" class="form-control"
                                   placeholder="e.g. Bình nước, Dọn phòng..." required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Unit <span class="text-danger">*</span></label>
                            <input type="text" name="unit" class="form-control"
                                   placeholder="e.g. lần, tháng, chai..." required>
                            <div class="form-text">Đơn vị tính của dịch vụ (dùng cho hóa đơn).</div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Price (VNĐ) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" name="price" class="form-control"
                                       placeholder="e.g. 10000" min="0" step="1000" required>
                                <span class="input-group-text">₫</span>
                            </div>
                            <div class="form-text">Giá mặc định mỗi đơn vị khi tạo hóa đơn.</div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" class="form-control" rows="3"
                                      placeholder="Mô tả ngắn về dịch vụ..."></textarea>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Image filename</label>
                            <input type="text" name="image" class="form-control"
                                   placeholder="service.jpg" value="service.jpg">
                            <div class="form-text">Để mặc định hoặc nhập tên file từ <code>assets/images/service/</code>.</div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-check-circle me-1"></i>Save Service
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

</t:layout>