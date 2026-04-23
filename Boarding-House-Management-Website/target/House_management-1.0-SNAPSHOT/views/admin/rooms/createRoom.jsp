<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<t:layout>

    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/room"
           class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
        <h4 class="mb-0"><i class="bi bi-house-door me-2"></i>Add Room</h4>
    </div>

    <div class="card shadow-sm border-0" style="max-width:560px;">
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/room">
                <input type="hidden" name="action" value="create">

                <div class="mb-3">
                    <label class="form-label fw-semibold">Room Number <span class="text-danger">*</span></label>
                    <input type="text" name="roomNumber" class="form-control" required
                           placeholder="e.g. 101">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                    <select name="categoryId" class="form-select" required>
                        <option value="">-- Select category --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}">${cat.categoryName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Status</label>
                    <select name="status" class="form-select">
                        <option value="available">Available</option>
                        <option value="occupied">Occupied</option>
                        <option value="maintenance">Maintenance</option>
                    </select>
                </div>

                <div class="mb-4">
                        <label class="form-label fw-semibold">Room Image</label>
                        <div class="d-flex align-items-start gap-3">
                            <div class="position-relative">
                                <div id="roomImagePreview" class="rounded overflow-hidden bg-light d-flex align-items-center justify-content-center"
                                     style="width:160px;height:120px;border:2px dashed #ccc;cursor:pointer;"
                                     onclick="document.getElementById('roomImageInput').click()">
                                    <c:choose>
                                        <c:when test="${not empty room.image}">
                                            <img src="${pageContext.request.contextPath}/${room.image}"
                                                 style="width:100%;height:100%;object-fit:cover;"
                                                 id="roomImgTag" alt="Room image">
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-image text-muted" style="font-size:32px;"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <input type="file" id="roomImageInput" accept="image/*" style="display:none"
                                       onchange="handleRoomImageUpload(this)">
                                <input type="hidden" name="image" id="roomImagePath" value="${room.image}">
                            </div>
                            <div>
                                <div class="small text-muted mb-1">Click to upload room image</div>
                                <div class="small text-muted">JPG, PNG - Max 5MB</div>
                                <div class="small text-muted mt-1">Current: ${not empty room.image ? room.image : 'None'}</div>
                            </div>
                        </div>
                    </div>

                <div class="row mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Area (m²)</label>
                        <input type="number" name="areaMSquare" class="form-control"
                               min="1" max="200" step="0.5" placeholder="e.g. 25">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Max Occupants</label>
                        <input type="number" name="maxOccupants" class="form-control"
                               min="1" max="10" placeholder="e.g. 2">
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-plus-lg me-1"></i>Create
                    </button>
                    <a href="${pageContext.request.contextPath}/room"
                       class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

</t:layout>
