<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>My Profile - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* Import Font Pretendard */
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css");

        /* Ocean Palette Variables */
        :root {
            --ocean-900: #03045E;
            --ocean-800: #023E8A;
            --ocean-700: #0077B6;
            --ocean-600: #0096C7;
            --ocean-500: #00B4D8;
            --ocean-400: #48CAE4;
            --ocean-300: #90E0EF;
            --ocean-200: #ADE8F4;
            --ocean-100: #CAF0F8;
            
            --ds-bg: #f4f7f9;
            --ds-border: #E1E2E4;
            --ds-text: #292A2D;
        }

        body { 
            font-family: 'Pretendard', sans-serif !important;
            background-color: var(--ds-bg); 
            color: var(--ds-text);
        }

        /* Profile Header Gradient */
        .profile-header {
            background: linear-gradient(135deg, var(--ocean-900), var(--ocean-800), var(--ocean-700));
            border-radius: 16px;
            color: white;
            padding: 32px 24px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(3, 4, 94, 0.15);
        }
        .profile-header::after {
            content: '';
            position: absolute;
            top: -40px; right: -40px;
            width: 160px; height: 160px;
            border-radius: 50%;
            background: rgba(255,255,255,0.08);
        }
        
        .avatar-wrapper {
            width: 100px; height: 100px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 42px;
            border: 3px solid rgba(255,255,255,0.4);
            flex-shrink: 0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .info-card { 
            border-radius: 16px; 
            border: 1px solid var(--ds-border); 
            box-shadow: 0 2px 8px rgba(0,0,0,0.02) !important;
        }

        .info-row {
            display: flex;
            align-items: flex-start;
            padding: 14px 0;
            border-bottom: 1px dashed var(--ocean-200);
        }
        .info-row:last-child { border-bottom: none; }
        
        /* Adjusted labels to be non-bold and capitalize first letter only */
        .info-label {
            width: 160px;
            color: #5A5C63;
            font-size: 14px;
            font-weight: normal; 
            text-transform: capitalize;
            flex-shrink: 0;
        }
        .info-value { font-weight: 600; color: var(--ds-text); }
        
        /* Themed Role Badges */
        .role-badge {
            display: inline-block;
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.3px;
            color: #ffffff !important;
        }
        .role-admin    { background: var(--ocean-900); color: white; }
        .role-staff    { background: var(--ocean-600); color: white; }
        .role-customer { background: rgba(0, 119, 182, 0.1); color: var(--ocean-800); border: 1px solid rgba(0, 119, 182, 0.2); }
        
        /* Buttons */
        .btn-edit {
            background-color: var(--ocean-900);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
        }
        .btn-edit:hover { background-color: var(--ocean-800); color: white; }

        .quick-action-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .quick-action-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 119, 182, 0.08) !important;
        }
    </style>
</head>
<body>
    <%@ include file="../navbar.jsp" %>

    <div class="container-fluid p-0">
      <div class="row g-0" style="min-height: calc(100vh - 56px);">
        <%@ include file="sidebar.jsp" %>
        <main class="col p-4">
    <div style="max-width: 720px; margin: 0 auto;">

        <%-- Success message --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success d-flex align-items-center mb-3" style="border-radius: 12px;" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                <span><c:out value="${sessionScope.successMessage}" /></span>
            </div>
            <% session.removeAttribute("successMessage"); %>
        </c:if>

        <%-- Profile header --%>
        <div class="profile-header mb-4 d-flex align-items-center gap-4">
            <div class="avatar-wrapper">
                <i class="bi bi-person-fill"></i>
            </div>
            <div>
                <h4 class="fw-bold mb-1">${user.fullName}</h4>
                <div class="opacity-75 small mb-3">@${user.username}</div>
                <span class="role-badge
                    ${user.role == 'admin' ? 'role-admin' :
                      user.role == 'staff' ? 'role-staff' : 'role-customer'}">
                    ${user.role == 'admin' ? 'Administrator' :
                      user.role == 'staff' ? 'Staff'         : 'Tenant'}
                </span>
            </div>
        </div>

        <%-- Info card --%>
        <div class="card info-card shadow-sm mb-4">
            <div class="card-body px-4 py-3">

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0 fs-5">
                        <i class="bi bi-person-lines-fill me-2" style="color: var(--ocean-600);"></i>Personal information
                    </h5>
                    <a href="${pageContext.request.contextPath}/customer?action=editProfile"
                       class="btn btn-edit btn-sm px-3">
                        <i class="bi bi-pencil-square me-1"></i>Edit
                    </a>
                </div>

                <div class="info-row">
                    <div class="info-label"><i class="bi bi-person me-2"></i>Full name</div>
                    <div class="info-value">${not empty user.fullName ? user.fullName : '—'}</div>
                </div>

                <div class="info-row">
                    <div class="info-label"><i class="bi bi-at me-2"></i>Username</div>
                    <div class="info-value text-muted">${user.username}</div>
                </div>

                <div class="info-row">
                    <div class="info-label"><i class="bi bi-envelope me-2"></i>Email</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty user.email}">
                                <a href="mailto:${user.email}" class="text-decoration-none" style="color: var(--ocean-700);">${user.email}</a>
                            </c:when>
                            <c:otherwise><span class="text-muted">Not set</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label"><i class="bi bi-telephone me-2"></i>Phone</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty user.phone}">
                                <a href="tel:${user.phone}" class="text-decoration-none" style="color: var(--ocean-700);">${user.phone}</a>
                            </c:when>
                            <c:otherwise><span class="text-muted">Not set</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-label"><i class="bi bi-person-vcard-fill me-2"></i>CCCD</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty user.cccd}">
                                <span class="text-dark">${user.cccd}</span>
                            </c:when>
                            <c:otherwise><span class="text-muted">Not set</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <%-- Quick actions --%>
        <div class="row g-3">
            <div class="col-sm-6">
                <a href="${pageContext.request.contextPath}/customer?action=editProfile"
                   class="card info-card quick-action-card text-decoration-none d-flex flex-row align-items-center p-3 gap-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center"
                         style="width:48px;height:48px;background:var(--ocean-100);flex-shrink:0">
                        <i class="bi bi-pencil" style="color:var(--ocean-700);font-size:20px"></i>
                    </div>
                    <div>
                        <div class="fw-bold text-dark" style="font-size: 15px;">Edit profile</div>
                        <div class="text-muted" style="font-size:13px">Update your personal details</div>
                    </div>
                </a>
            </div>
            <div class="col-sm-6">
                <a href="${pageContext.request.contextPath}/auth?action=changePassword"
                   class="card info-card quick-action-card text-decoration-none d-flex flex-row align-items-center p-3 gap-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center"
                         style="width:48px;height:48px;background:#d1e7dd;flex-shrink:0">
                        <i class="bi bi-shield-lock" style="color:#0f5132;font-size:20px"></i>
                    </div>
                    <div>
                        <div class="fw-bold text-dark" style="font-size: 15px;">Change password</div>
                        <div class="text-muted" style="font-size:13px">Update your security password</div>
                    </div>
                </a>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        </main>
      </div>
    </div>
</body>
</html>