<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/room"
           class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
        <h4 class="mb-0"><i class="bi bi-pencil-square me-2"></i>Edit Room</h4>
    </div>

    <c:if test="${empty room}">
        <div class="alert alert-danger">Room not found.</div>
    </c:if>

    <c:if test="${not empty room}">
        <div class="card shadow-sm border-0 mx-auto" style="max-width:560px;">
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/room">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="roomId" value="${room.roomId}">

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Room Number <span class="text-danger">*</span></label>
                        <input type="text" name="roomNumber" class="form-control" required
                               value="${room.roomNumber}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                        <select name="categoryId" class="form-select" required>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}"
                                    ${cat.categoryId == room.categoryId ? 'selected' : ''}>
                                    ${cat.categoryName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Status</label>
                        <select name="status" class="form-select">
                            <option value="available" ${room.status == 'available' ? 'selected' : ''}>Available</option>
                            <option value="occupied"  ${room.status == 'occupied'  ? 'selected' : ''}>Occupied</option>
                            <option value="maintenance" ${room.status == 'maintenance' ? 'selected' : ''}>Maintenance</option>
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
                            <label class="form-label fw-semibold">Area (m2)</label>
                            <input type="number" name="areaMSquare" class="form-control"
                                   min="1" max="200" step="0.5"
                                   value="${room.areaMSquare}" placeholder="e.g. 25">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Max Occupants</label>
                            <input type="number" name="maxOccupants" class="form-control"
                                   min="1" max="10"
                                   value="${room.maxOccupants}" placeholder="e.g. 2">
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i>Save Changes
                        </button>
                        <a href="javascript:history.back()"
                           class="btn btn-outline-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

    <script>
    function handleRoomImageUpload(input) {
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
            formData.append('type', 'room');

            var reader = new FileReader();
            reader.onload = function(e) {
                var preview = document.getElementById('roomImagePreview');
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
                    document.getElementById('roomImagePath').value = data.fullPath;
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
