<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; }
        .eu-card { border-radius: 16px; border: none; }
        .form-control:focus, .form-select:focus {
            border-color: #764ba2;
            box-shadow: 0 0 0 0.2rem rgba(118,75,162,0.2);
        }
        .btn-save {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none;
        }
        .btn-save:hover { background: linear-gradient(135deg, #5568d6, #6a3fa0); }
        .page-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 12px;
            padding: 18px 24px;
            margin-bottom: 24px;
        }
        .avatar-circle {
            width: 64px; height: 64px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 28px; font-weight: 700;
            border: 3px solid rgba(255,255,255,0.4);
        }
        .section-title {
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .5px;
            color: #6c757d;
            margin-bottom: 12px;
        }
    </style>
</head>
<body>
    <%@ include file="../../navbar.jsp" %>

<div class="container-fluid">
<div class="row flex-nowrap admin-layout-row">
<%@ include file="../sidebar.jsp" %>
<main class="col admin-main px-4 py-4"><div style="max-width: 680px;">

        <%-- Page header --%>
        <div class="page-header d-flex align-items-center gap-3">
            <div class="avatar-circle">
                ${not empty editUser.fullName ? editUser.fullName.substring(0,1).toUpperCase() : editUser.username.substring(0,1).toUpperCase()}
            </div>
            <div>
                <h4 class="mb-0 fw-bold">Edit Profile</h4>
                <small class="opacity-75">@${editUser.username} · ID #${editUser.userId}</small>
            </div>
            <a href="${pageContext.request.contextPath}/user?action=list"
               class="btn btn-light btn-sm ms-auto">
                <i class="bi bi-arrow-left me-1"></i> Back
            </a>
        </div>

        <form action="${pageContext.request.contextPath}/user" method="post">
            <input type="hidden" name="action"  value="update">
            <input type="hidden" name="userId"  value="${editUser.userId}">
            <input type="hidden" name="username" value="${editUser.username}">

            <%-- Basic info --%>
            <div class="card eu-card shadow-sm mb-3">
                <div class="card-body p-4">
                    <div class="section-title">
                        <i class="bi bi-person me-1"></i>Basic Information
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Username</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-at"></i></span>
                            <input type="text" class="form-control bg-light"
                                   value="${editUser.username}" readonly>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Full Name <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person"></i></span>
                            <input type="text" name="fullName" class="form-control"
                                   placeholder="Enter full name"
                                   value="${editUser.fullName}" required>
                        </div>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                <input type="email" name="email" class="form-control"
                                       placeholder="Email"
                                       value="${editUser.email}">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Phone</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                                <input type="tel" name="phone" class="form-control"
                                       placeholder="Phone number (e.g. 0912345678)"
                                       pattern="^(0|\+84)[0-9]{9}$"
                                       title="10-digit phone number starting with 0 or +84"
                                       value="${editUser.phone}">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Role & account --%>
            <div class="card eu-card shadow-sm mb-3">
                <div class="card-body p-4">
                    <div class="section-title">
                        <i class="bi bi-shield-check me-1"></i>Role &amp; Account
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Role</label>
                        <select name="role" class="form-select">
                            <option value="admin"    ${editUser.role == 'admin'    ? 'selected' : ''}>Administrator</option>
                            <option value="staff"    ${editUser.role == 'staff'    ? 'selected' : ''}>Staff</option>
                            <option value="customer" ${editUser.role == 'customer' ? 'selected' : ''}>Tenant</option>
                        </select>
                    </div>

                    <div class="mb-0">
                        <label class="form-label fw-semibold">
                            New Password
                            <span class="text-muted fw-normal">(leave blank to keep current)</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                            <input type="password" name="password" id="adminNewPwd" class="form-control"
                                   placeholder="Enter new password (optional)">
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('adminNewPwd','eyeAdminPwd')">
                                <i class="bi bi-eye" id="eyeAdminPwd"></i>
                            </button>
                        </div>
                    </div>
                    <div class="mt-3 mb-0">
                        <label class="form-label fw-semibold">
                            Confirm New Password
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                            <input type="password" name="confirmPassword" id="adminConfirmPwd" class="form-control"
                                   placeholder="Re-enter new password">
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('adminConfirmPwd','eyeAdminConfirmPwd')">
                                <i class="bi bi-eye" id="eyeAdminConfirmPwd"></i>
                            </button>
                        </div>
                        <div id="pwdMismatch" class="text-danger small mt-1" style="display:none">
                            Passwords do not match
                        </div>
                    </div>
                </div>
            </div>

            <%-- Hidden image (preserve existing value) --%>
            <input type="hidden" name="image" value="${not empty editUser.image ? editUser.image : 'default.png'}">

            <%-- Actions --%>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-save btn-primary flex-fill fw-semibold">
                    <i class="bi bi-check-circle me-1"></i> Save Changes
                </button>
                <a href="${pageContext.request.contextPath}/user?action=list"
                   class="btn btn-outline-secondary flex-fill fw-semibold">
                    <i class="bi bi-x-circle me-1"></i> Cancel
                </a>
            </div>

        </form>

    </div>

    <script>
        function togglePwd(inputId, iconId) {
            var input = document.getElementById(inputId);
            var icon  = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('bi-eye', 'bi-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('bi-eye-slash', 'bi-eye');
            }
        }

        // Validate confirm password before submit
        document.querySelector('form').addEventListener('submit', function(e) {
            var pwd     = document.getElementById('adminNewPwd').value;
            var confirm = document.getElementById('adminConfirmPwd').value;
            var msg     = document.getElementById('pwdMismatch');
            if (pwd && pwd !== confirm) {
                e.preventDefault();
                msg.style.display = 'block';
                document.getElementById('adminConfirmPwd').focus();
            } else {
                msg.style.display = 'none';
            }
        });
    </script>
</div>
<%@ include file="../../footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</main>
</div>
</div>
</body>
</html>
