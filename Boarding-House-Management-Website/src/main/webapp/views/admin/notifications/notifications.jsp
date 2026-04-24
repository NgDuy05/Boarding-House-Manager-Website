<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

<style>
    /* 1. Header Gradient */
    .page-header {
        background: linear-gradient(135deg, #001D39, #0A4174, #49769F);
        color: white; border-radius: 12px; padding: 20px 24px; margin-bottom: 24px;
        box-shadow: 0 4px 12px rgba(0, 29, 57, 0.15);
    }
    .page-header .btn-light { background: #fff; border: none; color: #001D39; font-weight: 600; }
    .page-header .btn-light:hover { background: #BDD8E9; color: #001D39; }

    /* 2. Custom Nav Tabs */
    .nav-tabs { border-bottom: 1px solid #BDD8E9; }
    .nav-tabs .nav-link { color: #49769F; font-weight: 500; padding: 10px 20px; border: none; border-bottom: 2px solid transparent; transition: all 0.2s; }
    .nav-tabs .nav-link:hover { color: #0A4174; border-bottom: 2px solid #7BBDE8; }
    .nav-tabs .nav-link.active { color: #001D39; font-weight: 700; background: transparent; border-bottom: 2px solid #001D39; }

    /* 3. Table styling */
    .table thead th { 
        background-color: #BDD8E9 !important; 
        color: #001D39 !important; 
        font-size: 12px; 
        font-weight: 700; 
        text-transform: uppercase; 
        letter-spacing: .5px; 
        border: none; 
    }
    .table tbody tr:hover { background: rgba(123, 189, 232, 0.15); }
    
    /* 4. Badges */
    .badge-general { background-color: #BDD8E9; color: #001D39; border: 1px solid #7BBDE8; }
    .badge-private { background-color: rgba(10, 65, 116, 0.1); color: #0A4174; border: 1px solid rgba(10, 65, 116, 0.3); }

    /* 5. Custom Buttons */
    .btn-theme-dark { background-color: #001D39; color: white; border: none; }
    .btn-theme-dark:hover { background-color: #0A4174; color: white; }

    .btn-outline-theme { border-color: #49769F; color: #49769F; }
    .btn-outline-theme:hover { background-color: #49769F; color: white; }

    .btn-outline-action-view { border-color: #4E8EA2; color: #4E8EA2; }
    .btn-outline-action-view:hover { background-color: #4E8EA2; color: white; }

    .btn-outline-action-edit { border-color: #0A4174; color: #0A4174; }
    .btn-outline-action-edit:hover { background-color: #0A4174; color: white; }
</style>

    <%-- Header --%>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-bell-fill me-2"></i>Notifications</h4>
            <small class="opacity-75" style="color: #BDD8E9;">Manage general and private announcements</small>
        </div>
        <a href="${pageContext.request.contextPath}/notification?action=create"
           class="btn btn-light btn-sm px-3 py-2">
            <i class="bi bi-plus-lg me-1" style="color: #0A4174;"></i>New Notification
        </a>
    </div>

    <%-- Filter tabs: All / General / Private --%>
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link ${empty param.type ? 'active' : ''}"
               href="${pageContext.request.contextPath}/notification?action=list">
                <i class="bi bi-grid me-1"></i>All
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.type == 'broadcast' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/notification?action=list&type=broadcast">
                <i class="bi bi-megaphone me-1"></i>General
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.type == 'targeted' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/notification?action=list&type=targeted">
                <i class="bi bi-person-lines-fill me-1"></i>Private
            </a>
        </li>
    </ul>

    <%-- Search / filter bar --%>
    <form method="get" action="${pageContext.request.contextPath}/notification" class="row g-2 mb-4">
        <input type="hidden" name="action" value="list">
        <c:if test="${not empty param.type}">
            <input type="hidden" name="type" value="${param.type}">
        </c:if>
        <div class="col-md-5">
            <div class="input-group">
                <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                <input type="text" name="keyword" value="${param.keyword}" placeholder="Search title / content…"
                       class="form-control">
            </div>
        </div>
        <div class="col-auto">
            <button class="btn btn-theme-dark h-100 px-3">
                Filter
            </button>
            <a href="${pageContext.request.contextPath}/notification?action=list${not empty param.type ? '&type='.concat(param.type) : ''}"
               class="btn btn-outline-theme h-100 ms-1 px-3">Clear</a>
        </div>
    </form>

    <%-- Table --%>
    <div class="card shadow-sm border-0" style="border-radius: 14px; overflow: hidden;">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0 align-middle">
                    <thead>
                        <tr>
                            <th class="ps-4">#</th>
                            <th>Title</th>
                            <th>Type</th>
                            <th>Created By</th>
                            <th>Date</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty notifications}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-3 d-block mb-2" style="color: #6EA2B3;"></i>No notifications found.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="n" items="${notifications}">
                                    <tr>
                                        <td class="ps-4 text-muted small fw-semibold">#${n.notificationId}</td>
                                        <td class="fw-semibold" style="color: #0A4174;">${n.title}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${n.broadcast}">
                                                    <span class="badge badge-general rounded-pill px-3">
                                                        <i class="bi bi-megaphone me-1"></i>General
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-private rounded-pill px-3">
                                                        <i class="bi bi-person me-1"></i>Private #${n.targetContractId}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${n.createdByName}</td>
                                        <td class="small text-muted">${n.createdAt}</td>
                                        <td class="text-center pe-4">
                                            <a href="${pageContext.request.contextPath}/notification?action=detail&id=${n.notificationId}"
                                               class="btn btn-sm btn-outline-action-view me-1" title="View">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/notification?action=edit&id=${n.notificationId}"
                                               class="btn btn-sm btn-outline-action-edit me-1" title="Edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <form method="post" action="${pageContext.request.contextPath}/notification"
                                                  class="d-inline"
                                                  onsubmit="return confirm('Delete this notification?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="notificationId" value="${n.notificationId}">
                                                <button class="btn btn-sm btn-outline-danger" title="Delete">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</t:layout>