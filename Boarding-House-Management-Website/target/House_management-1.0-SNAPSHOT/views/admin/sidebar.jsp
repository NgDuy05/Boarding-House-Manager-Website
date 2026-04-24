<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Admin Sidebar — included in all admin management pages --%>
<style>
/* =======================
   GLOBAL
======================= */
body {
    background-color: #ffffff !important;
    color: #333;
}

/* =======================
   SIDEBAR
======================= */
.admin-sidebar {
    min-height: calc(100vh - 56px);
    background: #ffffff;
    position: sticky;
    top: 56px;
    height: calc(100vh - 56px);
    overflow-y: auto;
    border-right: 1px solid #e9ecef;
    padding: 10px;
}

/* LINK */
.admin-sidebar .nav-link {
    color: #333;
    border-radius: 10px;
    margin-bottom: 6px;
    padding: 0.55rem 0.9rem;
    font-size: 0.9rem;
    transition: all 0.2s ease;
}

/* 🔥 HOVER CHUẨN */
.admin-sidebar .nav-link:hover {
    background-color: #00537A !important;
    color: #ffffff !important;
}

/* ICON khi hover */
.admin-sidebar .nav-link:hover i {
    color: #ffffff !important;
}

/* ACTIVE */
.admin-sidebar .nav-link.active {
    background: #00537A;
    color: #ffffff;
    font-weight: 500;
    box-shadow: 0 3px 8px rgba(0, 83, 122, 0.25);
}

/* ICON */
.admin-sidebar .nav-link i {
    width: 20px;
}

/* HEADING */
.sidebar-heading {
    color: #999;
    font-size: 0.7rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    padding: 0.75rem 0.9rem 0.3rem;
}

/* =======================
   CONTENT
======================= */
.admin-main {
    background: #ffffff;
}

/* CARD */
.card {
    border: none;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}

/* =======================
   SCROLLBAR
======================= */
.admin-sidebar::-webkit-scrollbar {
    width: 6px;
}

.admin-sidebar::-webkit-scrollbar-thumb {
    background: #ccc;
    border-radius: 10px;
}
</style>

<nav class="col-md-3 col-lg-2 d-md-block admin-sidebar py-3 px-2">

    <div class="sidebar-heading">Overview</div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/dashboard">
                <i class="bi bi-speedometer2 me-2"></i>Dashboard
            </a>
        </li>
    </ul>

    <div class="sidebar-heading mt-2">Finance</div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/bill') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/bill?action=list">
                <i class="bi bi-receipt me-2"></i>Bills
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/deposit') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/deposit">
                <i class="bi bi-bank me-2"></i>Deposits
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/price') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/price">
                <i class="bi bi-tag me-2"></i>Price Categories
            </a>
        </li>
    </ul>

    <div class="sidebar-heading mt-2">Properties</div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/room') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/room?action=list">
                <i class="bi bi-house-door me-2"></i>Rooms
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/facility') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/facility">
                <i class="bi bi-wrench me-2"></i>Facilities
            </a>
        </li>
<!--        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/amenity') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/amenity">
                <i class="bi bi-stars me-2"></i>Amenities
            </a>
        </li>-->
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/utility') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/utility">
                <i class="bi bi-lightning-charge me-2"></i>Utilities
            </a>
        </li>
    </ul>

    <div class="sidebar-heading mt-2">Tenants</div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/contract') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/contract?action=list">
                <i class="bi bi-file-earmark-text me-2"></i>Contracts
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/manage-customer') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/manage-customer">
                <i class="bi bi-people me-2"></i>Customers
            </a>
        </li>
    </ul>

    <div class="sidebar-heading mt-2">Services</div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link ${param.action == 'adminList' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/services?action=adminList">
                <i class="bi bi-grid me-2"></i>Manage Services
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.action == 'manageRequests' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/services?action=manageRequests">
                <i class="bi bi-clipboard2-check me-2"></i>Service Requests
            </a>
        </li>
    </ul>

    <div class="sidebar-heading mt-2">System</div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/user') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/user?action=list">
                <i class="bi bi-person-gear me-2"></i>Users
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/notification') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/notification?action=list">
                <i class="bi bi-bell me-2"></i>Notifications
            </a>
        </li>
<!--        <li class="nav-item">
            <a class="nav-link ${pageContext.request.requestURI.contains('/activity-log') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/activity-log">
                <i class="bi bi-activity me-2"></i>Activity Logs
            </a>
        </li>-->
    </ul>

</nav>
